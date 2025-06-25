# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🚀 SESSION INITIALIZATION (MANDATORY)

**EVERY new conversation MUST start with these steps in exact order:**

### Step 1: Read Project Context Files
1. **Read CLAUDE.md** (this file) - to understand project workflow and requirements
2. **Read PLANNING.md** - to understand architecture, goals, style, and constraints  
3. **Read TASK.md** - to check current task status, priorities, and what's in progress

### Step 2: Check Git Status
4. **Run `git status`** - to check for uncommitted work and understand current state
5. **If uncommitted work exists**: Remind user to commit before starting new tasks

### Step 3: Plan New Work
6. **Use TodoWrite tool** to create/update todo list for any new work before starting
7. **Confirm task priorities** from TASK.md before proceeding

**⚠️ THIS PROTOCOL IS MANDATORY, NOT OPTIONAL. Do not skip these steps.**

---

### 🔄 Project Awareness & Context
- **Always read `PLANNING.md`** at the start of a new conversation to understand the project's architecture, goals, style, and constraints.
- **Check `TASK.md`** before starting a new task. If the task isn't listed, add it with a brief description and today's date.
- **Use consistent naming conventions, file structure, and architecture patterns** as described in `PLANNING.md`.

### 🧱 Code Structure & Modularity
- **Never create a file longer than 500 lines of code.** If a file approaches this limit, refactor by splitting it into modules or helper files.
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
- **Use clear, consistent imports** (prefer relative imports within packages where applicable).

### 🧪 Testing & Reliability
- **Always create unit tests for new features** using the project's testing framework (functions, classes, routes, etc).
- **After updating any logic**, check whether existing unit tests need to be updated. If so, do it.
- **Tests should live in a `/tests` folder** mirroring the main app structure.
  - Include at least:
    - 1 test for expected use
    - 1 edge case
    - 1 failure case

### ✅ Task Completion (MANDATORY WORKFLOW)

**IMMEDIATE TASK MARKING - No Exceptions:**
- **Mark completed acceptance criteria in `TASK.md` IMMEDIATELY** after finishing each one
- **Update TodoWrite tool in parallel** with TASK.md updates for dual tracking
- **Never batch task completions** - mark progress incrementally as work is done

**COMMIT REMINDERS - Required After Every Major Task:**
- **IMMEDIATELY remind user to commit** after completing any full task from TASK.md
- **Suggest specific commit messages** based on actual work accomplished
- **Check git status** before starting new tasks to ensure clean working state

**DISCOVERED WORK TRACKING:**
- Add new sub-tasks or TODOs discovered during development to `TASK.md` under "Discovered During Work" section
- **Never leave discovered tasks untracked** - add them immediately when found

**THIS IS MANDATORY WORKFLOW, NOT SUGGESTIONS.**

### 🔄 Version Control & Git (MANDATORY PROTOCOL)

**REQUIRED GIT CHECKS:**
- **ALWAYS check `git status`** before and after major changes to understand what files have been modified
- **MANDATORY: Check for uncommitted work** when starting new tasks and remind user to commit pending changes first

**MANDATORY COMMIT REMINDERS - Trigger Immediately After:**
  - Completing ANY task or sub-task from `TASK.md`
  - Adding new features or functionality
  - Fixing bugs or issues
  - Updating documentation
  - Completing a testing milestone
  - Implementing any acceptance criteria

**COMMIT MESSAGE REQUIREMENTS:**
- **Suggest specific, meaningful commit messages** that describe what was accomplished, not just what files changed
- **Include task references** (e.g., "Complete INFRA-001: Flutter project initialization")
- **Never commit automatically** - always ask the user if they want to commit the changes

**WORKING STATE MANAGEMENT:**
- **NEVER start new major work** with uncommitted changes
- **Always maintain clean working state** between tasks

### 📎 Style & Conventions
- **Follow the project's established coding standards** and style guide.
- **Use consistent formatting** with the project's configured formatter.
- **Use type annotations** where supported by the language.
- **Write clear documentation** for every function using the project's documentation style.
- **Follow the project's naming conventions** for variables, functions, classes, and files.

### 📚 Documentation & Explainability
- **Update `README.md`** when new features are added, dependencies change, or setup steps are modified.
- **Comment non-obvious code** and ensure everything is understandable to a mid-level developer.
- When writing complex logic, **add an inline comment** explaining the why, not just the what.

### 🌐 MCP Server Requirements
This project uses Model Context Protocol (MCP) servers to extend Claude Code capabilities.

#### Configured MCP Servers
- **Brave Search** (`brave-search`): Web search functionality using Brave Search API
  - Command: `npx @modelcontextprotocol/server-brave-search`
  - Requirements: Node.js, Brave Search API key (set as `BRAVE_API_KEY` environment variable)
  - Usage: Provides web search capabilities for research and documentation lookup

#### MCP Server Management
- **List servers**: `claude mcp list`
- **Add server**: `claude mcp add <name> <command> [args...]`
- **Remove server**: `claude mcp remove <name>`
- **Get server details**: `claude mcp get <name>`

#### Prerequisites for MCP Servers
- **Node.js**: Required for NPX-based servers
- **API Keys**: Store sensitive keys as environment variables, never in code
- **NEVER hardcode API keys** in configuration files or source code
- **Always use environment variables** for sensitive data (e.g., `BRAVE_API_KEY` from `.env`)
- **Network Access**: MCP servers may require internet connectivity

#### MCP Servers
- Brave Search: For web search capabilities

### 🧠 AI Behavior Rules (ENFORCEMENT)

**MANDATORY PROTOCOL COMPLIANCE:**
- **ALWAYS follow the SESSION INITIALIZATION protocol** at the start of every conversation
- **NEVER skip reading CLAUDE.md, PLANNING.md, and TASK.md** before starting work
- **IMMEDIATELY mark task progress** in TASK.md after completing acceptance criteria
- **ALWAYS remind user to commit** after completing major tasks

**TECHNICAL REQUIREMENTS:**
- **Never assume missing context. Ask questions if uncertain.**
- **Never hallucinate libraries or functions** – only use known, verified packages from the project's dependencies
- **Always confirm file paths and module names** exist before referencing them in code or tests
- **Never delete or overwrite existing code** unless explicitly instructed to or if part of a task from `TASK.md`

**WORKFLOW VIOLATIONS:**
- **If you realize you haven't followed the mandatory protocols**, immediately acknowledge the oversight and correct it
- **Never continue work without proper session initialization**