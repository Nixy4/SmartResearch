# 简单的 Ruby HTTP 服务器
require 'bundler/setup'
require 'webrick'
require 'json'
require 'logger'
require 'fileutils'

# 加载SmartResearch库
require_relative '../lib/smart_research_cli'

current_dir = File.dirname(__FILE__)
config_dir = current_dir + '/../config'
log_dir = current_dir + '/../log'
pid_file_path = current_dir + '/mcp_server.pid'

# 设置日志
Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
log_file = File.join(log_dir, 'server.log')
file_logger = Logger.new(log_file, 'daily')
file_logger.level = Logger::INFO
console_logger = Logger.new(STDOUT)
console_logger.level = Logger::INFO

# 多路日志器
class MultiLogger
	def initialize(*targets)
		@targets = targets
	end
	def info(msg)
		@targets.each { |t| t.info(msg) }
	end
	def error(msg)
		@targets.each { |t| t.error(msg) }
	end
	def warn(msg)
		@targets.each { |t| t.warn(msg) }
	end
end

LOGGER = MultiLogger.new(file_logger, console_logger)

# 守护进程化
if ARGV.include?('--daemon') || ARGV.include?('-d')
	Process.daemon(true, true)
	LOGGER.info("MCP服务器以守护进程模式启动，PID: #{Process.pid}")
	
	# 将PID写入文件
	pid_file = pid_file_path
	File.write(pid_file, Process.pid)
end

# 初始化SmartResearch应用
begin
	app = SmartResearchCLI::Application.new(
		config_path: config_dir,
		log_path: log_dir
	)
	LOGGER.info("SmartResearch应用初始化成功")
rescue => e
	LOGGER.error("SmartResearch应用初始化失败: #{e.message}")
	LOGGER.error(e.backtrace.join("\n"))
	app = nil
end

server = WEBrick::HTTPServer.new(:Port => 8080)

# 根路径
server.mount_proc '/' do |req, res|
	LOGGER.info("根路径请求: #{req.request_method}")
	res.body = 'MCP Server 已启动。'
end

# MCP工具调用接口 - 支持chat/ask/write三种模式
server.mount_proc '/mcp/tool_call' do |req, res|
	LOGGER.info("/mcp/tool_call 请求: #{req.request_method.to_s.force_encoding('UTF-8')} #{req.body.to_s.force_encoding('UTF-8')}")
	if req.request_method == 'POST'
		begin
			data = JSON.parse(req.body)
			mode = data['mode']
			message = data['message']
			
			# 验证参数
			raise "参数 'message' 不能为空" if message.nil? || message.empty?
			raise "不支持的模式: #{mode}" unless ['chat', 'ask', 'write'].include?(mode)
			
			# 根据模式选择agent
			agent_name = case mode
			when 'chat'
				'smarter_search'
			when 'ask'
				'smart_kb'
			when 'write'
				'smart_writer'
			end
			
			LOGGER.info("模式: #{mode}, Agent: #{agent_name}, 消息: #{message}")
			
			# 实际调用SmartResearch应用
			agent_result = if app
				begin
					app.call_agent(agent_name.to_sym, message)
				rescue => e
					LOGGER.error("Agent调用失败: #{e.message}")
					"错误: #{e.message}"
				end
			else
				"SmartResearch应用未初始化"
			end
			
			result = {
				'id' => 'tool_call_' + rand(100000).to_s,
				'object' => 'tool_call',
				'created' => Time.now.to_i,
				'mode' => mode,
				'agent' => agent_name,
				'message' => message,
				'status' => 'success',
				'result' => agent_result
			}
			
			res['Content-Type'] = 'application/json'
			res.body = result.to_json.force_encoding('UTF-8')
			LOGGER.info("/mcp/tool_call 响应: #{result.to_s.force_encoding('UTF-8')}")
		rescue => e
			res.status = 400
			res.body = { 'error' => e.message }.to_json.force_encoding('UTF-8')
			LOGGER.error("/mcp/tool_call 错误: #{e.message.to_s.force_encoding('UTF-8')}")
		end
	else
		res.status = 405
		res.body = { 'error' => '仅支持POST请求' }.to_json.force_encoding('UTF-8')
		LOGGER.warn("/mcp/tool_call 非法请求: #{req.request_method.to_s.force_encoding('UTF-8')}")
	end
end

trap('INT') { 
	server.shutdown
	# 删除PID文件
	pid_file = pid_file_path
	File.delete(pid_file) if File.exist?(pid_file)
}

trap('TERM') {
	server.shutdown
	# 删除PID文件
	pid_file = pid_file_path
	File.delete(pid_file) if File.exist?(pid_file)
}

server.start
