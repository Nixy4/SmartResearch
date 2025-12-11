# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Components
      class ChatPanel
        include Glimmer

        def initialize(app)
          @app = app
        end

        def build(parent)
          parent.instance_eval do
            label('对话内容') {
              stretchy false
            }
            
            multiline_entry {
              stretchy true
              read_only true
              text <=> [@app, :content_text]
            }
          end
        end
      end
    end
  end
end
