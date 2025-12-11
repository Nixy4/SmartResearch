def find_new_contents(query_processor, short_memory, query_text)
  results = query_processor.process_query(query_text, 3)
  contents = []
  results.each do |r|
    unless short_memory.find_mem(r[:url])
      short_memory.add_mem(r[:url], r[:content])
      contents << {
        :url => r[:url],
        :content => r[:content],
      }
    end
  end
  return contents
end

def find_contents(query_processor, short_memory, query_text)
  results = query_processor.process_query(query_text, 5)
  contents = []
  results.each do |r|
    unless short_memory.find_mem(r[:url])
      short_memory.add_mem(r[:url], r[:content])
    end
    contents << {
      :url => r[:url],
      :content => short_memory.find_mem(r[:url]),
    }
  end
  return contents
end

def get_json(result)
  pattern = /```json\s*(.*?)\s*```/m
  match = result.match(pattern)
  json_str = match ? match[1].strip : "{}"
  if json_str == "{}"
    pattern = /\{(.*)\}/m
    match = result.match(pattern)
    json_str = match ? "{" + match[1].strip + "}" : "{}"
  end
  begin
    return JSON.parse(json_str)
  rescue JSON::ParserError
    return {}
  end
end

def generate_outline(query_text, query_processor, short_memory)
  # Check if outline.json exists and read it
  existing_outline = {}
  if File.exist?("reports/outline.json")
    begin
      existing_outline = JSON.parse(File.read("reports/outline.json"))
      show_log "发现已有提纲文件，将基于现有提纲进行修改"
    rescue JSON::ParserError
      show_log "现有提纲文件格式错误，将重新生成"
      existing_outline = {}
    end
  end

  contents = find_new_contents(query_processor, short_memory, query_text)
  show_log "找到#{contents.size}条记录"

  last_json = existing_outline
  while contents.size > 0
    # Include existing outline in the worker call for modification
    outline = call_worker(:preparation_outline, {
      query_text: query_text,
      contents: contents,
      existing_outline: last_json,
    }, with_tools: false, with_history: true)
    outline = outline.content
    outline_json = get_json(outline)

    if outline_json.empty?
      outline_json = last_json
    else
      last_json = outline_json
    end

    if outline_json["query"]
      contents = find_new_contents(query_processor, short_memory, outline_json["query"])
      show_log "又找到#{contents.size}条记录"
    else
      contents = []
    end
  end

  # Add original query to outline for reference
  outline_json["original_query"] = query_text

  # Save outline to reports/outline.json
  File.write("reports/outline.json", JSON.pretty_generate(outline_json))
  show_log "提纲已生成并保存到 reports/outline.json"
  return outline_json
end

def write_full_article(outline_json, query_processor, short_memory)
  # Use article info from outline if available, otherwise use defaults
  article_info = outline_json["article"] || {}
  file_name = "reports/" + article_info["file"] || "reports/report_#{Time.now.to_i}.md"
  article_title = article_info["title"]

  f = File.new(file_name, "w")
  f.puts("#{article_title}")

  outline_json["outline"].each do |id, chapter|
    contents = find_contents(query_processor, short_memory, article_title + "," + chapter["title"] + "," + chapter["summary"])
    show_log "针对章节：#{chapter["title"]}，又找到#{contents.size}条记录"

    chapter_text = call_worker(
      :chapter_writer,
      {
        outline: outline_json["outline"],
        contents: contents,
        title: chapter["title"],
        summary: chapter["summary"],
        length: chapter["length"],
        article_style: article_info["style"],
        article_audience: article_info["audience"],
      },
      with_tools: false,
      with_history: false,
    )
    f.puts "\n#{chapter["title"]}"
    f.puts chapter_text.content
    show_log "完成写作：#{chapter["title"]}"
  end
  f.close
  show_log "写作完成，内容存放在：#{file_name}"
  return file_name
end

def rewrite_chapter(chapter_id, new_instructions, query_text, query_processor, short_memory)
  # Load outline from file
  outline_json = JSON.parse(File.read("reports/outline.json")) if File.exist?("reports/outline.json")
  return show_log "请先生成提纲 (使用 outline 命令)" unless outline_json

  chapter = outline_json["outline"][chapter_id.to_s]
  return show_log "未找到章节 #{chapter_id}" unless chapter

  show_log "正在重写章节: #{chapter["title"]}"

  # Find content for this specific chapter
  contents = find_contents(query_processor, short_memory, query_text + "," + chapter["title"] + "," + chapter["summary"] + "," + new_instructions)

  # Rewrite the chapter with new instructions
  article_info = outline_json["article"] || {}
  rewritten_chapter = call_worker(
    :chapter_writer,
    {
      outline: outline_json["outline"],
      contents: contents,
      title: chapter["title"],
      summary: chapter["summary"],
      length: chapter["length"],
      instructions: new_instructions,
      article_style: article_info["style"],
      article_audience: article_info["audience"],
    },
    with_tools: true,  # Enable tools for modify_file
    with_history: false,
  )

  show_log "章节重写完成: #{chapter["title"]}"

  # Try to find the report file to update
  article_info = outline_json["article"] || {}
  file_name = "reports/" + (article_info["file"] || "report_#{Time.now.to_i}.md")

  if File.exist?(file_name)
    # Read current content to find the chapter
    current_content = File.read(file_name)
    lines = current_content.lines

    # Find the chapter section
    chapter_header = "#{chapter["title"]}"
    chapter_start = lines.index { |line| line.strip == chapter_header }

    if chapter_start
      # Find the end of this chapter (next header or end of file)
      chapter_end = lines[chapter_start + 1..-1].index { |line| line.start_with?("##") }
      chapter_end = chapter_end ? chapter_start + 1 + chapter_end : lines.length

      # Create diff to replace the chapter content
      diff_content = ""
      # Keep the header line
      diff_content += " #{lines[chapter_start]}"
      # Remove old content
      (chapter_start + 1...chapter_end).each do |i|
        diff_content += "-#{lines[i]}"
      end
      # Add new content
      rewritten_chapter.content.lines.each do |line|
        diff_content += "+#{line}"
      end

      # Use modify_file tool to update the file
      modify_result = call_tool(:modify_file, {
        filename: file_name,
        diff_txt: diff_content,
      })

      show_log "文件已更新: #{modify_result}"
    else
      show_log "警告: 在文件中未找到章节 '#{chapter["title"]}'，重写内容将仅显示而不保存"
    end
  else
    show_log "警告: 报告文件 #{file_name} 不存在，重写内容将仅显示而不保存"
  end

  return rewritten_chapter.content
end

SmartAgent.define :smart_writer do
  query_processor = QueryProcessor.new(SmartAgent.prompt_engine)
  short_memory = ShortMemory.new
  input = params[:text]

  if input.downcase == "h" || input.downcase == "help"
    show_log "帮助信息："
    show_log "h/help                  显示帮助"
    show_log "outline [主题]          生成文章提纲并保存到 outline.json"
    show_log "outline [讨论]          根据讨论，修改提纲文件 outline.json 的内容"
    show_log "outline                 列出当前提纲"
    show_log "del                     删除原本存在的 outline.json 文件"
    show_log "write_all / wa          根据 outline.json 生成完整文章"
    show_log "rewrite [章节ID] [指令]  重写指定章节"
    show_log "  示例: rewrite 1. 请用更专业的语言重写这个章节"
    show_log "format                  重新调整脚注的格式"
    show_log "sa                      显示整篇文章"
    show_log "sa [章节ID]             显示文章的特定章节"
  elsif input.downcase.start_with?("outline ")
    query_text = input[7..-1].strip
    generate_outline(query_text, query_processor, short_memory)
  elsif input.downcase == "outline"
    if File.exist?("reports/outline.json")
      outline_json = JSON.parse(File.read("reports/outline.json"))
      show_log JSON.pretty_generate(outline_json)
    else
      show_log "outline.json文件不存在"
    end
  elsif input.downcase.start_with?("del")
    if File.exist?("reports/outline.json")
      File.delete("reports/outline.json")
      show_log "outline.json文件已经删除"
    end
  elsif input.downcase.start_with?("write_all") || input.downcase == "wa"
    if File.exist?("reports/outline.json")
      outline_json = JSON.parse(File.read("reports/outline.json"))
      write_full_article(outline_json, query_processor, short_memory)
    else
      show_log "请先生成提纲 (使用 outline 命令)"
    end
  elsif input.downcase.start_with?("rewrite ")
    parts = input[8..-1].strip.split(" ", 2)
    if parts.size >= 2
      chapter_id = parts[0]
      instructions = parts[1]
      # Use the original query text from the outline if available
      outline_json = JSON.parse(File.read("reports/outline.json")) if File.exist?("reports/outline.json")
      query_text = outline_json["original_query"] if outline_json && outline_json["original_query"]
      query_text ||= ""

      rewritten_content = rewrite_chapter(chapter_id, instructions, query_text, query_processor, short_memory)
      show_log "重写后的内容："
      show_log rewritten_content
    else
      show_log "用法: rewrite [章节ID] [指令]"
    end
  elsif input.downcase == "format"
    if File.exist?("reports/outline.json")
      format_article("reports/outline.json")
    else
      show_log "提纲文件不存在"
    end
  elsif input.downcase == "sa"
    if File.exist?("reports/outline.json")
      outline_json = JSON.parse(File.read("reports/outline.json"))
      file_name = "reports/" + outline_json["article"]["file"]
      content = File.read(file_name)
      show_log("\n" + content)
    end
  elsif input.downcase.start_with?("sa ")
    if File.exist?("reports/outline.json")
      outline_json = JSON.parse(File.read("reports/outline.json"))
      file_name = "reports/" + outline_json["article"]["file"]
      content = File.read(file_name)
      chapter_list = outline_json["outline"]
      id = input[3..-1]
      if chapter_list[id]
        chapter_title = chapter_list[id]["title"]
        title_pos = content.index(chapter_title)
        if title_pos
          end_pos = content.index("\n##", title_pos)
          if end_pos
            chapter_text = content[title_pos...end_pos]
          else
            # 如果是最后一个章节，取到文件末尾
            chapter_text = content[title_pos..-1]
          end
          show_log("\n" + chapter_text)
        end
      else
        show_log("章节不存在")
      end
    end
  else
    show_log "请输入正确的命令，使用 'h' 查看帮助"
  end
end

SmartAgent.build_agent(
  :smart_writer,
  tools: [:modify_file],
)

def parse_chapter(chapter_text)
  # 分离正文和脚注
  main_content = ""
  footnotes = []

  lines = chapter_text.split("\n")
  in_footnotes = false

  lines.each do |line|
    # 检测脚注开始（以 [^数字]: 开头的行）
    if line =~ /^\[\^(\d+)\]:\s*(.+)$/
      in_footnotes = true
      footnote_id = $1.to_i
      footnote_content = $2.strip

      # 解析脚注内容，提取URL和标题
      if footnote_content =~ /(.+)\s+-\s+(https?:\/\/\S+)/
        title = $1.strip
        url = $2.strip
      else
        # 如果没有明确的URL格式，将整个内容作为标题
        title = footnote_content
        url = ""
      end

      footnotes << {
        "url" => url,
        "title" => title,
        "id" => footnote_id,
      }
    elsif in_footnotes
      # 如果已经在脚注区域，继续收集脚注内容
      if line.strip.empty?
        # 空行可能表示脚注结束
        in_footnotes = false
      else
        # 将多行脚注内容合并到最后一个脚注的标题中
        if footnotes.any?
          footnotes.last["title"] += " " + line.strip
        end
      end
    else
      # 正文内容
      main_content += line + "\n"
    end
  end

  # 清理正文末尾的空白行
  main_content.strip!

  {
    "content" => main_content,
    "footnotes" => footnotes,
  }
end

def renote_content(result, all_footnotes)
  content = result["content"]
  footnotes = result["footnotes"]

  # 创建一个映射表，用于存储原始脚注ID到新all_id的映射
  footnote_mapping = {}

  # 遍历所有脚注
  footnotes.each do |footnote|
    original_id = footnote["id"]
    url = footnote["url"]

    if url.empty?
      # 如果URL为空，删除这个脚注 - 在映射表中标记为nil
      footnote_mapping[original_id] = nil
    else
      # 如果URL不为空，在all_footnotes中查找对应的all_id
      if all_footnotes[url] && all_footnotes[url]["all_id"]
        new_id = all_footnotes[url]["all_id"]
        footnote_mapping[original_id] = new_id
      else
        # 如果没有找到对应的all_id，也删除这个脚注
        footnote_mapping[original_id] = nil
      end
    end
  end

  # 替换content中的脚注引用
  footnote_mapping.each do |original_id, new_id|
    if new_id.nil?
      # 删除脚注引用
      content = content.gsub(/\[\^#{original_id}\]/, "")
    else
      # 替换为新的all_id
      content = content.gsub(/\[\^#{original_id}\]/, "【^#{new_id}】")
    end
  end

  content = content.gsub("【", "[")
  content = content.gsub("】", "]")

  # 清理可能出现的多余空格
  #content = content.gsub(/\s+/, " ").strip

  content
end

def format_article(json_file)
  outline = JSON.parse(File.read(json_file))
  markdown_file = "reports/" + outline["article"]["file"]
  new_markdown_file = markdown_file.gsub(".md", ".new.md")
  all_footnotes = {}
  all_id = 1
  content = File.read(markdown_file)
  chapter_list = outline["outline"]
  parsed_chapters = ""

  chapter_list.each do |id, info|
    title = info["title"]
    title_pos = content.index(title)
    if title_pos
      end_pos = content.index("\n##", title_pos)
      if end_pos
        chapter_text = content[title_pos...end_pos]
      else
        # 如果是最后一个章节，取到文件末尾
        chapter_text = content[title_pos..-1]
      end

      result = parse_chapter(chapter_text)
      result["footnotes"].each do |footnote|
        unless footnote["url"].empty?
          url = footnote["url"]
          unless all_footnotes[url]
            all_footnotes[url] = footnote
            all_footnotes[url]["all_id"] = all_id
            all_id += 1
          else
            if all_footnotes[url]["title"].size < footnote["title"].size
              all_footnotes[url]["title"] = footnote["title"]
            end
          end
        end
      end
      result["content"] = renote_content(result, all_footnotes)
      parsed_chapters += result["content"] + "\n\n"
    end
  end
  all_footnotes.each do |url, info|
    parsed_chapters += "[^#{info["all_id"]}]: #{info["title"]} - #{info["url"]}\n"
  end
  # 输出解析结果到新文件
  File.write(new_markdown_file, parsed_chapters)

  show_log "解析完成！结果已保存到: #{new_markdown_file}"
end
