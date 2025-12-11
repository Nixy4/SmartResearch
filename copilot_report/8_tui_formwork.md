读取 [](file:///home/nix/SmartResearch/lib/smart_research/application.rb)

application.rb 的 TUI（终端用户界面）主要由以下部分组成：

---

### 1. **布局组件（Component）**
- `@layout = Component::Root.build`
- 主体分为左右两栏：`split_row(Component::Main, Component::Sidebar)`
- 主栏再分上下：`split_column(Component::Content, Component::InputArea)`
- 负责整体界面结构（主区、侧边栏、内容区、输入区）

---

### 2. **事件回调系统**
- 通过 agent 的事件注册，动态更新内容区
  - `on_reasoning`：AI推理流式输出（高亮 cyan）
  - `on_content`：AI内容流式输出（高亮 blue）
  - `on_tool_call`：工具调用提示（高亮 cyan）
  - `on_logging`：日志消息（高亮 cyan）

---

### 3. **内容面板（content_panel）**
- 所有 AI/工具/日志输出都追加到 `content_panel.content`
- 使用 `RubyRich::AnsiCode` 控制终端颜色

---

### 4. **输入与对话管理**
- `clear_history_messages`：清空历史
- `get_conversation_name`：获取对话标题
- `start` 方法：启动 TUI 主循环，绑定输入区、刷新率、提示符等

---

### 5. **主循环与交互**
- `RubyRich::Live.start`：启动 TUI，设置刷新率、输入位置、提示符等参数
- 监听用户输入，驱动 agent 交互

---

**总结：**
- 布局（主区/侧栏/内容/输入）
- 事件回调（推理、内容、工具、日志）
- 内容面板（流式输出、彩色高亮）
- 输入区与对话管理
- 主循环（Live TUI）

如需详细代码结构或交互流程图，可进一步展开。