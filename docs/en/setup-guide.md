# Rimo in Coding Tools

[English](../en/setup-guide.md) | [日本語](../ja/setup-guide.md)

This guide connects Rimo to the AI **coding tools that run on your computer** — Claude Code, Codex CLI, Cursor, and Claude Desktop. They talk to the local MCP server bundled inside the `rimo` binary (`rimo mcp`), so once it is wired in your tool can list your notes, read transcripts, search, and ask questions across your Rimo notes.

> **Using a web assistant (Claude or ChatGPT) instead?** Those need nothing installed — you add Rimo in the browser and sign in. See [Rimo in Claude](rimo-in-claude.md) or [Rimo in ChatGPT](rimo-in-chatgpt.md). For *what you can ask* once connected — the same for every tool — see [What you can do with MCP](mcp.md).

> **Skill vs. MCP — which should you use?** Both ship with `rimo`. The [agent skill](../../skills/rimo-cli/SKILL.md) is a markdown operating manual any agent can read and follow by running shell commands. `rimo mcp` is the typed-tool alternative for MCP-capable clients (Claude Code, Cursor, Codex with MCP support). They can coexist; pick whichever fits your agent.

---

## 1. Prerequisites

1. **`rimo` installed and on `$PATH`.** Confirm with `rimo version`. If not installed yet, see [Installation](installation.md).
2. **A logged-in account.** Run `rimo auth login` to authenticate through your
   browser; the token is stored in your OS keyring. The MCP server reuses the
   same authentication as the CLI — there is no separate MCP login.

> **Claude Desktop is the exception** — its one-click extension bundles `rimo`, so you do **not** need the CLI installed or a `rimo auth login` session for that path. See [Claude Desktop (one-click extension)](#claude-desktop-one-click-extension) below.

---

## 2. Setup per client

### Claude Code

Add a `rimo` entry to your `.mcp.json`. Project-local (`./.mcp.json`, committed alongside your repo) or user-global (`~/.claude/mcp.json`) both work.

```json
{
  "mcpServers": {
    "rimo": {
      "type": "stdio",
      "command": "rimo",
      "args": ["mcp"]
    }
  }
}
```

Restart Claude Code so it spawns the new server. Rimo tools are added; ask naturally and Claude Code routes to the right tool.

### Claude Desktop (one-click extension)

Claude Desktop installs MCP servers as **extensions** (`.mcpb` bundles) — no hand-editing `claude_desktop_config.json`. The Rimo bundle is self-contained: **you do not need the `rimo` CLI installed.**

1. **Get the bundle.** Download `rimo.mcpb` from the [latest release](https://github.com/rimo/cli/releases/latest) (macOS and Windows).
2. **Install it.** Open Claude Desktop → **Settings → Extensions**, then drag `rimo.mcpb` onto the window (or use **Install from file**). Double-clicking the file also works.
3. **Sign in.** Create a [personal API key](personal-api-keys.md) in the Rimo web app and paste it into the extension's **Rimo API key** setting. Claude Desktop stores it securely.
   - Already use the `rimo` CLI? You can leave the key blank — the extension reuses your `rimo auth login` session instead.
4. **Enable it.** The Rimo tools appear in Claude Desktop's tool list; ask naturally and Claude routes to the right tool.

> **Rotating an API key:** revoke the old key in the Rimo web app, create a new one, and paste it into the extension's settings (Settings → Extensions → Rimo → Configure) — the change takes effect right away.

> **Updating:** each release ships a fresh `rimo.mcpb` with that release's `rimo` built in — download the latest and reinstall to update. A separately installed `rimo` CLI updates on its own via `rimo upgrade`; the two copies don't affect each other.

### Codex

Codex CLI does **not** read `.mcp.json`. It reads `~/.codex/config.toml` and registers MCP servers under `[mcp_servers.<name>]` (TOML). Add a `rimo` entry:

```toml
[mcp_servers.rimo]
command = "rimo"
args = ["mcp"]
```

Restart Codex so it spawns the new server. The Rimo tools become available; ask naturally and Codex routes to the right tool. If `rimo` is not on the `PATH` Codex inherits, set `command` to the absolute path (e.g. `command = "/usr/local/bin/rimo"`).

### Cursor

Open Cursor's settings → **MCP** → **Add new MCP server** and fill in:

- **Type:** Command (stdio)
- **Command:** `rimo`
- **Args:** `mcp`

Save and reload Cursor's MCP panel; the Rimo tools will appear.

### Other MCP clients

Any MCP client that speaks stdio JSON-RPC works. The launch command is always:

```bash
rimo mcp
```

The client reads JSON-RPC from stdout and writes to stdin; log output goes to stderr so it never collides with the protocol stream.

---

## 3. Authentication errors

If a tool call returns an error mentioning auth, the most common causes are:

| Symptom                                                        | Fix                                                                 |
|----------------------------------------------------------------|---------------------------------------------------------------------|
| Every tool returns an error about resolving a token.           | Run `rimo auth login`, then **restart your MCP client** so it re-spawns `rimo mcp` with the new token. |
| Tool succeeds against one account, fails against another.      | Check `rimo_auth_status`. The other account's token may be expired — log in again with `--account <alias>`. |
| You see "no token resolved" but `rimo auth status` looks fine. | Your MCP client may not have inherited your shell's `PATH`. Either provide the absolute path to `rimo` in the `.mcp.json` `command` field, or launch the client from a shell that has `~/.local/bin` on `PATH`. |

---

## 4. Troubleshooting

**The Rimo tools never appear in the tool picker.**
Verify `rimo` is on `$PATH` for the user account running the MCP client. Try `which rimo` from the same shell environment the client launches from. If the client launches from a GUI app (not a shell), it may not see `~/.local/bin`; either add `rimo` to a shell-agnostic location (`/usr/local/bin`) or hard-code the absolute path in `.mcp.json`.

**Tools are listed but every call returns an error.**
Check the logs your MCP client surfaces for `rimo mcp`. Most error messages from the server are written verbatim into the tool result content. Common cases: expired token (re-login + restart client), no internet, backend transiently 5xx (retry).

**The agent picks `note_ask` when I want `note_search`.**
Agents lean on tool descriptions plus your phrasing. Be explicit: *"search my notes for…"* routes to `note_search` / `note_semantic_search`; *"answer the question…"* routes to `note_ask`.

**Fewer tools appear than I expect.**
Some Rimo API operations are intentionally not exposed yet — only operations the CLI exercises end-to-end ship as MCP tools. The list grows as more CLI commands are released.

**Interactive debugging.**
The official MCP Inspector is the easiest way to poke at the server directly:

```bash
npx @modelcontextprotocol/inspector rimo mcp
```

It opens a local web UI where you can browse tools, inspect schemas, and fire one tool call at a time.

---

## See also

- [What you can do with MCP](mcp.md) — the tools and example prompts, once you are connected
- [Rimo in Claude](rimo-in-claude.md) / [Rimo in ChatGPT](rimo-in-chatgpt.md) — the hosted server for web assistants; nothing to install
- [Authentication](authentication.md) — login flows, token storage, multi-account
- [Configuration](configuration.md) — `config.yaml`, environment variables
- [Commands](commands.md) — full CLI reference (the MCP server exposes a subset of these)
- [Agent skill](../../skills/rimo-cli/SKILL.md) — the markdown alternative for agents that don't speak MCP
