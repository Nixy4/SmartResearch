SmartPrompt.define_worker :get_conversation_name do
  use "isyscore"
  model "qwen3-next"
  prompt :get_conversation_name, {content: params[:content]}
  send_msg
end