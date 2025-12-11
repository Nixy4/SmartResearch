# encoding: utf-8
# frozen_string_literal: true

module SmartResearch
  module Gui
    module Helpers
      class OutputFormatter
        # 格式化用户消息
        def self.format_user_message(text)
          "[用户] #{text}\n"
        end

        # 格式化AI思考
        def self.format_thinking_header
          "[AI 思考中] "
        end

        # 格式化AI回复
        def self.format_talking_header
          "\n[AI 回复] \n"
        end

        # 格式化工具调用状态
        def self.format_tool_status(text)
          "[工具] #{text}"
        end

        # 格式化Worker状态
        def self.format_worker_status(text)
          "[Worker] #{text}"
        end

        # 格式化系统状态
        def self.format_status(text)
          "[状态] #{text}"
        end

        # 移除ANSI颜色代码
        def self.strip_ansi_colors(text)
          text.gsub(/\e\[([0-9;]+)m/, '')
        end

        # 格式化时间戳
        def self.format_timestamp
          Time.now.strftime('[%H:%M:%S]')
        end
      end
    end
  end
end
