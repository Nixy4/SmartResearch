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

def chunk_content(content, max_chars = 4000)
  # 如果内容长度小于max_chars，则整篇返回
  return [content] if content.length <= max_chars

  # 按照markdown的语法分段
  chunks = split_by_markdown_headers(content, max_chars)

  # 如果按markdown分段后仍然有超过max_chars的块，则进一步分片
  final_chunks = []
  chunks.each do |chunk|
    if chunk.length <= max_chars
      final_chunks << chunk
    else
      # 按max_chars大小分片，且各片之间保留100的重叠内容
      final_chunks += split_with_overlap(chunk, max_chars, 100)
    end
  end

  final_chunks
end

# 按照markdown标题分段
def split_by_markdown_headers(content, max_chars)
  # 定义标题级别
  headers = ["#", "##", "###", "####"]
  # 创建正则表达式匹配标题
  header_pattern = /^(#{headers.join("|")})\s+.+$/m

  # 找到所有标题的位置
  matches = content.enum_for(:scan, header_pattern).map { Regexp.last_match }

  # 如果没有找到标题，返回原内容
  return [content] if matches.empty?

  chunks = []
  last_index = 0

  matches.each_with_index do |match, index|
    # 获取当前标题的内容（到下一个标题或结尾）
    start_index = match.begin(0)
    end_index = if index + 1 < matches.length
        matches[index + 1].begin(0)
      else
        content.length
      end

    # 如果不是从开头开始，添加从上一个标题到当前标题的内容
    if last_index < start_index
      section = content[last_index...start_index]
      chunks << section unless section.strip.empty?
    end

    # 添加当前标题及其内容
    section = content[start_index...end_index]
    chunks << section
    last_index = end_index
  end

  # 添加最后一部分（如果有的话）
  if last_index < content.length
    section = content[last_index..-1]
    chunks << section unless section.strip.empty?
  end

  chunks
end

# 按指定大小分片，且各片之间保留重叠内容
def split_with_overlap(content, max_chars, overlap)
  chunks = []
  start_index = 0

  while start_index < content.length
    # 计算理想结束索引
    ideal_end_index = start_index + max_chars
    ideal_end_index = content.length if ideal_end_index > content.length

    # 初始化实际结束索引
    end_index = ideal_end_index

    # 如果不是在内容末尾，尝试找到最近的换行符
    if ideal_end_index < content.length
      # 在理想结束位置附近查找换行符
      search_start = [ideal_end_index - 200, start_index].max
      search_end = [ideal_end_index + 200, content.length].min
      substring = content[search_start...search_end]

      # 查找最接近理想位置的换行符
      best_newline = -1
      substring.scan(/\n/) do
        pos = search_start + $~.begin(0)
        if pos <= ideal_end_index
          best_newline = pos
        else
          # 如果已经超过了理想位置，就使用找到的最佳位置
          break if best_newline != -1
        end
      end

      # 如果找到了换行符，调整结束位置
      if best_newline != -1 && best_newline > start_index
        end_index = best_newline + 1  # 包含换行符
      end
    end

    # 确保不会超出内容长度
    end_index = content.length if end_index > content.length

    # 提取分片
    chunk = content[start_index...end_index]
    chunks << chunk

    # 如果已经到结尾，退出循环
    break if end_index >= content.length

    # 计算下一个分片的起始位置（保留重叠）
    start_index = end_index - overlap
    start_index = 0 if start_index < 0  # 确保不会为负数
  end

  chunks
end

def process_content_chunks(doc_id, title, content, topic_ids)
  topic_ids = ResearchTopic.select_map(:id) if topic_ids.empty?
  chunks = chunk_content(content)
  section_ids = []

  chunks.each_with_index do |chunk, index|
    section_title = chunks.size > 1 ? "#{title} (Part #{index + 1}/#{chunks.size})" : title

    # Create or update SourceSection record
    section = SourceSection.create_section(doc_id, "null", section_title)
    section.content = chunk
    section.section_number = index + 1
    section.save

    section_ids << section.id

    # Generate embedding for the chunk
    text = "#{section_title}\n#{chunk}"
    begin
      unless text.empty?
        result = call_worker(:get_embedding, { text: text, length: 1024 })
        Embedding.create_embedding(section.id, "[#{result.response.join(",")}]")
      end
      show_log "嵌入数据保存成功 (Part #{index + 1})"
    rescue => e
      show_log "嵌入数据保存失败 (Part #{index + 1}): #{e.message}"
    end

    # Process tags for each topic
    topic_ids.each do |topic_id|
      topic = ResearchTopic[topic_id]
      tags = call_worker(:get_tags, { topic: topic.name, text: text })
      begin
        json_obj = get_json(tags.content)
        unless json_obj.empty?
          type_tag = Tag.find_or_create_by_name(json_obj["Type"])
          section[:tag_id] = type_tag[:id]
          section.save
          ResearchTopicSection.create_link(topic_id, section.id)
          ResearchTopicTag.create_link(topic.id, type_tag[:id])
          json_obj["Tags"].each do |tag|
            new_tag = Tag.find_or_create_by_name(tag)
            SectionTag.create_link(section[:id], new_tag[:id])
          end
          show_log "标签保存成功 (Part #{index + 1})"
        end
      rescue => e
        show_log "标签处理失败 (Part #{index + 1}): #{e.message}"
      end
    end
  end
  section_ids
end

SmartAgent::Agent.define :smart_kb do
  query_processor = QueryProcessor.new(SmartAgent.prompt_engine)
  short_memory = ShortMemory.new
  input = params[:text]
  if input.downcase == "h" || input.downcase == "help"
    show_log "帮助信息："
    show_log "h/help             显示帮助"
    show_log "l/list             列出研究主题"
    show_log "l [num]/list [num] 列出特定主题下的文档标题"
    show_log "ll [num]           列出特定文档的内容"
    show_log "d [num]            下载指定正文内容"
    show_log "d [url]            下载指定URL的内容并保存"
    show_log "dd [num]           下载特定主题下的所有正文内容"
    show_log "ask [question]     向知识库提问"
    show_log "del [num]          删除指定的章节"
    show_log "dall               下载所有未能完成下载的内容"
  elsif input.downcase == "l" || input.downcase == "list"
    ResearchTopic.order_by(:id).each do |topic|
      show_log "#{topic[:id]}" + " " * (4 - "#{topic[:id]}".size) + topic[:name]
    end
  elsif input.downcase[0..1] == "l " && input[2..-1].to_i > 0
    topic_id = input[2..-1].to_i
    doc_list = []
    ResearchTopicSection.order_by(:section_id).where_all(research_topic_id: topic_id).each do |rts|
      section = SourceSection[rts[:section_id]]
      doc = SourceDocument[section[:document_id]]
      unless doc_list.include?(doc.id)
        doc_list << doc.id
        show_log "#{doc[:id]}" + " " * (4 - "#{doc[:id]}".size) + doc[:title]
        if section.content == "null"
          show_log "     null"
        end
      end
    end
  elsif input.downcase[0..2] == "ll " && input[3..-1].to_i > 0
    doc_id = input[3..-1].to_i
    doc = SourceDocument[doc_id]
    show_log doc[:title]
    section_ids = []
    SourceSection.order_by(:id).where_all(document_id: doc_id).each do |section|
      section_ids << section.id
      show_log section[:content]
      tag_ids = SectionTag.order_by(:tag_id).where(section_id: section.id).select_map(:tag_id)
      show_log "Tags: " + Tag.where(id: tag_ids).select_map(:name).to_s
    end
  elsif input.downcase[0..1] == "d " && input[2..-1].to_i > 0
    doc_id = input[2..-1].to_i
    doc = SourceDocument[doc_id]
    show_log doc[:url]
    content = call_worker(:download_page, { url: doc[:url] })

    # Extract title from content
    pattern = /\[title\]\s*(.*?)\s*\[\/title\]/m
    match = content.content.match(pattern)
    title = match ? match[1] : doc[:title] || "Untitled"
    md_content = content.content.gsub(/\[title\].*?\[\/title\]/m, "").strip
    section_ids = SourceSection.where(document_id: doc[:id]).select_map(:id)
    topic_ids = ResearchTopicSection.where(section_id: section_ids).select_map(:research_topic_id).uniq
    # 删除与该文档相关的所有SectionTag记录
    SourceSection.where(document_id: doc_id).each do |section|
      SectionTag.where(section_id: section.id).delete
    end

    # 删除与该文档相关的所有Embedding记录
    SourceSection.where(document_id: doc_id).each do |section|
      Embedding.where(source_id: section.id).delete
    end

    # 删除所有topic与section之间的关联
    ResearchTopicSection.where(section_id: section_ids).delete

    # 删除与该文档相关的所有SourceSection记录
    SourceSection.where(document_id: doc_id).delete

    # Process content with chunking
    process_content_chunks(doc_id, title, md_content, topic_ids)
    doc.download_state = 1
    doc.save
    show_log "下载并分片保存完成"
  elsif input.downcase[0..1] == "d " && (input[2..-1].include?("https://") || input[2..-1].include?("http://"))
    url = input[2..-1]
    content = call_worker(:download_page, { url: url })

    # Extract title from content
    md_content = content.content
    pattern = /\[title\]\s*(.*?)\s*\[\/title\]/m
    match = md_content.match(pattern)
    title = match ? match[1] : ""
    md_content = md_content.gsub(/\[title\].*?\[\/title\]/m, "").strip

    # 创建或更新SourceDocument记录
    doc = SourceDocument.find_or_create_by_url(url)
    doc.title = title
    doc.save

    # Process content with chunking
    process_content_chunks(doc[:id], title, md_content)
    doc.download_state = 1
    doc.save
    show_log "下载并分片保存完成"
  elsif input.downcase[0..3] == "del " && input[4..-1].to_i > 0
    doc_id = input[4..-1].to_i
    doc = SourceDocument[doc_id]
    if doc
      # 删除与该文档相关的所有SectionTag记录
      SourceSection.where(document_id: doc_id).each do |section|
        SectionTag.where(section_id: section.id).delete
      end

      # 删除与该文档相关的所有Embedding记录
      SourceSection.where(document_id: doc_id).each do |section|
        Embedding.where(source_id: section.id).delete
      end

      # 删除与该文档相关的所有SourceSection记录
      SourceSection.where(document_id: doc_id).delete

      # 删除SourceDocument记录
      doc.delete
      show_log "文档及其相关记录已删除"
    else
      show_log "未找到指定的文档"
    end
  elsif input.downcase[0..3] == "ask "
    question = input[4..-1]
    contents = find_new_contents(query_processor, short_memory, question)
    show_log "找到#{contents.size}条记录"
    call_worker(:summary, { text: "问题：" + question + "\n回答：" + contents.to_s })
  elsif input.downcase[0..2] == "dd " && input[3..-1].to_i > 0
    topic_id = input[2..-1].to_i
    doc_list = []
    ResearchTopicSection.order_by(:section_id).where_all(research_topic_id: topic_id).each do |rts|
      section = SourceSection[rts[:section_id]]
      doc = SourceDocument[section[:document_id]]
      next if doc.download_state > 0
      unless doc_list.include?(doc.id)
        doc_list << doc.id
        if section.content == "null"
          begin
            show_log "下载： #{doc[:url]}"
            content = call_worker(:download_page, { url: doc[:url] })
            unless content.content.to_s.empty?
              pattern = /\[title\]\s*(.*?)\s*\[\/title\]/m
              match = content.content.match(pattern)
              title = match ? match[1] : doc[:title] || "Untitled"
              md_content = content.content.gsub(/\[title\].*?\[\/title\]/m, "").strip
              if md_content.include?("读取PDF时出错")
                show_log "PDF解析失败"
                next
              end
              section_ids = SourceSection.where(document_id: doc.id).select_map(:id)
              topic_ids = ResearchTopicSection.where(section_id: section_ids).select_map(:research_topic_id).uniq
              # 删除与该文档相关的所有SectionTag记录
              SourceSection.where(document_id: doc.id).each do |section|
                SectionTag.where(section_id: section.id).delete
              end

              # 删除与该文档相关的所有Embedding记录
              SourceSection.where(document_id: doc.id).each do |section|
                Embedding.where(source_id: section.id).delete
              end

              # 删除所有topic与section之间的关联
              ResearchTopicSection.where(section_id: section_ids).delete

              # 删除与该文档相关的所有SourceSection记录
              SourceSection.where(document_id: doc.id).delete

              # Process content with chunking
              process_content_chunks(doc.id, title, md_content, topic_ids)
              doc.download_state = 1
              doc.save
              show_log "下载并分片保存完成"
            else
              doc.download_state = 2
              doc.save
              show_log "下载失败"
            end
          rescue => e
            doc.download_state = 2
            doc.save
            show_log "下载失败: #{e.message}"
          end
        end
      end
    end
  elsif input.downcase == "dall"
    SourceSection.order_by(:id).where(content: "null").select_map(:id).each do |section_id|
      section = SourceSection[section_id]
      doc = SourceDocument[section.document_id]
      next if doc.download_state > 0
      show_log "下载： #{doc[:url]}"
      begin
        content = call_worker(:download_page, { url: doc[:url] })
        unless content.content.to_s.empty?
          pattern = /\[title\]\s*(.*?)\s*\[\/title\]/m
          match = content.content.match(pattern)
          title = match ? match[1] : doc[:title] || "Untitled"
          md_content = content.content.gsub(/\[title\].*?\[\/title\]/m, "").strip
          if md_content.include?("读取PDF时出错")
            show_log "PDF解析失败"
            next
          end
          section_ids = SourceSection.where(document_id: doc.id).select_map(:id)
          topic_ids = ResearchTopicSection.where(section_id: section_ids).select_map(:research_topic_id).uniq
          # 删除与该文档相关的所有SectionTag记录
          SourceSection.where(document_id: doc.id).each do |section|
            SectionTag.where(section_id: section.id).delete
          end

          # 删除与该文档相关的所有Embedding记录
          SourceSection.where(document_id: doc.id).each do |section|
            Embedding.where(source_id: section.id).delete
          end

          # 删除所有topic与section之间的关联
          ResearchTopicSection.where(section_id: section_ids).delete

          # 删除与该文档相关的所有SourceSection记录
          SourceSection.where(document_id: doc.id).delete

          # Process content with chunking
          process_content_chunks(doc.id, title, md_content, topic_ids)
          doc.download_state = 1
          doc.save
          show_log "下载并分片保存完成"
        else
          doc.download_state = 2
          doc.save
          show_log "下载失败"
        end
      rescue => e
        doc.download_state = 2
        doc.save
        show_log "下载失败: #{e.message}"
      end
    end
    show_log "已经下载所有文档。"
  else
    show_log "请输入正确的命令"
  end
end

SmartAgent.build_agent(
  :smart_kb
)
