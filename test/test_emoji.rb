#!/usr/bin/env ruby
# encoding: utf-8

require 'glimmer-dsl-libui'

include Glimmer

window('Emoji Test', 400, 300) {
  margined true
  
  vertical_box {
    label('测试 Emoji 显示') {
      stretchy false
    }
    
    @entry = multiline_entry {
      stretchy true
      text "Hello 👋\nWorld 🌍\nEmoji 😀🎉🚀\n中文测试"
    }
    
    button('添加更多Emoji') {
      stretchy false
      on_clicked do
        current = @entry.text
        @entry.text = current + "\n新增: 🎨🎭🎪🎬🎮"
      end
    }
  }
}.show
