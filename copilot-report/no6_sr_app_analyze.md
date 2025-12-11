搜索正则表达式 `call_agent|agent_engine|please|on_reasoning|on_content|on_tool_call` (`**/lib/**/*.rb`)，10 个结果

搜索匹配 `**/config/agent.yml` 的文件，1 个匹配项

搜索正则表达式 `smarter_search|smart_kb|smart_writer` (`**/lib/**/*.rb`)，3 个结果

读取 [](file:///home/nix/SmartResearch/config/agent.yml)

搜索正则表达式 `QueryProcessor|Embedding|search_by_vector` (`**/lib/**/*.rb`)，20 个结果

读取 [](file:///home/nix/SmartResearch/agents)

搜索匹配 `**//home/nix/SmartResearch/agents/*.yml` 的文件，无匹配项

读取 [](file:///home/nix/SmartResearch/lib/models/query_processor.rb#1-1)，行 1 到 100

读取 [](file:///home/nix/SmartResearch/agents/smarter_search.rb)

读取 [](file:///home/nix/SmartResearch/agents/smart_kb.rb#1-1)，行 1 到 100

读取 [](file:///home/nix/SmartResearch/agents/smart_writer.rb#1-1)，行 1 到 100

## Agent引擎工作逻辑分析报告

### 🏗️ 架构概览

```
SmartAgent::Engine (./config/agent.yml)
    ↓
加载3个预定义Agent
    ├── smarter_search (智能搜索)
    ├── smart_kb (知识库整理)
    └── smart_writer (创作输出)
```

---

### 🔧 Agent引擎初始化

**配置文件**: agent.yml
```yaml
logger_file: "./log/agent.log"
engine_config: "./config/llm_config.yml"  # LLM配置
agent_path: "./agents"                     # Agent定义目录
tools_path: "./agents/tools"               # 工具目录
mcp_path: "./agents/mcps"                  # MCP服务器目录
```

**初始化流程**:
```ruby
@agent_engine = SmartAgent::Engine.new("./config/agent.yml")
# → 自动加载 agents/ 目录下的所有 .rb 文件
# → 构建 agents Hash: { agent_name => Agent实例 }
```

---

### 🎯 核心执行流程

#### 1. **Agent调用入口**

```ruby
def call_agent(agent_name, input_text, content_panel)
  agent = @agent_engine.agents[agent_name]  # 获取指定agent
  
  # 注册4个回调事件
  agent.on_reasoning { |chunk| ... }   # 推理过程
  agent.on_content { |chunk| ... }     # 内容输出
  agent.on_tool_call { |msg| ... }     # 工具调用
  agent.on_logging { |msg| ... }       # 日志信息
  
  agent.please(input_text)  # 发起请求
end
```

#### 2. **事件驱动模型**

**4种事件流**:

| 事件 | 触发条件 | 数据结构 |
|------|---------|---------|
| `on_reasoning` | AI推理阶段 | `chunk["choices"][0]["delta"]["reasoning_content"]` |
| `on_content` | AI回复阶段 | `chunk["choices"][0]["delta"]["content"]` |
| `on_tool_call` | 工具调用 | `msg[:status]` → `:start` / `:end` / 其他 |
| `on_logging` | 自定义日志 | 字符串消息 |

**状态转换**:
```
初始状态 (reasoning=false, reasoned=false)
    ↓
收到reasoning_content → 显示"AI Thinking:" (reasoning=true)
    ↓
收到content → 显示"AI Talking:" (reasoning切换回false)
    ↓
继续输出content → 流式显示
```

---

### 🤖 三大核心Agent

#### 1️⃣ **smarter_search** - 智能搜索引擎

**工作流程** (5步流水线):

```ruby
SmartAgent.define :smarter_search do
  # Step 1: 分析问题类型和搜索范围
  call_worker(:analyze_search_scope, params, 
              with_tools: false, with_history: true)
  
  # Step 2: 初步搜索 (带工具调用)
  call_worker(:pre_search, params, 
              with_tools: true, with_history: true)
  → 如果需要，调用 call_tools(result)
  
  # Step 3: 生成详细搜索规划
  call_worker(:generate_search_plan, params, 
              with_tools: false, with_history: true)
  
  # Step 4: 执行详细搜索 (带工具调用)
  call_worker(:smart_search, params, 
              with_tools: true, with_history: true)
  → 如果需要，调用 call_tools(result)
  
  # Step 5: 总结搜索结果
  call_worker(:summary, params, 
              with_tools: false, with_history: true)
end
```

**关键特性**:
- **多阶段推理**: 分析→预搜→规划→详搜→总结
- **工具集成**: 注册了 `smart_search` 工具和 `opendigger` MCP服务器
- **历史记忆**: `with_history: true` 保持上下文连贯
- **日志追踪**: 每步完成后调用 `show_log()`

---

#### 2️⃣ **smart_kb** - 知识库整理器

**核心功能**:

1. **文档分块处理** (`chunk_content`)
   - 按Markdown标题分段
   - 超长段落再按4000字符+100重叠分片
   - 防止超过LLM上下文限制

2. **智能分段策略**:
```ruby
def split_by_markdown_headers(content, max_chars)
  headers = ["#", "##", "###", "####"]
  # 识别markdown结构
  # 按语义边界切分
end

def split_with_overlap(content, max_chars, overlap)
  # 保留100字符重叠
  # 在换行符处切分
end
```

3. **JSON提取工具**:
```ruby
def get_json(result)
  # 从LLM输出中提取JSON
  # 支持 ```json...``` 和裸JSON
  # 容错处理
end
```

**应用场景**: 文档导入、内容整理、标签提取

---

#### 3️⃣ **smart_writer** - 智能创作引擎

**双层架构**:

##### Layer 1: 查询处理层 (`QueryProcessor`)

```ruby
class QueryProcessor
  def process_query(query_text, limit = 5)
    # 多语言标签提取
    langs = ["简体中文", "繁体中文", "英语", "日语"]
    langs.each do |lang|
      tags = text_to_tags(query_text, lang)
      query_vector = text_to_vector(tags.join(","))
      
      # 向量检索 + 标签加权
      results = Embedding.search_by_vector_with_tag_boost(
        query_vector, tags, limit
      )
    end
    
    # 去重、排序、返回Top结果
    results.uniq!.sort_by! { |r| r[:distance] }
  end
end
```

**关键方法**:
- `text_to_tags`: 调用 `:get_tags` worker，LLM提取关键标签
- `text_to_vector`: 调用 `:get_embedding` worker，生成1024维向量
- `Embedding.search_by_vector_with_tag_boost`: PostgreSQL pgvector检索

##### Layer 2: 创作流程层

```ruby
def generate_outline(query_text, query_processor, short_memory)
  # 读取已有提纲（如果存在）
  existing_outline = JSON.parse(File.read("reports/outline.json"))
  
  # 迭代搜索并生成提纲
  while contents.size > 0
    outline = call_worker(:preparation_outline, {
      query_text: query_text,
      contents: contents,
      existing_outline: last_json  # 增量修改
    })
    
    # 提取JSON结构
    outline_json = get_json(outline.content)
    
    # 如果需要更多信息，继续搜索
    if outline_json["query"]
      contents = find_new_contents(query_processor, ...)
    end
  end
  
  # 保存到 reports/outline.json
  File.write("reports/outline.json", JSON.pretty_generate(outline_json))
end
```

**核心特性**:
- **增量式生成**: 基于已有提纲修改，而非重新生成
- **短期记忆管理**: `ShortMemory` 避免重复检索相同URL
- **自适应搜索**: LLM决定是否需要更多信息

---

### 🔄 数据流详解

#### 完整调用链

```
用户输入
    ↓
Application.call_agent(:smarter_search, text, panel)
    ↓
Agent.please(text) → 触发agent定义的流程
    ↓
call_worker(:worker_name, params) → 调用SmartPrompt Worker
    ↓
Worker处理 → 返回结果
    ↓
如果result.call_tools == true
    ↓
call_tools(result) → 执行工具/MCP调用
    ↓
工具返回结果 → 注入到历史消息
    ↓
继续下一个call_worker
    ↓
最终返回result.content
    ↓
通过on_content回调 → 流式显示到content_panel
```

#### 向量检索流程 (smart_writer专用)

```
query_text
    ↓
QueryProcessor.process_query
    ↓
text_to_tags(多语言) → ["标签1", "标签2", ...]
    ↓
text_to_vector → [0.123, 0.456, ...] (1024维)
    ↓
Embedding.search_by_vector_with_tag_boost
    ↓
PostgreSQL: SELECT ... ORDER BY vector <-> query_vector
    ↓
返回 {url, content, distance, document_title, ...}
    ↓
去重 + 排序 + Top-K
```

---

### 🛠️ Worker系统

**Worker类型**:

| Worker名称 | 用途 | 带工具? |
|-----------|------|--------|
| `analyze_search_scope` | 分析搜索范围 | ❌ |
| `pre_search` | 初步搜索 | ✅ |
| `generate_search_plan` | 生成搜索计划 | ❌ |
| `smart_search` | 详细搜索 | ✅ |
| `summary` | 总结结果 | ❌ |
| `get_tags` | 提取标签 | ❌ |
| `get_embedding` | 生成向量 | ❌ |
| `preparation_outline` | 生成提纲 | ❌ |

**调用参数**:
- `with_tools`: 是否启用工具调用能力
- `with_history`: 是否包含历史对话上下文

---

### 🎨 设计亮点

1. **流式响应**: 实时显示AI思考和回复过程，用户体验佳
2. **多阶段推理**: 将复杂任务拆解为多个Worker步骤
3. **工具-Agent解耦**: Worker处理逻辑，Tools提供能力
4. **向量+标签双重检索**: 语义匹配+关键词加权
5. **增量式生成**: 提纲可多次迭代改进
6. **短期记忆**: 避免重复检索，提高效率

---

### ⚠️ 潜在优化点

1. **错误处理**: `call_worker` 缺少超时和重试机制
2. **并发控制**: 多个Agent同时调用可能导致资源竞争
3. **缓存策略**: 向量检索结果可缓存，减少DB查询
4. **状态持久化**: Agent执行状态不持久化，重启丢失
5. **Token消耗监控**: 缺少对LLM调用成本的追踪

---

### 📊 性能分析

**smarter_search时间复杂度**:
```
O(5 * LLM调用) + O(n * 工具调用)
约 5-10秒 (取决于LLM响应速度)
```

**smart_writer查询性能**:
```
O(4 * 标签提取) + O(4 * 向量检索) + O(n * 去重排序)
约 2-5秒 (PostgreSQL pgvector很快)
```

这个Agent系统采用了**多阶段推理 + 工具增强 + 向量检索**的混合架构，是一个完整的RAG (Retrieval-Augmented Generation) 实现。