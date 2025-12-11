#!/usr/bin/env ruby
require 'glimmer-dsl-libui'

include Glimmer

window('Glimmer LibUI Demo', 600, 400) {
  margined true
  vertical_box {
    label('欢迎体验 Glimmer LibUI') {
      stretchy false
    }
    horizontal_separator
    horizontal_box {
      label('输入内容:')
      @input = entry {
        on_changed do
          @status.text = "当前输入: #{@input.text}"
        end
      }
      button('弹窗') {
        on_clicked do
          msg_box('提示', @input.text.empty? ? '你好，世界！' : @input.text)
        end
      }
      button('清空') {
        on_clicked do
          @input.text = ''
        end
      }
    }
    horizontal_separator
    label('列表:')
    @items = [['Ruby'], ['Python'], ['Go'], ['Rust']]
    table {
      text_column('编程语言')
      cell_rows @items
      on_changed do |row|
        @status.text = "选中: #{@items[row][0]}"
      end
    }
    horizontal_box {
      button('添加到列表') {
        on_clicked do
          if @input.text.strip.empty?
            msg_box_error('错误', '请输入内容')
          else
            @items << [@input.text.strip]
            @input.text = ''
            @status.text = "已添加: #{@items.last[0]}"
          end
        end
      }
      button('删除选中') {
        on_clicked do
          if @items.empty?
            msg_box_error('错误', '列表为空')
          else
            selected = @status.text.sub('选中: ', '')
            idx = @items.index { |item| item[0] == selected }
            if idx
              @items.delete_at(idx)
              @status.text = '已删除选中项'
            else
              msg_box_error('错误', '请先选中一项')
            end
          end
        end
      }
      button('清空列表') {
        on_clicked do
          @items.clear
          @status.text = '列表已清空'
        end
      }
    }
    horizontal_separator
    @status = label('状态栏: 准备就绪')
  }
  on_closing do
    puts '窗口已关闭'
  end
}.show
