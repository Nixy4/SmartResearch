好的,让我分析向知识库添加内容的代码: 

搜索文本 `create_or_update_source_document` (`**/*.rb`)，15 个结果

已汇总会话历史记录

读取 [](file:///home/nix/SmartResearch/agents/tools/create_or_update_source_document_and_section.rb)

搜索匹配 `**/lib/smart_research/models/*.rb` 的文件，无匹配项

搜索正则表达式 `class.*SourceDocument|class.*SourceSection` (`**/lib/**/*.rb`)，2 个结果

读取 [](file:///home/nix/SmartResearch/lib/models/source_document.rb)

读取 [](file:///home/nix/SmartResearch/lib/models/source_section.rb)

搜索正则表达式 `class.*ResearchTopic` (`**/lib/models/*.rb`)，3 个结果

读取 [](file:///home/nix/SmartResearch/lib/models/research_topic.rb)

读取 [](file:///home/nix/SmartResearch/lib/models/research_topic_section.rb)

读取 [](file:///home/nix/SmartResearch/lib/models/embedding.rb#1-1)，行 1 到 50

读取 [](file:///home/nix/SmartResearch/lib/models/embedding.rb#50-50)，行 50 到 93

搜索文本 `smart_search` (`**/agents/tools/*.rb`)，1 个结果

读取 [](file:///home/nix/SmartResearch/agents/tools/smart_search.rb)

搜索匹配 `**/db/migrations/*.rb` 的文件，无匹配项

搜索匹配 `**/db/*.rb` 的文件，1 个匹配项

搜索正则表达式 `create_table|add_column` (`**/db/*.rb`)，无结果

读取 [](file:///home/nix/SmartResearch/db/init_db.rb)

读取 [](file:///home/nix/SmartResearch/db/init.sql)

现在让我查看一下数据是如何被实际使用和查询的: 

搜索正则表达式 `ask_agent|AskAgent` (`**/agents/**/*.rb`)，无结果

搜索匹配 `**/agents/ask*.rb` 的文件，无匹配项

读取 [](file:///home/nix/SmartResearch/agents)

读取 [](file:///home/nix/SmartResearch/agents/smart_kb.rb#1-1)，行 1 到 150

读取 [](file:///home/nix/SmartResearch/agents/smart_kb.rb#150-150)，行 150 到 300

完美!现在让我查看向量查询的部分: 

读取 [](file:///home/nix/SmartResearch/agents/smart_kb.rb#300-300)，行 300 到 440

现在让我查看查询处理和向量搜索的实现: 

搜索正则表达式 `class.*QueryProcessor|find_new_contents` (`**/lib/**/*.rb`)，1 个结果

读取 [](file:///home/nix/SmartResearch/lib/models/query_processor.rb)

现在查看一下具体的工作流程入口: 

搜索文本 `find_new_contents` (`**/agents/**/*.rb`)，7 个结果

读取 [](file:///home/nix/SmartResearch/agents/smart_writer.rb#1-1)，行 1 到 60

现在查看短记忆管理: 

搜索正则表达式 `class.*ShortMemory` (`**/lib/**/*.rb`)，1 个结果

读取 [](file:///home/nix/SmartResearch/lib/models/short_memory.rb)

完美!现在让我创建一个完整的分析报告:

## 📋 SmartResearch 知识库内容添加代码分析

### 🎯 整体架构

SmartResearch 使用 PostgreSQL + pgvector 构建了一个**语义搜索知识库系统**,包含以下核心组件:

#### 1. **数据模型层** (5张核心表)

```
research_topics (研究主题)
    ↓
research_topic_sections (主题-章节关联)
    ↓
source_sections (文档章节) ← embeddings (向量表)
    ↓
source_documents (源文档)
```

#### 2. **向知识库添加内容的三种方式**

---

### 📝 方式一: `create_or_update_source_document_and_section` 工具

**位置**: create_or_update_source_document_and_section.rb

**工作流程**:
```ruby
1. 根据 URL 查找或创建 SourceDocument
2. 创建 SourceSection (存储文档内容)
3. 根据 topic 参数查找或创建 ResearchTopic
4. 建立 ResearchTopicSection 关联关系
```

**参数**:
- `topic`: 研究主题名称
- `url`: 文档来源URL
- `title`: 文档标题
- `snippet`: 文档摘要
- `text`: 文档正文内容

**特点**:
- ✅ 自动去重 (基于URL)
- ✅ 支持更新已有文档
- ✅ 自动建立主题关联
- ❌ **不生成向量** (需要后续手动下载)
- ❌ **不提取标签**

**调用示例** (在 `smart_search` 工具中):
```ruby
call_tool(:create_or_update_source_document_and_section, {
  "topic" => "Ruby编程语言",
  "url" => "https://ruby-lang.org",
  "title" => "Ruby官方文档",
  "snippet" => "Ruby是一门动态编程语言",
  "text" => "null"  # 只存元数据,不存正文
})
```

---

### 📥 方式二: 批量下载功能 (`smart_kb` Agent)

**位置**: smart_kb.rb

#### 核心函数: `process_content_chunks`

**工作流程**:
```ruby
1. 内容分片 (chunk_content)
   - 按 Markdown 标题分段
   - 单片不超过 4000 字符
   - 片间保留 100 字符重叠

2. 为每个分片创建 SourceSection

3. 生成向量嵌入
   - 调用 get_embedding worker
   - 向量维度: 1024
   - 存入 embeddings 表

4. 提取标签
   - 调用 get_tags worker
   - 存入 section_tags 表
   - 建立 research_topic_tags 关联
```

**命令集**:

| 命令 | 功能 | 示例 |
|------|------|------|
| `d [num]` | 下载指定文档ID | `srcli ask "d 123"` |
| `d [url]` | 下载指定URL | `srcli ask "d https://example.com"` |
| `dd [topic_id]` | 下载主题下所有文档 | `srcli ask "dd 5"` |
| `dall` | 下载所有未下载内容 | `srcli ask "dall"` |

**关键代码分析**:

```ruby
# 1. 智能分片函数
def chunk_content(content, max_chars = 4000)
  # 按 Markdown 标题分段
  chunks = split_by_markdown_headers(content, max_chars)
  
  # 超大段落继续分片(保留重叠)
  final_chunks = []
  chunks.each do |chunk|
    if chunk.length <= max_chars
      final_chunks << chunk
    else
      final_chunks += split_with_overlap(chunk, max_chars, 100)
    end
  end
  final_chunks
end

# 2. 处理内容并存储
def process_content_chunks(doc_id, title, content, topic_ids)
  chunks = chunk_content(content)
  
  chunks.each_with_index do |chunk, index|
    # 创建章节
    section = SourceSection.create_section(doc_id, "null", title)
    section.content = chunk
    section.section_number = index + 1
    section.save
    
    # 生成向量
    text = "#{section_title}\n#{chunk}"
    result = call_worker(:get_embedding, { text: text, length: 1024 })
    Embedding.create_embedding(section.id, "[#{result.response.join(",")}]")
    
    # 提取标签
    topic_ids.each do |topic_id|
      topic = ResearchTopic[topic_id]
      tags = call_worker(:get_tags, { topic: topic.name, text: text })
      # 解析JSON并存储标签...
    end
  end
end
```

**特点**:
- ✅ **自动生成向量**
- ✅ **自动提取标签**
- ✅ **智能内容分片**
- ✅ 支持长文档处理
- ✅ 保留上下文连续性

---

### 🔍 方式三: 智能搜索入库 (`smart_search` 工具)

**位置**: smart_search.rb

**工作流程**:
```ruby
1. 调用搜索引擎获取结果
2. 为搜索结果推荐研究主题
3. 创建或关联研究主题
4. 将搜索结果存入知识库(仅元数据)
```

**特点**:
- ✅ 自动主题分类
- ✅ 批量入库搜索结果
- ❌ **仅存元数据** (text字段为"null")
- ❌ 需要后续使用 `d` 命令下载正文

**代码分析**:
```ruby
# 1. 获取研究主题列表
topics = call_tool(:get_research_topics)

# 2. 执行搜索
result = call_tool(:search, { "query" => input_params["q"], "num" => 10 })

# 3. AI推荐主题
suggestion_topic = call_worker(:get_topic, {
  topics: topics.to_s,
  search_result: result["content"][0]["text"]
})

# 4. 创建研究主题
topic_info = call_tool(:create_research_topic, { "name" => s_topic })

# 5. 遍历搜索结果入库
search_result.each do |sr|
  if SourceDocument.where(url: sr["link"]).empty?
    call_tool(:create_or_update_source_document_and_section, {
      "topic" => JSON.parse(topic_info)["name"],
      "url" => sr["link"],
      "title" => sr["title"],
      "snippet" => sr["snippet"],
      "text" => "null"  # 稍后下载
    })
  end
end
```

---

### 🔎 知识库查询流程

#### QueryProcessor 类

**位置**: query_processor.rb

**查询步骤**:
```ruby
def process_query(query_text, limit = 5)
  results = []
  
  # 1. 多语言查询
  langs.each do |lang|
    # 2. 将问题转为标签
    tags = text_to_tags(query_text, lang)
    
    # 3. 将标签转为向量
    query_vector = text_to_vector(tags.join(","))
    
    # 4. 向量相似度搜索(带标签加权)
    query_results = Embedding.search_by_vector_with_tag_boost(
      query_vector, tags, limit
    )
    results << query_results
  end
  
  # 5. 去重并排序
  results.uniq! { |r| r[:url] }
  results.sort_by! { |r| r[:distance] }
  return results[0..limit*2-1]
end
```

**向量搜索SQL** (在 `Embedding` 模型中):
```sql
SELECT e.id, e.source_id, s.content, d.title, d.url,
       (e.vector <-> ?) as distance
FROM embeddings e
JOIN source_sections s ON e.source_id = s.id
JOIN source_documents d ON s.document_id = d.id
ORDER BY e.vector <-> ?
LIMIT ?
```

**标签加权搜索**:
```sql
-- 匹配标签的记录距离减半(优先级提升)
(e.vector <-> ?) * CASE
  WHEN COUNT(st.tag_id) > 0 THEN 0.5
  ELSE 1.0
END as distance
```

---

### 📊 数据库表结构详解

#### 核心表关系:

```sql
-- 1. 源文档表
CREATE TABLE source_documents (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    url TEXT,
    description TEXT,
    download_state INTEGER DEFAULT 0  -- 0=未下载 1=已下载 2=失败
);

-- 2. 文档章节表
CREATE TABLE source_sections (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES source_documents(id),
    content TEXT NOT NULL,
    section_title TEXT,
    section_number INTEGER,
    tag_id INTEGER  -- 主分类标签
);

-- 3. 向量表 (pgvector)
CREATE TABLE embeddings (
    id SERIAL PRIMARY KEY,
    source_id INTEGER NOT NULL,  -- 指向 source_sections.id
    vector public.vector(1024)   -- 1024维向量
);

-- 4. 研究主题表
CREATE TABLE research_topics (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

-- 5. 主题-章节关联表
CREATE TABLE research_topic_sections (
    research_topic_id INTEGER REFERENCES research_topics(id),
    section_id INTEGER REFERENCES source_sections(id),
    PRIMARY KEY (research_topic_id, section_id)
);

-- 6. 标签表
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- 7. 章节-标签关联表 (多对多)
CREATE TABLE section_tags (
    section_id INTEGER REFERENCES source_sections(id),
    tag_id INTEGER REFERENCES tags(id),
    PRIMARY KEY (section_id, tag_id)
);
```

---

### 🚀 完整使用流程示例

#### 场景: 研究 Ruby 编程语言

```bash
# 1. 启动数据库
sr-pg-start

# 2. 激活环境
conda activate coze

# 3. 搜索并入库(仅元数据)
srcli chat "介绍一下Ruby语言"
# → 调用 smart_search 工具
# → 自动创建研究主题
# → 存储搜索结果元数据

# 4. 查看研究主题
srcli ask "l"
# 输出:
# 1   Ruby编程语言

# 5. 查看主题下的文档
srcli ask "l 1"
# 输出:
# 123  Ruby官方文档
#      null  (未下载正文)

# 6. 下载单个文档
srcli ask "d 123"
# → 下载网页内容
# → 智能分片(4000字符/片)
# → 生成向量嵌入
# → 提取标签

# 7. 批量下载主题下所有文档
srcli ask "dd 1"

# 8. 查询知识库
srcli ask "ask Ruby有哪些特性"
# → 将问题转为向量
# → 相似度搜索
# → 返回最相关的5个分片
# → AI生成自然语言回答
```

---

### ⚡ 关键技术点

#### 1. **向量生成** (通过 LLM Worker)
```ruby
result = call_worker(:get_embedding, { 
  text: "#{section_title}\n#{content}", 
  length: 1024 
})
# → 返回 1024 维向量数组
```

#### 2. **标签提取** (通过 LLM Worker)
```ruby
tags = call_worker(:get_tags, { 
  topic: "研究主题", 
  text: content,
  lang: "简体中文"
})
# → 返回 JSON: {"Type": "技术文档", "Tags": ["编程", "Ruby"]}
```

#### 3. **内容分片策略**
- **优先**: 按 Markdown 标题 (#, ##, ###) 分段
- **兜底**: 超过 4000 字符的段落继续切分
- **保留**: 片间重叠 100 字符保持上下文

#### 4. **向量搜索优化**
- 使用 pgvector 的 `<->` 操作符(余弦距离)
- 标签匹配时距离减半(优先级提升)
- 多语言查询去重

---

### 🎨 优缺点分析

#### ✅ 优点:
1. **智能分片**: 自动处理长文档,保留上下文
2. **语义搜索**: 基于向量相似度,理解问题意图
3. **标签系统**: 支持分类和加权搜索
4. **增量更新**: 根据URL去重,支持更新
5. **多语言**: 支持中英日多语言查询

#### ⚠️ 注意事项:
1. **两阶段入库**: 
   - 搜索时仅存元数据 (text="null")
   - 需要手动执行 `d` 命令下载正文
   
2. **向量生成依赖 LLM**:
   - 需要 `get_embedding` worker 正常工作
   - 向量生成失败不会阻塞入库

3. **标签提取可能失败**:
   - JSON 解析错误会跳过标签
   - 不影响核心搜索功能

4. **内存短记忆**:
   - `ShortMemory` 仅在单次会话生效
   - 不持久化到数据库

---

### 📚 相关文件清单

| 文件 | 功能 |
|------|------|
| create_or_update_source_document_and_section.rb | 工具: 创建文档和章节 |
| smart_search.rb | 工具: 智能搜索并入库 |
| smart_kb.rb | Agent: 知识库管理命令行 |
| source_document.rb | 模型: 源文档 |
| source_section.rb | 模型: 文档章节 |
| embedding.rb | 模型: 向量嵌入 |
| research_topic.rb | 模型: 研究主题 |
| query_processor.rb | 查询处理器 |
| short_memory.rb | 短期记忆管理 |
| init.sql | 数据库表结构 |

---

以上就是 SmartResearch 向知识库添加内容的完整代码分析! 核心是**三种入库方式**和**基于 pgvector 的语义搜索系统**。🎯