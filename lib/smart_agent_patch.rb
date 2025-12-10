# Monkey patch for SmartAgent::AgentContext to fix stream_response bug
# This fixes the issue where smart_agent-0.2.2 calls non-existent stream_response method

module SmartAgent
  # 扩展 Agent 类以支持 worker 回调
  class Agent
    attr_accessor :worker_call_proc
    
    def on_worker_call(&block)
      @worker_call_proc = block
    end
    
    def processor(type)
      case type
      when :reasoning
        @reasoning_event_proc
      when :content
        @content_event_proc
      when :tool_call
        @tool_call_proc
      when :worker
        @worker_call_proc
      else
        nil
      end
    end
  end
  
  class AgentContext
    # 添加show_log方法
    def show_log(message)
      # 通过tool_call事件处理器发送日志消息
      if @agent.processor(:tool_call)
        @agent.processor(:tool_call).call({ status: :log, message: message })
      end
      SmartAgent.logger.info(message)
    end
    
    # 增强的 JSON 解析方法
    def safe_parse(input)
      return input if input.is_a?(Hash) || input.is_a?(Array)
      return {} if input.nil? || input.strip.empty?
      
      original_input = input.dup
      cleaned = input.strip
      
      # 移除外层引号
      if cleaned.start_with?('"') && cleaned.end_with?('"')
        cleaned = cleaned[1...-1]
      end
      
      begin
        return JSON.parse(cleaned)
      rescue JSON::ParserError => e
        SmartAgent.logger.warn("JSON parse failed: #{e.message}")
        SmartAgent.logger.warn("Original: #{original_input}")
        SmartAgent.logger.warn("Cleaned: #{cleaned}")
        
        # 尝试修复常见的 JSON 错误
        # 1. 移除末尾多余的逗号
        fixed = cleaned.gsub(/,(\s*[}\]])/, '\1')
        # 2. 修复单引号为双引号
        fixed = fixed.gsub("'", '"')
        # 3. 确保键名有引号
        fixed = fixed.gsub(/(\w+)(\s*:)/, '"\1"\2')
        
        begin
          return JSON.parse(fixed)
        rescue JSON::ParserError
          SmartAgent.logger.error("Failed to fix JSON, returning empty hash")
          return {}
        end
      end
    end
    
    # 重写 call_tools 方法以确保参数正确解析
    def call_tools(result)
      @agent.processor(:tool_call).call({ :status => :start }) if @agent.processor(:tool_call)
      SmartAgent.logger.info("call tools: " + result.to_s)
      results = []
      
      result.call_tools.each do |tool|
        tool_call_id = tool["id"]
        tool_name = tool["function"]["name"]&.to_sym
        
        unless tool_name
          SmartAgent.logger.error("Tool name is nil, skipping tool call")
          next
        end
        
        # 确保参数是正确的格式
        arguments = tool["function"]["arguments"]
        params = safe_parse(arguments)
        
        # 如果解析后不是 Hash,记录错误并跳过
        unless params.is_a?(Hash)
          SmartAgent.logger.error("Parsed params is not a Hash: #{params.class}, value: #{params}")
          @agent.processor(:tool_call).call({ :content => "Error: Invalid tool parameters\n" }) if @agent.processor(:tool_call)
          next
        end
        
        SmartAgent.logger.info("Calling tool: #{tool_name} with params: #{params.inspect}")
        
        if Tool.find_tool(tool_name)
          begin
            tool_result = Tool.find_tool(tool_name).call(params, @agent)
            if tool_result
              @agent.processor(:tool_call).call({ :content => tool_result })
              SmartAgent.prompt_engine.history_messages << { "role" => "assistant", "content" => "", "tool_calls" => [tool] }
              SmartAgent.prompt_engine.history_messages << { "role" => "tool", "tool_call_id" => tool_call_id, "content" => tool_result.to_s.force_encoding("UTF-8") }
              results << tool_result
            end
          rescue => e
            SmartAgent.logger.error("Tool execution error: #{e.message}")
            @agent.processor(:tool_call).call({ :content => "Error: #{e.message}\n" }) if @agent.processor(:tool_call)
          end
        end
        
        if server_name = MCPClient.find_server_by_tool_name(tool_name)
          begin
            tool_result = MCPClient.new(server_name).call(tool_name, params, @agent)
            if tool_result
              @agent.processor(:tool_call).call({ :content => tool_result })
              SmartAgent.prompt_engine.history_messages << { "role" => "assistant", "content" => "", "tool_calls" => [tool] }
              SmartAgent.prompt_engine.history_messages << { "role" => "tool", "tool_call_id" => tool_call_id, "content" => tool_result.to_s }
              results << tool_result
            end
          rescue => e
            SmartAgent.logger.error("MCP tool execution error: #{e.message}")
            @agent.processor(:tool_call).call({ :content => "Error: #{e.message}\n" }) if @agent.processor(:tool_call)
          end
        end
        
        @agent.processor(:tool_call).call({ :content => " ... done\n" }) if @agent.processor(:tool_call)
      end
      
      @agent.processor(:tool_call).call({ :status => :end }) if @agent.processor(:tool_call)
      return results
    end
    
    # 重写call_worker方法以修复stream_response bug
    def call_worker(name, params, with_tools: true, with_history: false)
      @agent.processor(:worker).call({ :status => :start, :name => name }) if @agent.processor(:worker)
      SmartAgent.logger.info("Call Worker name is: #{name}")
      SmartAgent.logger.info("Call Worker params is: #{params}")
      
      if with_tools
        simple_tools = []
        if @agent.tools
          simple_tools = @agent.tools.map { |tool_name| Tool.find_tool(tool_name).to_json }
        end
        if @agent.servers
          mcp_tools = @agent.servers.map { |mcp_name| MCPClient.new(mcp_name).to_json }
          mcp_tools.each do |tools|
            tools["tools"].each do |tool|
              simple_tools << tool
            end
          end
        end
        params[:tools] = simple_tools
      end
      
      params[:with_history] = with_history
      ret = nil
      result = nil
      
      # 检查是否有内容处理器，如果有则使用流式输出
      has_content_processor = @agent.processor(:content) || @agent.processor(:reasoning)
      
      if has_content_processor
        # 修复：在流式调用时收集完整响应
        collected_content = ""
        collected_reasoning = ""
        collected_tool_calls = []
        
        SmartAgent.prompt_engine.call_worker_by_stream(name, params) do |chunk, _bytesize|
          if chunk.dig("choices", 0, "delta", "reasoning_content")
            collected_reasoning += chunk.dig("choices", 0, "delta", "reasoning_content")
            @agent.processor(:reasoning).call(chunk) if @agent.processor(:reasoning)
          end
          if chunk.dig("choices", 0, "delta", "content")
            collected_content += chunk.dig("choices", 0, "delta", "content")
            @agent.processor(:content).call(chunk) if @agent.processor(:content)
          end
          # 收集工具调用
          if chunk.dig("choices", 0, "delta", "tool_calls")
            delta_tools = chunk.dig("choices", 0, "delta", "tool_calls")
            delta_tools.each do |delta_tool|
              index = delta_tool["index"]
              
              # 确保有对应索引的位置
              collected_tool_calls[index] ||= {
                "id" => "",
                "type" => "function",
                "function" => {
                  "name" => "",
                  "arguments" => ""
                }
              }
              
              # 累积各个字段
              if delta_tool["id"]
                collected_tool_calls[index]["id"] = delta_tool["id"]
              end
              if delta_tool["function"]
                if delta_tool["function"]["name"]
                  collected_tool_calls[index]["function"]["name"] = delta_tool["function"]["name"]
                end
                if delta_tool["function"]["arguments"]
                  collected_tool_calls[index]["function"]["arguments"] += delta_tool["function"]["arguments"]
                end
              end
            end
          end
        end
        
        # 构建完整的响应对象
        message = {
          "content" => collected_content,
          "role" => "assistant"
        }
        message["tool_calls"] = collected_tool_calls.compact unless collected_tool_calls.empty?
        
        result = {
          "choices" => [{ "message" => message }]
        }
        @agent.processor(:worker).call({ :status => :end, :name => name, :stream => true }) if @agent.processor(:worker)
      else
        result = SmartAgent.prompt_engine.call_worker(name, params)
        @agent.processor(:worker).call({ :status => :end, :name => name, :stream => false }) if @agent.processor(:worker)
      end
      
      ret = SmartAgent::Result.new(result)
      ret
    end
  end
end
