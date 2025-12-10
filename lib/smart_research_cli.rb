require "smart_prompt"
require "smart_agent"
require "fileutils"
require "logger"

require_relative "./database"
require_relative "./smart_agent_patch"
require_relative "./smart_research_cli/application"

module SmartResearchCLI
  class CLI
    def self.start(argv)
      command = argv[0]
      
      case command
      when "interactive", "i", nil
        # Interactive mode
        app = Application.new
        app.run_interactive
      when "chat"
        # Single chat command
        message = argv[1..-1].join(" ")
        if message.empty?
          puts "Usage: smart_research_cli chat <message>"
          exit 1
        end
        app = Application.new
        app.call_agent(:smarter_search, message)
      when "ask"
        # Single ask command
        message = argv[1..-1].join(" ")
        if message.empty?
          puts "Usage: smart_research_cli ask <message>"
          exit 1
        end
        app = Application.new
        app.call_agent(:smart_kb, message)
      when "write"
        # Single write command
        message = argv[1..-1].join(" ")
        if message.empty?
          puts "Usage: smart_research_cli write <message>"
          exit 1
        end
        app = Application.new
        app.call_agent(:smart_writer, message)
      when "help", "-h", "--help"
        show_help
      else
        puts "Unknown command: #{command}"
        puts "Run 'smart_research_cli help' for usage information"
        exit 1
      end
    end

    def self.show_help
      puts <<~HELP
        SmartResearch CLI - Command Line Interface
        
        Usage:
          smart_research_cli [command] [arguments]
        
        Commands:
          interactive, i      Start interactive mode (default)
          chat <message>      Use smarter_search agent for general chat
          ask <message>       Use smart_kb agent for knowledge base queries
          write <message>     Use smart_writer agent for content creation
          help, -h, --help    Show this help message
        
        Examples:
          # Start interactive mode
          smart_research_cli
          smart_research_cli interactive
          
          # Single command mode
          smart_research_cli chat "Tell me about Ruby programming"
          smart_research_cli ask "Search my knowledge base for ML papers"
          smart_research_cli write "Write an article about AI"
        
        Interactive Mode Commands:
          /chat <message>     Chat with AI
          /ask <message>      Query knowledge base
          /write <message>    Generate content
          /clear              Clear conversation history
          /save [name]        Save conversation
          /load <name>        Load conversation
          /list               List saved conversations
          /help               Show help
          /exit, /quit        Exit
      HELP
    end
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger ||= Logger.new($stdout).tap do |log|
      log.progname = self.name
      log.level = Logger::INFO
    end
  end
end
