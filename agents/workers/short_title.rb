SmartPrompt.define_worker :short_title do
  use "isyscore"
  model "qwen3-next"
  prompt :short_title, {text: params[:text]}
  send_msg
end