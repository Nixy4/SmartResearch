# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      module Dialogs
        class SettingsDialog
          include Glimmer

          def self.show(app)
            new(app).show
          end

          def initialize(app)
            @app = app
          end

          def show
            window('设置', 600, 400) {
              margined true
              
              vertical_box {
                label('设置') {
                  stretchy false
                }
                
                # TODO: 添加设置选项
                label('功能开发中...') {
                  stretchy false
                }
                
                horizontal_box {
                  stretchy false
                  
                  button('确定') {
                    on_clicked do
                      close_window
                    end
                  }
                }
              }
            }.show
          end

          private

          def close_window
            # LibUI 窗口关闭逻辑
          end
        end
      end
    end
  end
end
