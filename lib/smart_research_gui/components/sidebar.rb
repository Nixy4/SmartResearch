# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      class Sidebar
        include Glimmer

        def initialize(app)
          @app = app
        end

        def build(parent)
          parent.instance_eval do
            vertical_box {
              stretchy false
              
              label('功能菜单') {
                stretchy false
              }
              
              button('保存对话') {
                stretchy false
                on_clicked do
                  Dialogs::SaveDialog.show(@app)
                end
              }
              
              button('加载对话') {
                stretchy false
                on_clicked do
                  Dialogs::LoadDialog.show(@app)
                end
              }
              
              button('清空历史') {
                stretchy false
                on_clicked do
                  if msg_box('确认', '确定要清空对话历史吗？')
                    @app.clear_history
                  end
                end
              }
              
              horizontal_separator {
                stretchy false
              }
              
              label('已保存的对话') {
                stretchy false
              }
              
              # TODO: 添加对话列表显示
            }
          end
        end
      end
    end
  end
end
