# MCP Setup Guide (macOS)

This guide sets up the three MCP servers for your workflow: **GitHub**, **Filesystem**, and **Web search (Brave)**.

Read this before touching `.mcp.json`. MCP has two scopes — user and project — and getting that wrong is the most common beginner mistake.

---

## Scope: User vs Project

| Scope | Stored in | Who can see it | When to use |
|-------|-----------|----------------|-------------|
| **user** | `~/.claude.json` | Only you, all projects | Servers you always want (GitHub, web search) |
| **project** | `.mcp.json` in repo | Everyone on the project | Servers specific to this task (filesystem paths) |

**The rule for your setup:**
- GitHub → `user` scope (you want this everywhere, and your PAT is secret)
- Filesystem → `project` scope (paths are task-specific, scoped per repo)
- Web search → `user` scope (general purpose, always useful)

Credentials go in environment variables, **never** hardcoded in `.mcp.json`.

---

## Prerequisites

```bash
# Verify Node.js is available (needed for npx-based servers)
node --version   # should be 18+
npx --version
```

---

## 1. GitHub MCP Server

GitHub's official remote MCP server. Uses HTTP transport with a Personal Access Token.

### Create a GitHub PAT

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Create a token with these permissions (minimum): `Contents: Read`, `Issues: Read/Write`, `Pull requests: Read/Write`, `Metadata: Read`
3. Copy the token

### Store the token securely

```bash
# Add to your ~/.zshrc (or ~/.zshenv for non-interactive shells)
echo 'export GITHUB_PAT="ghp_your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

### Add to Claude Code (user scope — available across all projects)

```bash
claude mcp add-json github \
  '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer '"$GITHUB_PAT"'"}}' \
  --scope user
```

### Verify

```bash
claude mcp list          # should show 'github'
claude mcp get github    # should show URL and status
```

---

## 2. Filesystem MCP Server

Lets Claude read/write files outside the project directory if needed. Scope this to your **project** — different tasks need access to different paths.

### Add via `.mcp.json` (project scope — committed to the repo)

Edit `.mcp.json` in your task repo:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/YOUR_USERNAME/projects",
        "/Users/YOUR_USERNAME/data"
      ]
    }
  }
}
```

Replace paths with the directories Claude should be able to access for this task.

**Important:** The `@npm` package is installed on-demand by `npx -y`. No separate install step needed.

### OR add via CLI (local scope — not committed, just for you)

```bash
claude mcp add filesystem \
  --transport stdio \
  -- npx -y @modelcontextprotocol/server-filesystem \
  /Users/$USER/projects /Users/$USER/data
```

---

## 3. Web Search — Brave Search MCP Server

Gives Claude the ability to search the web during tasks (literature review, documentation lookup, etc.).

### Get a Brave Search API key

1. Go to https://api.search.brave.com/
2. Create an account and get a free API key (2,000 queries/month free)
3. Copy the key

### Store the key securely

```bash
echo 'export BRAVE_API_KEY="BSA_your_key_here"' >> ~/.zshrc
source ~/.zshrc
```

### Add to Claude Code (user scope)

```bash
claude mcp add brave-search \
  --transport stdio \
  --env BRAVE_API_KEY=$BRAVE_API_KEY \
  -- npx -y @modelcontextprotocol/server-brave-search \
  --scope user
```

### Verify

```bash
claude mcp list    # should show github, brave-search
```

---

## Checking all servers at once

Inside Claude Code:
```
/mcp
```

This shows all connected servers, their status, and available tools.

---

## Context window impact

Each MCP server adds tools that consume context. Rough estimates:

| Server | Approx. tools | Context cost |
|--------|--------------|--------------|
| GitHub | ~30+ | Medium |
| Filesystem | ~10 | Low |
| Brave search | ~2 | Very low |

Claude Code's **Tool Search** feature activates automatically when tools exceed ~10% of context, deferring definitions until needed. With Sonnet 4 / Opus 4 this reduces token cost by ~85%.

Still: don't add servers you don't need for a given task. Use `claude mcp list` and remove unused ones.

---

## Troubleshooting

**Server shows "disconnected" in `/mcp`:**
```bash
# Check if npx can reach the package
npx -y @modelcontextprotocol/server-filesystem --help

# Increase startup timeout if slow network
MCP_TIMEOUT=30000 claude
```

**GitHub auth fails:**
```bash
# Verify your PAT is in the environment
echo $GITHUB_PAT

# Re-add the server with a fresh token
claude mcp remove github
claude mcp add-json github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer '"$GITHUB_PAT"'"}}' --scope user
```

**Too many tools / context issues:**
```bash
# List what's loaded
claude mcp list

# Remove a server temporarily
claude mcp remove server-name

# Re-add later when needed
```

---

## Per-task `.mcp.json` template

The `.mcp.json` file committed to each task repo should only contain project-scoped servers (filesystem paths). User-scoped servers (GitHub, Brave) are in `~/.claude.json` and load automatically.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/YOUR_USERNAME/projects/THIS_PROJECT",
        "/Users/YOUR_USERNAME/data/THIS_PROJECT"
      ]
    }
  }
}
```

Commit this to your task repo. Each collaborator adds their own user-scoped servers independently.
