# rimo

[English](README.en.md) | [日本語](README.md)

`rimo` is the command-line interface for the [Rimo Voice](https://rimo.app) platform. Search, fetch, and ask questions about your meeting notes from the terminal.

Built for both humans and AI agents (Claude Code, Codex, etc.): every command speaks JSON by default and exposes its behavior through `--help`, so it slots cleanly into scripts and agent workflows.

> **Official distribution repository.** Download binaries only from [Releases](https://github.com/rimo/cli/releases) and verify them against the published `checksums.txt` (see [Installation](docs/en/installation.md)).

## Install

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

This installs the latest `rimo` binary to `~/.local/bin`. See [Installation](docs/en/installation.md) for other options, upgrades, and uninstall.

## Quickstart

```bash
rimo auth login        # secure browser-based login (token stored securely by your OS)
rimo note list         # list your notes (JSON)
rimo note get <id>     # fetch a single note
```

```bash
rimo note search "Q3 release plan"          # find notes by meaning
rimo note ask "what did we decide on pricing?"   # AI answer drawn from your notes
```

## Commands

All commands print JSON to stdout by default. ([Why, and the exceptions →](docs/en/output-and-errors.md))

| Command | Description |
|---------|-------------|
| [`rimo auth login`](docs/en/commands.md#rimo-auth-login)   | Authenticate via browser-based login |
| [`rimo auth logout`](docs/en/commands.md#rimo-auth-logout) | Revoke tokens and remove a saved account |
| [`rimo auth status`](docs/en/commands.md#rimo-auth-status) | Show authenticated accounts |
| [`rimo auth switch`](docs/en/commands.md#rimo-auth-switch) | Switch the active account |
| [`rimo note list`](docs/en/commands.md#rimo-note-list)     | List notes (`--attended`, `--team`, `--since`/`--until`, `--updated-since`) |
| [`rimo note get`](docs/en/commands.md#rimo-note-get)       | Get a note by ID (metadata, transcript, or document) |
| [`rimo note search`](docs/en/commands.md#rimo-note-search) | Find notes by semantic similarity or keyword |
| [`rimo note ask`](docs/en/commands.md#rimo-note-ask)       | Ask a question and get an AI-synthesised answer |
| [`rimo team list`](docs/en/commands.md#rimo-team-list)     | List teams in your organization |
| [`rimo version`](docs/en/commands.md#rimo-version)         | Print the CLI version |
| [`rimo upgrade`](docs/en/commands.md#rimo-upgrade)         | Self-upgrade to the latest release |

Full flag-by-flag reference: [Commands](docs/en/commands.md).

## Global flags

```
--account <alias>    Account alias to use (overrides active_account in config)
--fields <spec>      Fields to include: "" (all), "compact", or "field1,field2"
--excludes <list>    Comma-separated fields to exclude from output
--dry-run            Simulate the command without side effects (writes only)
```

## Documentation

- [Installation](docs/en/installation.md) — install, upgrade, uninstall
- [Authentication](docs/en/authentication.md) — browser-based login and accounts
- [Personal API keys](docs/en/personal-api-keys.md) — create keys in the web app and authenticate with `RIMO_API_KEY` for CI/CD
- [Commands](docs/en/commands.md) — full reference with flags and examples
- [Configuration](docs/en/configuration.md) — `config.yaml`, credential storage, environment variables
- [Output & errors](docs/en/output-and-errors.md) — JSON design, `--fields`/`--excludes`, exit codes
- [What you can do with MCP](docs/en/mcp.md) — what an AI assistant can look up and answer from your Rimo notes
- [Rimo in Coding Tools](docs/en/setup-guide.md) — connect the `rimo` MCP server in Claude Code, Codex CLI, Cursor, and Claude Desktop
- [Troubleshooting](docs/en/troubleshooting.md) — common install, login, and PATH issues

## AI agents

`rimo` supports two complementary ways to plug into AI coding agents (Claude Code, Codex, Cursor, and others). On Claude Code, the easiest path is the plugin, which installs the skill in one command.

### Claude Code plugin (skill in one command)

The `rimo` plugin ships the [agent skill](skills/rimo-cli/SKILL.md) so Claude Code can drive the CLI. Install it in one command:

```
/plugin marketplace add rimo/cli
/plugin install rimo@rimo
```

This repo doubles as the marketplace, so there is no external dependency. You still need the `rimo` binary on your `$PATH` and an authenticated session (`rimo auth login`). The skill alone lets the agent use every feature through the `rimo` CLI; add the MCP server below if you also want typed tools.

### MCP server (typed tools, for MCP-capable clients)

Run `rimo mcp` to expose the CLI as typed [Model Context Protocol](https://modelcontextprotocol.io) tools. Add a `rimo` entry to your Claude Code `.mcp.json`:

```json
{
  "mcpServers": {
    "rimo": { "type": "stdio", "command": "rimo", "args": ["mcp"] }
  }
}
```

Restart your client and ask naturally:

- *"Summarize my Rimo notes from this week"*
- *"Find Rimo notes about the Q3 release plan"*

Full setup for Claude Code, Codex, Cursor, and other MCP clients: [Rimo in Coding Tools](docs/en/setup-guide.md).

### Claude Desktop (one-click extension)

Claude Desktop installs MCP servers as **extensions** — download `rimo.mcpb` from the [latest release](https://github.com/rimo/cli/releases/latest) and drop it onto **Settings → Extensions**. Everything is included — no CLI install, no config file editing. Sign in by pasting a [personal API key](docs/en/personal-api-keys.md) into the extension settings (CLI users can leave it blank to reuse their `rimo auth login` session). Details: [Rimo in Coding Tools → Claude Desktop](docs/en/setup-guide.md#claude-desktop-one-click-extension).

### Agent skill (works with any agent that runs shell commands)

`rimo` also ships a ready-to-use [agent skill](skills/rimo-cli/SKILL.md) — a self-contained operating manual any agent can read and follow by running shell commands. Use it when your agent does not support MCP, or when you want a single artifact you can paste into a system prompt.

```bash
# Project-local (commit alongside your repo)
mkdir -p .claude/skills/rimo-cli
curl -fsSL https://raw.githubusercontent.com/rimo/cli/main/skills/rimo-cli/SKILL.md \
  -o .claude/skills/rimo-cli/SKILL.md

# Or user-global
mkdir -p ~/.claude/skills/rimo-cli
curl -fsSL https://raw.githubusercontent.com/rimo/cli/main/skills/rimo-cli/SKILL.md \
  -o ~/.claude/skills/rimo-cli/SKILL.md
```

For Codex or other agents, point them at the installed file at the start of a session (e.g. `cat ~/.claude/skills/rimo-cli/SKILL.md`) or include its contents in the agent's system prompt.

## Support

Found a bug or have a feature request? Open an issue in this repository.

## Security

To report a security vulnerability, see our [Security Policy](SECURITY.md) — please do not open a public issue for security reports.

## License

This is not an open-source project. Use of the Rimo CLI is governed by the [Rimo Terms of Service](https://rimo.app/policies/terms); see [NOTICE](NOTICE.md).
