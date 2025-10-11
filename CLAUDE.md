# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SmartResearch is an AI research assistant implementing **Chain of Learning & Thinking (CoLT)** - a self-reinforcing loop of Think → Search → Learn → Store → Repeat. It's a Ruby-based application with MCP (Model Context Protocol) integration, built on SmartAgent and SmartPrompt frameworks.

## Core Architecture

### Three-Mode Application System

The application runs as a TUI (Terminal User Interface) with three operating modes, accessible via F-keys:

- **F2 - Communication & Exploration Mode** (`smart_search`): Interactive research and question answering with autonomous search planning
- **F3 - Knowledge Base Mode** (`smart_kb`): Document management, downloading, tagging, and vector-based retrieval
- **F4 - Creation Mode** (`smart_writer`): Outline generation and article writing based on accumulated knowledge

### Agent System Architecture

Built on **SmartAgent framework**, which provides:
- Multi-model LLM support (DeepSeek, Qwen, Kimi, etc.)
- Tool orchestration with MCP integration
- Worker-based task delegation
- Streaming responses with reasoning display

**Key Agents:**
- `smart_search` (F2): Orchestrates pre-search → smart_search → summary workflows
- `smart_kb` (F3): Command-line interface for knowledge management operations
- `smart_writer` (F4): Handles outline generation and multi-chapter article writing

**Agent Definition Pattern:**
```ruby
SmartAgent.define :agent_name do
  # Access params via params[:key]
  # Call workers: call_worker(:worker_name, params, options)
  # Call tools: call_tool(:tool_name, params)
  # Show logs: show_log(message)
end

SmartAgent.build_agent(:agent_name, tools: [...], mcp_servers: [...])
```

### Knowledge Storage System

PostgreSQL database with pgvector extension for semantic search:
- **ResearchTopic**: Top-level research themes
- **SourceDocument**: Web pages, PDFs, DOCX files
- **SourceSection**: Content chunks (max 4000 chars with 100-char overlap)
- **Embedding**: Vector embeddings for semantic search (1024-dimensional)
- **Tag**: Hierarchical tagging system with type tags and content tags
- Relational tables: `ResearchTopicSection`, `ResearchTopicTag`, `SectionTag`, `TagLink`

Content is automatically chunked by markdown headers, embedded, and tagged for each research topic.

### Configuration Files

- **`config/llm_config.yml`**: SmartPrompt engine configuration (LLM adapters, API keys, worker/template paths)
- **`config/agent.yml`**: SmartAgent engine configuration (agent/tools/MCP paths, logging)
- **`lib/database.rb`**: Database connection string (postgres://user:pass@host/db)

## Development Commands

### Running the Application

```bash
./bin/smart_research
```

The application launches into TUI mode. Press F2/F3/F4 to switch modes.

### Dependencies

```bash
bundle install                    # Install Ruby gems
pip3 install markitdown[all]      # Install Python document converter
```

### Database Setup

Requires PostgreSQL with pgvector extension. Connection configured in `lib/database.rb`:
```ruby
DB = Sequel.connect("postgres://nr:search@localhost/new_research")
```

Initialize database schema (auto-run if tables don't exist):
```bash
# Schema is in db/init.sql, loaded automatically via Database.setup
```

### MCP Server Integration

MCP servers are defined in `agents/mcps/`:
- **opendigger.rb**: Open source project metrics
- **all_in_one.rb**: General research toolkit
- **amap.rb**: Location/mapping services

Each MCP server is a Ruby class with tool definitions that SmartAgent can call.

## Key Implementation Patterns

### Worker Pattern

Workers are defined in `agents/workers/*.rb` with corresponding ERB templates in `agents/templates/*.erb`. Called via:
```ruby
result = call_worker(:worker_name, { param: value },
                     with_tools: true/false,
                     with_history: true/false)
```

Workers handle specific AI tasks like generating search plans, summarizing results, extracting tags, etc.

### Tool Pattern

Tools are defined in `agents/tools/*.rb` and registered with agents. Common tools:
- `create_research_topic`: Creates new research topic in database
- `create_or_update_source_document_and_section`: Stores web content
- `meta_scrape`: Web scraping via MetaScrape service
- `smart_search`: Web search integration
- `query_db`: SQL database queries
- `modify_file`: File editing tool

### Content Processing Pipeline

1. User asks question in F2 mode
2. `pre_search` worker analyzes scope and generates search plan
3. `smart_search` worker executes searches with tools
4. Results stored as SourceDocuments with "null" placeholder content
5. In F3 mode, use `dall` command to download full content
6. Content is chunked, embedded, tagged, and linked to research topics
7. In F4 mode, vector search retrieves relevant content for article writing

### Chunking Strategy

Content is split by markdown headers first, then by max_chars (default 4000) with 100-char overlap. See `chunk_content()` in `agents/smart_kb.rb:17-36`.

### Streaming Display

The TUI uses callbacks for real-time display:
- `agent.on_reasoning`: Displays AI thinking process
- `agent.on_content`: Displays AI responses
- `agent.on_tool_call`: Shows tool execution status
- `agent.on_logging`: Shows custom log messages

## F3 Knowledge Base Commands

Type these in F3 mode:
- `l` / `list`: List all research topics
- `l [num]`: List documents under topic ID
- `ll [num]`: Show document content and tags
- `d [num]`: Download full content for document ID
- `d [url]`: Download and save new URL
- `dd [num]`: Download all docs under topic ID
- `dall`: Download all incomplete documents
- `ask [question]`: Query knowledge base with vector search
- `del [num]`: Delete document and all relations

## F4 Writer Commands

Type these in F4 mode:
- `outline [topic]`: Generate article outline → `reports/outline.json`
- `outline`: Display current outline
- `outline [discussion]`: Modify existing outline based on feedback
- `del`: Delete outline.json
- `write_all` / `wa`: Write full article from outline → `reports/`
- `rewrite [chapter_id] [instructions]`: Rewrite specific chapter
- `format`: Clean up and deduplicate footnotes

## Important Files

- **`lib/smart_research/application.rb`**: Main application class, TUI initialization, agent orchestration
- **`lib/smart_research/learning_loop.rb`**: CoLT loop entry point (currently minimal)
- **`lib/database.rb`**: Database connection and model loading
- **`lib/models/*.rb`**: Sequel ORM models for all database tables
- **`agents/smart_search.rb`**: F2 mode agent definition
- **`agents/smart_kb.rb`**: F3 mode agent definition (500+ lines of command handling)
- **`agents/smart_writer.rb`**: F4 mode agent definition with outline/writing logic

## Testing

No comprehensive test suite currently exists. Main test file: `test/test_helper.rb`

## Architecture Notes

- **RubyRich Framework**: Provides TUI components (Layout, Panel) and event handling
- **SmartPrompt Engine**: Manages LLM interactions, history, and worker invocation
- **SmartAgent Engine**: Provides agent definitions, tool calling, and MCP integration
- **Better Prompt**: Optimization system for prompts (SQLite db at `db/prompt.db`)
- **Sequel ORM**: Database abstraction with validation helpers plugin

The application state lives in `Application` instance, passed to components via `live.app`. Each component (Content, InputArea, Sidebar) registers key bindings and draws views.

## External Dependencies

- **markitdown**: Python tool for converting various formats (PDF, DOCX, etc.) to Markdown
- **PostgreSQL + pgvector**: Vector similarity search for embeddings
- **SQLite3**: Better Prompt prompt optimization database
- **MCP Servers**: Node.js-based tools (e.g., open-digger-mcp-server)
