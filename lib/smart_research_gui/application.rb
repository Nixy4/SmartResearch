# encoding: utf-8
# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'logger'

module SmartResearch
  module Gui
    class Application
      include Glimmer

      attr_accessor :engine, :agent_engine
      attr_accessor :content_text, :input_text, :conversation_buffer
      attr_accessor :current_agent, :current_mode
      attr_accessor :conversations_list, :main_window
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
        
        # 初始化状态
        @content_text = String.new("", encoding: 'UTF-8')
        @input_text = String.new("", encoding: 'UTF-8')
        @conversation_buffer = String.new("", encoding: 'UTF-8')
        @current_agent = :smarter_search  # 默认使用smarter_search agent
        @current_mode = "交流与探索"
        @conversations_list = []
        
        # 加载对话列表
        refresh_conversations_list
      end

      def launch
        @main_window = Components::MainWindow.new(self)
        @main_window.show
      end

      # 调用agent
      def call_agent(agent_name, input_text)
        reasoning = false
        reasoned = false
        @output_buffer = ""
        
        agent = @agent_engine.agents[agent_name]
        raise "Agent '#{agent_name}' not found" unless agent
        
        SmartResearch::Gui.logger.info("Calling agent: #{agent_name}")
        append_status(">>> [Agent Start] Calling agent: #{agent_name}\n")
        
        # 注册<响应中>事件回调
        agent.on_reasoning do |chunk|
          reasoning_content = chunk.dig("choices", 0, "delta", "reasoning_content")
          unless reasoning_content.nil? || reasoning_content.empty?
            reasoned = true
            if reasoning == false
              append_thinking_header
              reasoning = true
            end
            append_reasoning(reasoning_content)
            
            if chunk.dig("choices", 0, "finish_reason") == true
              append_content("\n")
            end
          end
        end

        # 注册<响应内容>事件回调
        agent.on_content do |chunk|
          content = chunk.dig("choices", 0, "delta", "content")
          unless content.nil? || content.empty?
            if reasoning == true
              if reasoned == true
                append_talking_header
                reasoning = false
              end
            else
              if reasoned == false
                append_talking_header
                reasoned = true
              end
            end
            
            append_content(content)
            @output_buffer += content
            
            if chunk.dig("choices", 0, "finish") == true
              append_content("\n")
            end
          end
        end
        
        # 注册<工具调用>事件回调
        agent.on_tool_call do |msg|
          case msg[:status]
          when :start
            append_tool_status(">>> [Tools Start] Calling tools...\n")
          when :end
            append_tool_status("<<< [Tools End] Tools execution completed\n")
          when :log
            append_tool_status("#{msg[:message]}\n")
          else
            SmartResearch::Gui.logger.debug("Tool call: #{msg[:content]}") if msg[:content]
          end
        end
        
        # 注册<Worker调用>事件回调
        agent.on_worker_call do |msg|
          case msg[:status]
          when :start
            append_worker_status(">>> [Worker Start] Calling worker: #{msg[:name]}\n")
          when :end
            suffix = msg[:stream] ? " (stream)" : ""
            append_worker_status("<<< [Worker End] Worker completed: #{msg[:name]}#{suffix}\n")
          end
        end
        
        # 执行agent
        agent.please(input_text)
        
        append_status("<<< [Agent End] Agent completed: #{agent_name}\n\n")
        @output_buffer
      end

      # 发送消息
      def send_message
        input = @input_text.strip
        return if input.empty?
        
        # 显示用户输入
        append_user_message("用户: #{input}\n\n")
        @conversation_buffer += "用户: #{input}\n"
        
        # 清空输入框
        self.input_text = ""
        
        # 调用AI agent
        result = call_agent(@current_agent, input)
        @conversation_buffer += "AI: #{result}\n\n"
      end

      # 切换模式
      def switch_mode(mode_name)
        case mode_name
        when "交流与探索"
          @current_agent = :smarter_search
          @current_mode = "交流与探索"
        when "整理知识库"
          @current_agent = :smart_kb
          @current_mode = "整理知识库"
        when "创作与输出"
          @current_agent = :smart_writer
          @current_mode = "创作与输出"
        end
        SmartResearch::Gui.logger.info("Switched to mode: #{@current_mode}")
      end

      # 清空历史
      def clear_history
        @engine.clear_history_messages
        self.content_text = ""
        self.conversation_buffer = ""
        SmartResearch::Gui.logger.info("Conversation history cleared")
      end

      # 保存对话
      def save_conversation(filename = nil)
        filename ||= "conversation_#{Time.now.strftime('%Y%m%d_%H%M%S')}.md"
        filename += ".md" unless filename.end_with?(".md")
        filepath = "./conversations/#{filename}"
        
        FileUtils.mkdir_p("./conversations")
        File.write(filepath, @conversation_buffer)
        
        SmartResearch::Gui.logger.info("Conversation saved to: #{filepath}")
        refresh_conversations_list
        filepath
      end

      # 加载对话
      def load_conversation(filename)
        filepath = "./conversations/#{filename}"
        raise "Conversation file not found: #{filepath}" unless File.exist?(filepath)
        
        content = File.read(filepath)
        self.content_text = content
        self.conversation_buffer = content
        
        SmartResearch::Gui.logger.info("Conversation loaded from: #{filepath}")
        content
      end

      # 刷新对话列表
      def refresh_conversations_list
        @conversations_list = Dir["./conversations/*.md"].map { |f| File.basename(f) }.sort.reverse
      end

      # 文本追加方法
      def append_content(text)
        utf8_text = text.to_s.dup.force_encoding('UTF-8')
        self.content_text = @content_text + utf8_text
        print utf8_text  # 同时输出到终端
        $stdout.flush
      end

      def append_user_message(text)
        append_content("[用户] #{text}")
      end

      def append_thinking_header
        append_content("[AI 思考中] ")
      end

      def append_talking_header
        append_content("\n[AI 回复] \n")
      end

      def append_reasoning(text)
        append_content(text)
      end

      def append_tool_status(text)
        append_content("[工具] #{text}")
      end

      def append_worker_status(text)
        append_content("[Worker] #{text}")
      end

      def append_status(text)
        append_content("[状态] #{text}")
      end

      # 显示帮助信息
      def show_help
        help_text = <<~HELP
          SmartResearch GUI 帮助
          
          模式说明:
          - 交流与探索: 使用 smarter_search agent 进行一般对话和搜索
          - 整理知识库: 使用 smart_kb agent 整理和管理知识
          - 创作与输出: 使用 smart_writer agent 进行写作和创作
          
          操作说明:
          - 在输入框中输入问题或指令
          - 点击"发送"按钮或按 Ctrl+Enter 发送消息
          - 使用侧边栏功能按钮管理对话
        HELP
        
        # 使用 Glimmer DSL 的 msg_box 方法
        if @main_window && @main_window.window_proxy
          @main_window.window_proxy.msg_box('帮助', help_text)
        else
          SmartResearch::Gui.logger.warn('Main window not initialized, cannot show help dialog')
        end
      end

      # 清理资源
      def cleanup
        SmartResearch::Gui.logger.info('Cleaning up resources...')
        
        # 关闭数据库连接
        if defined?(ActiveRecord::Base) && ActiveRecord::Base.connected?
          ActiveRecord::Base.connection.close
          SmartResearch::Gui.logger.info('Database connection closed')
        end
        
        SmartResearch::Gui.logger.info('Cleanup completed')
      end

      private

      def setup_logger
        FileUtils.mkdir_p(@log_path)
        log_file = "#{@log_path}/gui.log"
        SmartResearch::Gui.logger = Logger.new(log_file)
        SmartResearch::Gui.logger.level = Logger::INFO
      end
    end
  end
end
