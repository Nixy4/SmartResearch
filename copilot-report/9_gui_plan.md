## Plan: TUI 移植为 Glimmer GUI 框架

将 SmartResearch TUI 结构迁移为 Glimmer GUI，核心思路是将终端布局、事件回调和交互逻辑映射为窗口控件和事件处理。

### 步骤
1. 设计主窗口布局：主区、侧栏、内容区、输入区（用 vertical_box/horizontal_box/nested box 实现）
2. 将内容面板映射为多行文本框或 label，支持彩色/高亮（可用 rich text 或分色 label）
3. 输入区用 entry + 按钮，支持回车/点击触发 agent 交互
4. 侧栏用 listbox/table 展示主题/历史/功能菜单
5. 事件回调用 Glimmer 的 on_changed/on_clicked/on_custom 绑定，流式内容追加到内容区
6. 日志、工具调用等信息用弹窗或状态栏展示
7. 主循环由 Glimmer 的 show 方法和事件驱动替代

### 进一步考虑
1. 终端彩色高亮需用 GUI 控件分色或富文本模拟
2. 输入区与内容区需支持自动滚动和焦点切换
3. 侧栏功能可扩展为 tab 或 treeview