SmartPrompt.define_worker :summarize_search_results do
  use "isyscore"
  model "qwen3-next"
  prompt :summarize_results, { ask: params[:ask], text: params[:text] }
  send_msg
end
