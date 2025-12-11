#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

# GUI版本启动脚本
require 'logger'
require 'smart_prompt'
require 'smart_agent'
require 'glimmer-dsl-libui'
require 'fileutils'

# 加载数据库和模型
require_relative 'database'

# 加载补丁以修复 smart_agent 的问题
require_relative 'smart_agent_patch'

# 定义SmartResearch模块
module SmartResearch
  module Gui
    def self.logger=(logger)
      @logger = logger
    end

    def self.logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = 'SmartResearch::Gui'
      end
    end
  end
end

# 加载所有GUI组件
require_relative 'smart_research_gui/application'
require_relative 'smart_research_gui/components/main_window'
require_relative 'smart_research_gui/components/chat_panel'
require_relative 'smart_research_gui/components/input_panel'
require_relative 'smart_research_gui/components/sidebar'
require_relative 'smart_research_gui/components/toolbar'
require_relative 'smart_research_gui/components/dialogs/save_dialog'
require_relative 'smart_research_gui/components/dialogs/load_dialog'
require_relative 'smart_research_gui/components/dialogs/settings_dialog'
require_relative 'smart_research_gui/helpers/output_formatter'

# 启动应用
module SmartResearch
  module Gui
    class CLI
      def self.start(argv = [])
        app = Application.new
        app.launch
      end
    end
  end
end
