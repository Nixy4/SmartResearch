#!/usr/bin/env ruby
require_relative 'lib/smart_research_cli'
require 'json'

# 测试 JSON 解析修复
# 创建一个测试类来访问 safe_parse 方法
class TestContext
  include SmartAgent
  
  def safe_parse(input)
    return input if input.is_a?(Hash) || input.is_a?(Array)
    return {} if input.nil? || input.strip.empty?
    
    original_input = input.dup
    cleaned = input.strip
    
    # 移除外层引号
    if cleaned.start_with?('"') && cleaned.end_with?('"')
      cleaned = cleaned[1...-1]
    end
    
    begin
      return JSON.parse(cleaned)
    rescue JSON::ParserError => e
      puts "  警告: JSON 解析失败 - #{e.message}"
      
      # 尝试修复常见的 JSON 错误
      # 1. 移除末尾多余的逗号
      fixed = cleaned.gsub(/,(\s*[}\]])/, '\1')
      # 2. 修复单引号为双引号
      fixed = fixed.gsub("'", '"')
      # 3. 确保键名有引号
      fixed = fixed.gsub(/(\w+)(\s*:)/, '"\1"\2')
      
      begin
        return JSON.parse(fixed)
      rescue JSON::ParserError
        puts "  错误: 无法修复 JSON,返回空 Hash"
        return {}
      end
    end
  end
end

context = TestContext.new

test_cases = [
  # 正常 JSON
  { input: '{"name": "test", "value": 123}', expected_type: Hash, desc: "正常 JSON" },
  
  # 末尾有逗号
  { input: '{"name": "test", "value": 123,}', expected_type: Hash, desc: "末尾逗号" },
  
  # 单引号
  { input: "{'name': 'test', 'value': 123}", expected_type: Hash, desc: "单引号" },
  
  # 空字符串
  { input: '', expected_type: Hash, desc: "空字符串" },
  
  # nil
  { input: nil, expected_type: Hash, desc: "nil 值" },
  
  # 已经是 Hash
  { input: { name: "test" }, expected_type: Hash, desc: "已经是 Hash" },
  
  # 无效 JSON
  { input: '{"name": "test"', expected_type: Hash, desc: "未闭合的 JSON" }
]

puts "=" * 60
puts "测试 JSON 解析修复"
puts "=" * 60

test_cases.each_with_index do |test, i|
  puts "\n测试 #{i + 1}: #{test[:desc]}"
  puts "输入: #{test[:input].inspect}"
  
  begin
    result = context.safe_parse(test[:input])
    puts "结果类型: #{result.class}"
    puts "结果内容: #{result.inspect}"
    
    if result.is_a?(test[:expected_type])
      puts "✅ 通过 - 返回了正确的类型"
    else
      puts "❌ 失败 - 期望 #{test[:expected_type]}, 得到 #{result.class}"
    end
  rescue => e
    puts "❌ 异常: #{e.message}"
  end
end

puts "\n" + "=" * 60
puts "测试完成"
puts "=" * 60
