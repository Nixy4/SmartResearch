## SmartResearch Models 依赖关系分析及Python移植计划

### 一、模型文件概览

models 目录包含11个模型文件：

1. embedding.rb - 向量嵌入管理
2. query_processor.rb - 查询处理器 
3. research_topic.rb - 研究主题
4. research_topic_section.rb - 研究主题-段落关联
5. research_topic_tag.rb - 研究主题-标签关联
6. section_tag.rb - 段落-标签关联
7. short_memory.rb - 短期内存
8. source_document.rb - 源文档
9. source_section.rb - 源文档段落
10. tag.rb - 标签
11. tag_link.rb - 标签链接

### 二、依赖关系分析

#### 核心依赖层级：

**1. 基础模型层（无依赖）**
- short_memory.rb - 纯内存对象，无数据库依赖
- tag.rb - 基础标签模型

**2. 主要实体层**
- source_document.rb - 源文档实体
- research_topic.rb - 研究主题实体

**3. 关联模型层**
- source_section.rb - 依赖 `source_document`和`tag`
- tag_link.rb - 依赖 `tag`

**4. 多对多关联层**
- research_topic_section.rb - 依赖 `research_topic`和`source_section`
- research_topic_tag.rb - 依赖 `research_topic`和`tag`
- section_tag.rb - 依赖 `source_section`和`tag`

**5. 高级功能层**
- embedding.rb - 依赖 `source_section`和`source_document`
- `query_processor.rb` - 依赖 `embedding`和`short_memory`

#### 数据库关联关系：

```
source_document (1) -----> (*) source_section
tag (1) -----> (*) source_section
research_topic (*) <-----> (*) tag (通过 research_topic_tag)
research_topic (*) <-----> (*) source_section (通过 research_topic_section)
source_section (*) <-----> (*) tag (通过 section_tag)
tag (1) -----> (*) tag_link <----- (1) tag
source_section (1) -----> (*) embedding
```

### 三、Python移植计划

#### 阶段一：基础设施搭建
**依赖包选择：**
- ORM: SQLAlchemy (对应Ruby的Sequel)
- 向量数据库: pgvector with psycopg2
- JSON处理: 内置json库
- 数学计算: numpy (用于向量操作)

#### 阶段二：模型移植顺序

**第1批：基础模型（无依赖）**
```python
# models/short_memory.py
class ShortMemory:
    def __init__(self):
        self.memory = {}
    
    def add_mem(self, url, mem):
        self.memory[url] = mem
    
    def find_mem(self, url):
        return self.memory.get(url)

# models/tag.py  
from sqlalchemy import Column, Integer, String
from .base import Base

class Tag(Base):
    __tablename__ = 'tags'
    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True, nullable=False)
```

**第2批：主要实体**
```python
# models/source_document.py
class SourceDocument(Base):
    __tablename__ = 'source_documents'
    # 字段定义...
    
# models/research_topic.py  
class ResearchTopic(Base):
    __tablename__ = 'research_topics'
    # 字段定义...
```

**第3批：关联模型**
```python
# models/source_section.py
class SourceSection(Base):
    __tablename__ = 'source_sections'
    document_id = Column(Integer, ForeignKey('source_documents.id'))
    tag_id = Column(Integer, ForeignKey('tags.id'))
    
# models/tag_link.py
class TagLink(Base):
    __tablename__ = 'tag_links'
    source_tag_id = Column(Integer, ForeignKey('tags.id'))
    target_tag_id = Column(Integer, ForeignKey('tags.id'))
```

**第4批：多对多关联**
```python
# models/associations.py
research_topic_tags = Table('research_topic_tags', Base.metadata,
    Column('research_topic_id', Integer, ForeignKey('research_topics.id')),
    Column('tag_id', Integer, ForeignKey('tags.id'))
)

section_tags = Table('section_tags', Base.metadata,
    Column('section_id', Integer, ForeignKey('source_sections.id')), 
    Column('tag_id', Integer, ForeignKey('tags.id'))
)
```

**第5批：高级功能**
```python
# models/embedding.py
class Embedding(Base):
    __tablename__ = 'embeddings'
    vector = Column(Vector(1024))  # pgvector类型
    
    @classmethod
    def search_by_vector(cls, query_vector, limit=5):
        return session.query(cls).order_by(
            cls.vector.cosine_distance(query_vector)
        ).limit(limit)

# models/query_processor.py  
class QueryProcessor:
    def __init__(self, engine):
        self.engine = engine
        self.short_memory = ShortMemory()
```

#### 阶段三：功能对应

**Ruby Sequel → Python SQLAlchemy 映射：**
- `validates_presence` → `nullable=False` + validation
- `many_to_many` → `relationship()` with secondary table
- `first()` → `session.query().first()`
- `where()` → `session.query().filter()`
- `join()` → `session.query().join()`

#### 阶段四：特殊功能处理

**向量搜索：**
```python
# 需要安装pgvector扩展
from pgvector.sqlalchemy import Vector

# 余弦相似度搜索
def search_by_vector_with_tag_boost(self, query_vector, tags=[], limit=5):
    query = session.query(Embedding).join(SourceSection).join(SourceDocument)
    
    if tags:
        # 添加标签提升逻辑
        query = query.outerjoin(SectionTag).outerjoin(Tag)
        query = query.filter(Tag.name.in_(tags))
    
    return query.order_by(Embedding.vector.cosine_distance(query_vector)).limit(limit)
```

**JSON处理和AI引擎接口：**
```python
import json

def text_to_tags(self, text, lang="简体中文"):
    if self.engine:
        try:
            result = self.engine.call_worker('get_tags', {
                'topic': '知识库查询', 
                'text': text, 
                'lang': lang
            })
            # JSON解析逻辑
            return json.loads(result)['Tags']
        except Exception as e:
            return []
    return []
```

#### 阶段五：配置和部署

**database.py:**
```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://user:password@localhost/smartresearch"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
```

### 四、移植优先级建议

1. **第一阶段** (1-2周)：基础模型 + ORM配置
2. **第二阶段** (2-3周)：核心实体模型 + 基本CRUD
3. **第三阶段** (2-3周)：关联关系 + 多对多表
4. **第四阶段** (3-4周)：向量搜索 + 查询处理器
5. **第五阶段** (1-2周)：测试 + 优化 + 文档

**总计：9-14周完成完整移植** 

已完成(制定Python移植计划/4) *4*

### 五、关键技术点

1. **向量数据库集成**：需要PostgreSQL + pgvector扩展
2. **AI引擎接口**：需要适配现有的SmartPrompt引擎调用
3. **多语言支持**：保持中文、英文、日文等多语言标签处理
4. **性能优化**：向量搜索的索引和查询优化
5. **数据迁移**：从Ruby Sequel到Python SQLAlchemy的数据迁移脚本

这个移植计划充分考虑了模型间的依赖关系，采用分阶段实施，确保每个阶段都有可测试的成果，降低移植风险。

Nixy4: 导出刚刚的计划到一个md

GitHub Copilot: 我来将刚刚分析的SmartResearch模型依赖关系和Python移植计划导出到一个markdown文件。 

Nixy4: @agent 重试

GitHub Copilot: 

Nixy4: @agent 重试

GitHub Copilot: 