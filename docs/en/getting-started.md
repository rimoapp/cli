# Getting Started

`rimo` is the command-line interface for the [Rimo Voice](https://rimo.app) platform. It lets you search, fetch, and ask questions about your meeting notes from the terminal — or wire it into AI agents like Claude Code, Codex, and Cursor.

## Install

**Linux / macOS**

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

**Windows (PowerShell)**

```powershell
irm https://rimo.app/cli/install.ps1 | iex
```

Verify:

```bash
rimo version
```

For manual installs, upgrades, and uninstall instructions, see [Installation](installation.md).

## Log in

```bash
rimo auth login
```

This opens your browser. Sign in and approve the request — your tokens are stored securely by your OS credential store, never in a file.

On headless machines (SSH, CI):

```bash
rimo auth login --no-browser
```

## Your first commands

```bash
# List your notes
rimo note list

# Fetch a single note (metadata as JSON)
rimo note get <note_id>

# Fetch a note's transcript as plain text
rimo note get <note_id> --transcript

# Search notes by meaning
rimo note search "Q3 release plan"

# Ask a question, get an AI-synthesised answer
rimo note ask "what did we decide about pricing?"
```

## Output format

Every command prints JSON to stdout by default — no TTY detection, no table formatting. This makes `rimo` predictable in both terminals and scripts:

```bash
rimo note list | jq '.notes[].title'
rimo note list --fields id,title,created_at
```

A few commands print plain text instead: `rimo version`, `rimo upgrade`, `rimo note ask`, and `rimo note get` with content flags. Errors are always JSON.

See [Output & Errors](output-and-errors.md) for the full contract.

## Next steps

- [Installation](installation.md) — platform-specific install, upgrade, uninstall
- [Authentication](authentication.md) — multi-account setup
- [Commands](commands.md) — full flag-by-flag reference
- [MCP Server](mcp.md) — typed tools for Claude Code, Codex, Cursor
- [Examples](examples.md) — practical recipes
