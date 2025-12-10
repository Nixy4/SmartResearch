SmartAgent.define :smart_search do
  
  #* 缓存原始问题
  question = params[:text]

  #* worker pre_search
  result = call_worker(:pre_search, params, with_tools: true, with_history: true)
  if result.call_tool
    call_tools(result)
    params[:text] = "请输出一份搜索规划"
    result = call_worker(:pre_search, params, with_tools: true, with_history: true)
  end
  
  #* worker smart_search
  params[:text] = result.content #继续使用上一步的内容
  result = call_worker(:smart_search, params, with_tools: true, with_history: true)
  if result.call_tools
    call_tools(result)
  end
  
  #* worker summary
  params[:text] = question 
  result = call_worker(:summary, params, with_tools: false, with_history: true)
  if result.call_tools
    call_tools(result)
    result = call_worker(:summary, params, with_tools: false, with_history: true)
  end

  result.content
end

SmartAgent.build_agent(
  :smart_search,
  tools: [:smart_search],
  mcp_servers: [:opendigger],
)
