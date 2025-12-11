## **TUI 版本 vs CLI 版本 - 完整差异分析报告**

### **架构设计对比**

#### **TUI 版本 (原型/基础)**
```
lib/smart_research/
├── application.rb          # 主应用类
├── learning_loop.rb        # 学习循环(未完整实现)
└── components/             # 组件化设计
    ├── root.rb             # 根布局
    ├── main.rb             # 主区域
    ├── sidebar.rb          # 侧边栏(快捷键)
    ├── content.rb          # 内容显示区
    ├── input_area.rb       # 输入区域
    ├── help_dialog.rb      # 帮助对话框
    ├── change_model.rb     # 模型切换
    ├── save_conversation.rb # 保存对话
    └── load_conversation.rb # 加载对话
```

#### **CLI 版本**
```
lib/smart_research_cli.rb   # 单文件设计
```

---

### **功能对比详表**

| 功能特性 | TUI 版本 ✅ | CLI 版本 | 差异说明 |
|---------|-----------|---------|---------|
| **初始化** |
| 数据库初始化 | ❌ 无 | ✅ `Database.setup` | CLI 更完善 |
| AI引擎初始化 | ✅ 双引擎 | ✅ 双引擎 | 相同 |
| MCP 状态检查 | ❌ 无 | ✅ `check_mcp_status` | CLI 更完善 |
| Logger | ✅ `Logger.new` | ❌ 无 | TUI 更完善 |
| AgentContext 扩展 | ❌ 无 | ✅ `show_log` 方法 | CLI 更完善 |
| **工作模式** |
| 交流与探索 (chat) | ✅ F2 切换 | ✅ `chat`/`c` 命令 | 名称不同 |
| 整理知识库 (ask) | ✅ F3 切换 | ✅ `kb`/`knowledge` 命令 | 名称不同 |
| 创作与输出 (write) | ✅ F4 切换 | ✅ `write`/`w` 命令 | 相同 |
| 智能搜索 | ❌ **缺失** | ✅ `search`/`s` 命令 | **CLI 独有** |
| **Agent 调用** |
| chat 模式 | `:smarter_search` | `:smarter_search` | 相同 ✅ |
| ask/kb 模式 | `:smart_kb` | `:smart_kb` | 相同 ✅ |
| write 模式 | `:smart_writer` | `:smart_writer` | 相同 ✅ |
| search 模式 | ❌ **不存在** | `:smart_search` | **不一致** ❌ |
| **输出方式** |
| 流式显示 | ✅ 完整回调系统 | ❌ 简单输出 | TUI 更好 |
| - 推理过程 | ✅ `on_reasoning` | ❌ | TUI 独有 |
| - 内容流式 | ✅ `on_content` | ❌ | TUI 独有 |
| - 工具调用 | ✅ `on_tool_call` | ❌ | TUI 独有 |
| - 日志显示 | ✅ `on_logging` | ❌ | TUI 独有 |
| 颜色高亮 | ✅ 丰富 | ✅ 基础 | TUI 更好 |
| **会话管理** |
| 新建对话 | ✅ Ctrl+N | ❌ 无 | TUI 独有 |
| 保存对话 | ✅ Ctrl+S | ❌ 无 | TUI 独有 |
| 加载对话 | ✅ Ctrl+O | ❌ 无 | TUI 独有 |
| 自动保存 | ✅ 每次回答后 | ❌ 无 | TUI 独有 |
| 对话命名 | ✅ AI自动生成 | ❌ 无 | TUI 独有 |
| **模型管理** |
| 模型切换 | ✅ 对话框选择 | ❌ 无 | TUI 独有 |
| 支持模型 | ✅ 7种预设 | ❌ 配置文件 | TUI 更灵活 |
| **交互特性** |
| 多行输入 | ✅ F6换行 | ❌ 仅单行 | TUI 更强 |
| 历史导航 | ✅ ↑/↓ 切换 | ❌ 无 | TUI 独有 |
| 光标控制 | ✅ ←/→/Home/End | ❌ 无 | TUI 独有 |
| 内容滚动 | ✅ PageUp/Down | ❌ 无 | TUI 独有 |
| 帮助系统 | ✅ F1对话框 | ✅ help命令 | 形式不同 |
| 清屏 | ❌ 无 | ✅ `clear` | CLI 独有 |
| **界面设计** |
| 布局 | ✅ 三栏布局 | ❌ 终端输出 | - |
| - 侧边栏 | ✅ 快捷键提示 | ❌ | TUI 独有 |
| - 内容区 | ✅ 可滚动Panel | ❌ | TUI 独有 |
| - 输入区 | ✅ 独立Panel | ❌ | TUI 独有 |
| 对话框 | ✅ 模态对话框 | ❌ | TUI 独有 |
| **错误处理** |
| 异常捕获 | ✅ 有 | ✅ 有 | 相同 |
| API错误提示 | ❌ 基础 | ✅ 友好提示 | CLI 更好 |
| **线程管理** |
| 异步处理 | ✅ Thread.new | ❌ 同步 | TUI 更好 |
| 输入锁定 | ✅ 处理中锁定 | ❌ 阻塞等待 | TUI 更好 |

---

### **关键差异总结**

#### **1. 缺失的功能（需要补充到 CLI）**

```ruby
# CLI 缺失但 TUI 具备的核心功能：
✗ 会话管理（保存/加载/新建）
✗ 流式输出回调系统
✗ 模型动态切换
✗ 多行输入支持
✗ 命令历史导航
✗ 对话自动命名
✗ 异步线程处理
```

#### **2. CLI 独有功能（需要补充到 TUI）**

```ruby
# TUI 缺失但 CLI 具备的功能：
✗ 数据库初始化 (Database.setup)
✗ MCP 状态详细检查
✗ show_log 方法注入
✗ 独立的 search 模式 (:smart_search agent)
✗ API 认证友好错误提示
✗ clear 清屏功能
```

#### **3. 设计理念差异**

| 维度 | TUI 版本 | CLI 版本 |
|-----|---------|---------|
| 架构 | 组件化、分层 | 单体、过程式 |
| 交互 | 图形化、实时 | 命令式、轮询 |
| 用户体验 | 富交互、所见即所得 | 简单直接、脚本化 |
| 扩展性 | 高（组件独立） | 低（单文件耦合） |
| 学习曲线 | 陡（快捷键） | 平缓（命令） |

---

### **建议的统一方案**

#### **优先级 P0 - 立即修复不一致**
1. ✅ 统一 Agent 名称：确认是否需要 `:smart_search`
2. ✅ CLI 添加数据库初始化
3. ✅ CLI 添加 MCP 状态检查
4. ✅ TUI 添加数据库初始化

#### **优先级 P1 - 功能补齐**
5. CLI 添加会话保存功能
6. CLI 添加流式输出（可选）
7. TUI 添加 search 模式（如需要）

#### **优先级 P2 - 体验优化**
8. 统一错误提示格式
9. 统一日志记录方式
10. 创建共享配置模块