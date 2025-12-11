# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      class Toolbar
        include Glimmer

        def initialize(app)
          @app = app
        end

        def build(parent)
          parent.instance_eval do
            horizontal_box {
              stretchy false
              
              label('模式切换:') {
                stretchy false
              }
              
              combobox {
                stretchy false
                items ['交流与探索', '整理知识库', '创作与输出']
                selected 0
                
                on_selected do |item|
                  @app.switch_mode(item)
                end
              }
              
              button('帮助') {
                stretchy false
                on_clicked do
                  @app.show_help
                end
              }
            }
          end
        end

        private

        def show_help
          help_text = <<~HELP
            SmartResearch GUI 帮助
            
            模式说明:
            - 交流与探索: 使用 smarter_search agent 进行一般对话和搜索
            - 整理知识库: 使用 smart_kb agent 整理和查询知识库
            - 创作与输出: 使用 smart_writer agent 进行内容创作
            
            快捷键:
            - Ctrl+Enter: 发送消息
            
            功能:
            - 保存对话: 将当前对话保存到文件
            - 加载对话: 从文件加载历史对话
            - 清空历史: 清空当前对话内容
          HELP
          
          msg_box('帮助', help_text)
        end
      end
    end
  end
end
