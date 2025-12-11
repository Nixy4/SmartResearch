# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      module Dialogs
        class SaveDialog
          include Glimmer

          def self.show(app)
            new(app).show
          end

          def initialize(app)
            @app = app
            @filename = "conversation_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
          end

          def show
            window('保存对话', 400, 150) {
              margined true
              
              vertical_box {
                label('输入文件名:') {
                  stretchy false
                }
                
                entry {
                  stretchy false
                  text <=> [self, :filename]
                }
                
                horizontal_box {
                  stretchy false
                  
                  button('保存') {
                    on_clicked do
                      save_and_close
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

          attr_accessor :filename

          def save_and_close
            if @filename.strip.empty?
              msg_box('错误', '文件名不能为空')
              return
            end
            
            begin
              filepath = @app.save_conversation(@filename)
              msg_box('成功', "对话已保存到: #{filepath}")
              close_window
            rescue => e
              msg_box('错误', "保存失败: #{e.message}")
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
