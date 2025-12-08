require "smart_prompt"
require "smart_agent"
require "colorize"
require_relative "./database"

module SmartResearch
  class SimpleCLI
    attr_reader :engine, :agent_engine

    def initialize
      puts "🚀 初始化 SmartResearch...".colorize(:green)
      
      # 初始化数据库
      Database.setup
      
      # 初始化AI引擎
      @engine = SmartPrompt::Engine.new("./config/llm_config.yml")
      @agent_engine = SmartAgent::Engine.new("./config/agent.yml")
      
      # 为AgentContext添加show_log方法
      SmartAgent::AgentContext.class_eval do
        def show_log(message)
          puts message if message && !message.empty?
          message
        end
      end
      
      puts "✅ SmartResearch 已准备就绪！".colorize(:green)
      puts ""
    end

    def self.start(argv)
      cli = new
      cli.run
    end

    def run
      show_help
      
      loop do
        print "\n> ".colorize(:cyan)
        input = gets
        break unless input  # 处理Ctrl+D等情况
        input = input.chomp.strip
        
        case input.downcase
        when 'quit', 'exit', 'q'
          puts "👋 再见！".colorize(:yellow)
          break
        when 'help', 'h'
          show_help
        when 'chat', 'c'
          puts "进入聊天模式，输入 'back' 返回主菜单".colorize(:blue)
          chat_mode
        when 'search', 's'
          puts "进入搜索模式，输入 'back' 返回主菜单".colorize(:blue)
          search_mode
        when 'kb', 'knowledge'
          puts "进入知识库模式，输入 'back' 返回主菜单".colorize(:blue)
          knowledge_mode
        when 'write', 'w'
          puts "进入写作模式，输入 'back' 返回主菜单".colorize(:blue)
          write_mode
        when 'clear'
          system('clear') || system('cls')
          show_help
        else
          if input.empty?
            next
          else
            puts "❓ 未知命令: #{input}".colorize(:red)
            puts "输入 'help' 查看可用命令".colorize(:yellow)
          end
        end
      end
    end

    private

    def show_help
      puts "=" * 50
      puts "🧠 SmartResearch - 智能研究助手".colorize(:magenta).bold
      puts "=" * 50
      puts "可用命令:".colorize(:green).bold
      puts "  chat, c       - 智能对话模式"
      puts "  search, s     - 智能搜索模式" 
      puts "  kb, knowledge - 知识库管理"
      puts "  write, w      - 智能写作模式"
      puts "  clear         - 清屏"
      puts "  help, h       - 显示帮助"
      puts "  quit, exit, q - 退出程序"
      puts "=" * 50
    end

    def chat_mode
      while true
        print "\n💬 聊天> ".colorize(:blue)
        input = gets
        break unless input  # 处理Ctrl+D等情况
        input = input.chomp.strip
        
        break if input.downcase == 'back'
        next if input.empty?
        
        puts "\n🤖 AI正在思考...".colorize(:yellow)
        
        begin
          # 调用智能搜索代理
          result = call_agent_simple(:smarter_search, input)
          puts "\n🤖 回答:".colorize(:green).bold
          puts result
        rescue => e
          puts "❌ 出错了: #{e.message}".colorize(:red)
        end
      end
      
      puts "返回主菜单".colorize(:blue)
    end

    def search_mode
      while true
        print "\n🔍 搜索> ".colorize(:cyan)
        input = gets
        break unless input  # 处理Ctrl+D等情况
        input = input.chomp.strip
        
        break if input.downcase == 'back'
        next if input.empty?
        
        puts "\n🔍 正在搜索...".colorize(:yellow)
        
        begin
          result = call_agent_simple(:smart_search, input)
          puts "\n📋 搜索结果:".colorize(:green).bold
          puts result
        rescue => e
          puts "❌ 搜索出错: #{e.message}".colorize(:red)
        end
      end
      
      puts "返回主菜单".colorize(:blue)
    end

    def knowledge_mode
      puts "\n📚 知识库操作指令:".colorize(:green)
      puts "  list - 列出研究主题"
      puts "  add <主题> - 添加研究主题"
      puts "  search <关键词> - 搜索知识库"
      
      while true
        print "\n📚 知识库> ".colorize(:blue)
        input = gets
        break unless input  # 处理Ctrl+D等情况
        input = input.chomp.strip
        
        break if input.downcase == 'back'
        next if input.empty?
        
        begin
          result = call_agent_simple(:smart_kb, input)
          puts "\n📋 结果:".colorize(:green).bold
          puts result
        rescue => e
          puts "❌ 操作出错: #{e.message}".colorize(:red)
        end
      end
      
      puts "返回主菜单".colorize(:blue)
    end

    def write_mode
      puts "\n✍️ 写作指令:".colorize(:green)
      puts "  outline <主题> - 生成文章提纲"
      puts "  write_all - 根据提纲生成完整文章"
      puts "  help - 查看更多写作指令"
      
      while true
        print "\n✍️ 写作> ".colorize(:blue)
        input = gets
        break unless input  # 处理Ctrl+D等情况
        input = input.chomp.strip
        
        break if input.downcase == 'back'
        next if input.empty?
        
        puts "\n✍️ 正在处理...".colorize(:yellow)
        
        begin
          result = call_agent_simple(:smart_writer, input)
          puts "\n📝 结果:".colorize(:green).bold
          puts result
        rescue => e
          puts "❌ 写作出错: #{e.message}".colorize(:red)
        end
      end
      
      puts "返回主菜单".colorize(:blue)
    end

    def call_agent_simple(agent_name, input_text)
      puts "🔄 调用代理: #{agent_name}".colorize(:cyan)
      
      begin
        agent = @agent_engine.agents[agent_name]
        unless agent
          return "❌ 代理 #{agent_name} 不存在"
        end

        # 现在使用isyscore配置，有硬编码的API密钥，直接跳过检查

        # 不使用流式回调，直接调用
        result = agent.please(input_text)
        
        puts "✅ 完成".colorize(:green)
        return result || "处理完成"
        
      rescue => e
        puts "❌ 出错了: #{e.message}".colorize(:red)
        # 如果是API相关错误，给出友好提示
        if e.message.include?("401") || e.message.include?("authentication")
          return "API认证失败，请设置环境变量 APIKey、DSKEY 或 ALIKEY"
        end
        return "处理失败: #{e.message}"
      end
    end
  end
end