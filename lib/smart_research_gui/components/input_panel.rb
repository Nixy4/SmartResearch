# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      class InputPanel
        include Glimmer

        def initialize(app)
          @app = app
        end

        def build(parent)
          parent.instance_eval do
            label('输入 (Ctrl+Enter 发送)') {
              stretchy false
            }
            
            multiline_entry {
              stretchy false
              text <=> [@app, :input_text]
            }
            
            horizontal_box {
              stretchy false
              
              button('发送') {
                on_clicked do
                  @app.send_message
                end
              }
              
              button('清空输入') {
                on_clicked do
                  @app.input_text = ""
                end
              }
            }
          end
        end
      end
    end
  end
end
