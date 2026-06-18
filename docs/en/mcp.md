# MCP server (`rimo mcp`)

[English](../en/mcp.md) | [日本語](../ja/mcp.md)

`rimo mcp` runs the [Model Context Protocol](https://modelcontextprotocol.io) server bundled inside the `rimo` binary. Once it is wired into your AI agent, the agent can list your notes, fetch transcripts, search by keyword or meaning, and ask natural-language questions across your notes — all using typed tools rather than shelling out to the CLI and parsing JSON.

> **Skill vs. MCP — which should you use?** Both ship with `rimo`. The [agent skill](../../skills/rimo-cli/SKILL.md) is a markdown operating manual any agent can read and follow by running shell commands. `rimo mcp` is the typed-tool alternative for MCP-capable clients (Claude Code, Cursor, Codex with MCP support). They can coexist; pick whichever fits your agent.

---

## 1. Prerequisites

1. **`rimo` installed and on `$PATH`.** Confirm with `rimo version`. If not installed yet, see [Installation](installation.md).
2. **A logged-in account.** Run `rimo auth login` to authenticate through your
   browser; the token is stored in your OS keyring. The MCP server reuses the
   same authentication as the CLI — there is no separate MCP login.

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

### Codex

Codex picks up MCP servers from the same `.mcp.json` shape Claude Code uses. Add the snippet above, then restart Codex. If you are running a Codex configuration that does not auto-discover `.mcp.json`, point it at the file explicitly in its launch settings.

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

## 3. Available tools

`rimo mcp` advertises 12 tools. Call `rimo_commands` at any time for the live machine-readable catalogue, including each tool's JSON Schema.

| Tool name                | What it does                                                                |
|--------------------------|-----------------------------------------------------------------------------|
| `note_list`              | List your notes. Supports `page_size` / `page_token` for pagination.        |
| `note_list_attended`     | List notes you participated in as an attendee.                              |
| `note_get`               | Fetch one note by ID. Accepts `meta=true` for metadata-only.                |
| `note_list_participants` | List a note's participants (join against transcript `speaker_uuid`).        |
| `note_list_documents`    | List documents attached to a note.                                          |
| `note_get_document`      | Fetch one document by ID from a note.                                       |
| `note_search`            | Keyword search across your notes.                                           |
| `note_semantic_search`   | Concept / meaning-based retrieval (returns ranked notes; no AI answer).     |
| `note_ask`               | Natural-language Q&A — returns an AI-synthesised answer plus source notes.  |
| `team_list`              | List teams in your organization. Supports `page_size` / `page_token`.      |
| `rimo_auth_status`       | List configured accounts (same shape as `rimo auth status`).                |
| `rimo_commands`          | Full tool catalogue with JSON Schemas. One-call discovery.                  |

**Picking the right retrieval tool**

- `note_search` — exact keywords. Cheapest.
- `note_semantic_search` — describe a concept ("notes about pricing strategy"); ranked notes back, no AI answer.
- `note_ask` — ask a question and get a synthesised answer. Calls the LLM; budget accordingly.

---

## 4. Example agent prompts

Once `rimo mcp` is wired in, your agent picks the right tool from natural-language input. These prompts have all been verified to route to the listed tool:

| What you say                                                              | Tool the agent picks       |
|---------------------------------------------------------------------------|-----------------------------|
| "Show me my Rimo notes from this week."                                   | `note_list`                 |
| "Which Rimo meetings did I attend last sprint?"                           | `note_list_attended`        |
| "Get the transcript of Rimo note `<id>`."                                 | `note_get`                  |
| "Who was in the Rimo meeting `<id>`?"                                     | `note_list_participants`    |
| "What documents are attached to Rimo note `<id>`?"                        | `note_list_documents`       |
| "Pull document `<doc>` from Rimo note `<id>`."                            | `note_get_document`         |
| "Find Rimo notes mentioning 'pricing strategy'."                          | `note_search`               |
| "Find Rimo notes about onboarding — even ones not using that exact phrase." | `note_semantic_search`    |
| "Looking at my Rimo notes, what did we decide about the Q3 release?"      | `note_ask`                  |
| "List the teams in my Rimo organization."                                 | `team_list`                 |
| "Which Rimo accounts am I logged into?"                                   | `rimo_auth_status`          |
| "List every Rimo tool you can use."                                       | `rimo_commands`             |

---

## 5. Reserved tool arguments

Every Rimo API tool accepts these arguments in addition to its operation-specific parameters. They mirror the CLI's global flags.

| Argument   | Type    | Effect                                                                      |
|------------|---------|-----------------------------------------------------------------------------|
| `account`  | string  | Use a specific configured account (same as `--account`).                    |
| `fields`   | string  | Comma-separated allowlist of response fields to keep (same as `--fields`).  |
| `excludes` | string  | Comma-separated denylist of response fields to drop (same as `--excludes`). |
| `dry_run`  | boolean | Simulate without side effects (same as `--dry-run`).                        |

**Multi-account switching.** If you have multiple Rimo accounts in your keyring, append the alias to your prompt — *"…using my `work` account."* The agent passes `account="work"` and `rimo mcp` resolves the matching token before the call. Run `rimo_auth_status` first to see which aliases exist.

**Shrinking agent context.** Long notes can blow the agent's context window. Use `fields` or `excludes` to filter responses. Most agents will use them on their own if you say *"…and just give me the title, ID, and held_at."*

---

## 6. Authentication errors

If a tool call returns an error mentioning auth, the most common causes are:

| Symptom                                                        | Fix                                                                 |
|----------------------------------------------------------------|---------------------------------------------------------------------|
| Every tool returns an error about resolving a token.           | Run `rimo auth login`, then **restart your MCP client** so it re-spawns `rimo mcp` with the new token. |
| Tool succeeds against one account, fails against another.      | Check `rimo_auth_status`. The other account's token may be expired — log in again with `--account <alias>`. |
| You see "no token resolved" but `rimo auth status` looks fine. | Your MCP client may not have inherited your shell's `PATH`. Either provide the absolute path to `rimo` in the `.mcp.json` `command` field, or launch the client from a shell that has `~/.local/bin` on `PATH`. |

---

## 7. Troubleshooting

**The Rimo tools never appear in the tool picker.**
Verify `rimo` is on `$PATH` for the user account running the MCP client. Try `which rimo` from the same shell environment the client launches from. If the client launches from a GUI app (not a shell), it may not see `~/.local/bin`; either add `rimo` to a shell-agnostic location (`/usr/local/bin`) or hard-code the absolute path in `.mcp.json`.

**Tools are listed but every call returns an error.**
Check the logs your MCP client surfaces for `rimo mcp`. Most error messages from the server are written verbatim into the tool result content. Common cases: expired token (re-login + restart client), no internet, backend transiently 5xx (retry).

**The agent picks `note_ask` when I want `note_search`.**
Agents lean on tool descriptions plus your phrasing. Be explicit: *"search my notes for…"* routes to `note_search` / `note_semantic_search`; *"answer the question…"* routes to `note_ask`.

**`rimo_commands` lists fewer tools than I expect.**
Some Rimo API operations are intentionally not exposed yet — only operations the CLI exercises end-to-end ship as MCP tools. The list grows as more CLI commands are released.

**Interactive debugging.**
The official MCP Inspector is the easiest way to poke at the server directly:

```bash
npx @modelcontextprotocol/inspector rimo mcp
```

It opens a local web UI where you can browse tools, inspect schemas, and fire one tool call at a time.

---

## See also

- [Authentication](authentication.md) — login flows, token storage, multi-account
- [Configuration](configuration.md) — `config.yaml`, environment variables
- [Commands](commands.md) — full CLI reference (the MCP server exposes a subset of these)
- [Agent skill](../../skills/rimo-cli/SKILL.md) — the markdown alternative for agents that don't speak MCP
