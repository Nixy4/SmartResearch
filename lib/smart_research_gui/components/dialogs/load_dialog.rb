# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      module Dialogs
        class LoadDialog
          include Glimmer

          def self.show(app)
            new(app).show
          end

          def initialize(app)
            @app = app
            @selected_index = 0
          end

          def show
            conversations = @app.conversations_list
            
            if conversations.empty?
              msg_box('提示', '没有找到已保存的对话')
              return
            end
            
            window('加载对话', 500, 400) {
              margined true
              
              vertical_box {
                label('选择要加载的对话:') {
                  stretchy false
                }
                
                combobox {
                  stretchy false
                  items conversations
                  selected <=> [self, :selected_index]
                }
                
                horizontal_box {
                  stretchy false
                  
                  button('加载') {
                    on_clicked do
                      load_and_close(conversations)
                    end
                  }
                  
                  button('取消') {
                    on_clicked do
                      close_window
                    end
                  }
                }
              }
            }.show
          end

          private

          attr_accessor :selected_index

          def load_and_close(conversations)
            filename = conversations[@selected_index]
            
            begin
              @app.load_conversation(filename)
              msg_box('成功', "对话已加载: #{filename}")
              close_window
            rescue => e
              msg_box('错误', "加载失败: #{e.message}")
            end
          end

          def close_window
            # LibUI 窗口关闭逻辑
          end
        end
      end
    end
  end
end
