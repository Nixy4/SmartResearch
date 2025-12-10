# CLI 应用配置
require "logger"

module SmartResearchCLI
  class Application
    attr_accessor :engine, :agent_engine
    attr_reader :output_buffer

    def initialize(config_path: "./config", log_path: "./log")
      @config_path = config_path
      @log_path = log_path
      @output_buffer = ""
      
      # 初始化引擎
      @engine = SmartPrompt::Engine.new("#{@config_path}/llm_config.yml")
      @agent_engine = SmartAgent::Engine.new("#{@config_path}/agent.yml")
      
      # 设置日志
      setup_logger
    end

    # 调用agent并返回结果
    def call_agent(agent_name, input_text, options = {})
      reasoning = false
      reasoned = false
      @output_buffer = ""
      
      agent = @agent_engine.agents[agent_name]
      raise "Agent '#{agent_name}' not found" unless agent
      
      # 红色提示：开始调用 agent
      puts "\e[31m>>> [Agent Start] Calling agent: #{agent_name}\e[0m"
      SmartResearchCLI.logger.info("Calling agent: #{agent_name}")
      
      #* 注册<响应中>事件回调
      agent.on_reasoning do |chunk|
        reasoning_content = chunk.dig("choices", 0, "delta", "reasoning_content")
        unless reasoning_content.nil? || reasoning_content.empty?
          reasoned = true
          if reasoning == false
            print_thinking_header
            reasoning = true
          end
          print_reasoning(reasoning_content)
          
          if chunk.dig("choices", 0, "finish_reason") == true
            puts
          end
        end
      end

      #* 注册<响应内容>事件回调
      agent.on_content do |chunk|
        content = chunk.dig("choices", 0, "delta", "content")
        unless content.nil? || content.empty?
          if reasoning == true
            if reasoned == true
              print_talking_header
              reasoning = false
            end
          else
            if reasoned == false
              print_talking_header
              reasoned = true
            end
          end
          
          print_content(content)
          @output_buffer += content
          
          if chunk.dig("choices", 0, "finish") == true
            puts
          end
        end
      end
      
      #* 注册<工具调用>事件回调
      agent.on_tool_call do |msg|
        case msg[:status]
        when :start
          print_tools_start
        when :end
          print_tools_end
        when :log
          # 处理show_log发送的日志消息
          print_log(msg[:message])
        else
          # 如果需要，可以记录详细的工具调用信息
          SmartResearchCLI.logger.debug("Tool call: #{msg[:content]}") if msg[:content]
        end
      end
      
      #* 注册<Worker调用>事件回调
      agent.on_worker_call do |msg|
        case msg[:status]
        when :start
          print_worker_start(msg[:name])
        when :end
          print_worker_end(msg[:name], msg[:stream])
        end
      end
      
      # 执行agent
      agent.please(input_text)
      
      # 红色提示：agent 调用结束
      puts "\e[31m<<< [Agent End] Agent completed: #{agent_name}\e[0m"
      puts
      @output_buffer
    end

    # 清空对话历史
    def clear_history_messages
      @engine.clear_history_messages
      SmartResearchCLI.logger.info("Conversation history cleared")
    end

    # 根据内容生成对话名称
    def get_conversation_name(content)
      @engine.call_worker(:get_conversation_name, { content: content })
    end

    # 保存对话到文件
    def save_conversation(content, filename = nil)
      filename ||= "conversation_#{Time.now.strftime('%Y%m%d_%H%M%S')}.md"
      filepath = "./conversations/#{filename}"
      
      FileUtils.mkdir_p("./conversations")
      File.write(filepath, content)
      
      SmartResearchCLI.logger.info("Conversation saved to: #{filepath}")
      filepath
    end

    # 从文件加载对话
    def load_conversation(filename)
      filepath = "./conversations/#{filename}"
      raise "Conversation file not found: #{filepath}" unless File.exist?(filepath)
      
      content = File.read(filepath)
      SmartResearchCLI.logger.info("Conversation loaded from: #{filepath}")
      content
    end

    # 列出可用的对话
    def list_conversations
      Dir["./conversations/*.md"].sort.reverse
    end

    # 运行交互式命令行循环
    def run_interactive
      puts "=" * 60
      puts "SmartResearch CLI - Interactive Mode"
      puts "=" * 60
      puts "Commands:"
      puts "  /chat <message>  - Chat mode (smarter_search)"
      puts "  /ask <message>   - Knowledge base mode (smart_kb)"
      puts "  /write <message> - Writing mode (smart_writer)"
      puts "  /clear           - Clear conversation history"
      puts "  /save [name]     - Save conversation"
      puts "  /load <name>     - Load conversation"
      puts "  /list            - List saved conversations"
      puts "  /help            - Show this help"
      puts "  /exit or /quit   - Exit"
      puts "=" * 60
      puts

      conversation_buffer = ""
      
      loop do
        print "> "
        input = $stdin.gets
        break unless input  # 处理EOF
        input = input.chomp.strip
        
        next if input.empty?
        
        case input
        when /^\/exit$/i, /^\/quit$/i
          puts "Goodbye!"
          break
        when /^\/help$/i
          show_help
        when /^\/clear$/i
          clear_history_messages
          conversation_buffer = ""
          puts "✓ History cleared"
        when /^\/save(?:\s+(.+))?$/i
          filename = $1 ? "#{$1}.md" : nil
          filepath = save_conversation(conversation_buffer, filename)
          puts "✓ Saved to: #{filepath}"
        when /^\/load\s+(.+)$/i
          filename = $1
          filename += ".md" unless filename.end_with?(".md")
          begin
            conversation_buffer = load_conversation(filename)
            puts "✓ Loaded: #{filename}"
          rescue => e
            puts "✗ Error: #{e.message}"
          end
        when /^\/list$/i
          conversations = list_conversations
          if conversations.empty?
            puts "No saved conversations found."
          else
            puts "Saved conversations:"
            conversations.each_with_index do |file, idx|
              name = File.basename(file)
              puts "  #{idx + 1}. #{name}"
            end
          end
        when /^\/chat\s+(.+)$/i
          message = $1
          conversation_buffer += "User: #{message}\n"
          puts
          result = call_agent(:smarter_search, message)
          conversation_buffer += "AI: #{result}\n\n"
        when /^\/ask\s+(.+)$/i
          message = $1
          conversation_buffer += "User: #{message}\n"
          puts
          result = call_agent(:smart_kb, message)
          conversation_buffer += "AI: #{result}\n\n"
        when /^\/write\s+(.+)$/i
          message = $1
          conversation_buffer += "User: #{message}\n"
          puts
          result = call_agent(:smart_writer, message)
          conversation_buffer += "AI: #{result}\n\n"
        else
          puts "Unknown command. Type /help for available commands."
        end
        
        puts
      end
    end

    private

    def setup_logger
      FileUtils.mkdir_p(@log_path)
      log_file = "#{@log_path}/cli_app.log"
      SmartResearchCLI.logger = Logger.new(log_file)
      SmartResearchCLI.logger.level = Logger::INFO
    end

    def print_thinking_header
      print "\e[36;1mAI Thinking: \e[0m"
    end

    def print_talking_header
      puts
      print "\e[34mAI Talking: \e[0m"
      puts
    end

    def print_reasoning(text)
      print "\e[36;1m#{text}\e[0m"
    end

    def print_content(text)
      print text
    end

    def print_log(msg)
      puts "\e[36;1m#{msg}\e[0m"
    end

    def print_tools_start
      puts "\e[31m>>> [Tools Start] Calling tools...\e[0m"
    end

    def print_tools_end
      puts "\e[31m<<< [Tools End] Tools execution completed\e[0m"
    end

    def print_worker_start(name)
      puts "\e[31m>>> [Worker Start] Calling worker: #{name}\e[0m"
    end

    def print_worker_end(name, stream = false)
      suffix = stream ? " (stream)" : ""
      puts "\e[31m<<< [Worker End] Worker completed: #{name}#{suffix}\e[0m"
    end

    def show_help
      puts "=" * 60
      puts "Available Commands:"
      puts "  /chat <message>  - Use smarter_search agent for general chat"
      puts "  /ask <message>   - Use smart_kb agent for knowledge base queries"
      puts "  /write <message> - Use smart_writer agent for content creation"
      puts "  /clear           - Clear conversation history"
      puts "  /save [name]     - Save current conversation to file"
      puts "  /load <name>     - Load a saved conversation"
      puts "  /list            - List all saved conversations"
      puts "  /help            - Show this help message"
      puts "  /exit, /quit     - Exit the program"
      puts "=" * 60
    end
  end
end
