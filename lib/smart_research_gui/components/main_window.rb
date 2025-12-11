# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      class MainWindow
        include Glimmer

        attr_reader :window_proxy

        def initialize(app)
          @app = app
        end

        def show
          @window_proxy = window('SmartResearch', 1200, 800) {
            margined true
            
            vertical_box {
              # 工具栏
              Toolbar.new(@app).build(self)
              
              horizontal_separator {
                stretchy false
              }
              
              # 主内容区域
              horizontal_box {
                stretchy true
                
                # 侧边栏
                Sidebar.new(@app).build(self)
                
                vertical_separator {
                  stretchy false
                }
                
                # 中间区域：聊天面板 + 输入面板
                vertical_box {
                  stretchy true
                  
                  # 聊天面板
                  ChatPanel.new(@app).build(self)
                  
                  horizontal_separator {
                    stretchy false
                  }
                  
                  # 输入面板
                  InputPanel.new(@app).build(self)
                }
              }
              
              horizontal_separator {
                stretchy false
              }
              
              # 状态栏
              label {
                stretchy false
                text <= [@app, :current_mode, after_read: ->(val) { "当前模式: #{val}" }]
              }
            }
            
            on_closing do
              SmartResearch::Gui.logger.info('Application closing')
              @app.cleanup
              ::LibUI.quit
              0
            end
          }.show
        end
      end
    end
  end
end
