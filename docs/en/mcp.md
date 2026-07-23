# What you can do with MCP

[English](../en/mcp.md) | [日本語](../ja/mcp.md)

Rimo's **MCP** connection lets an AI assistant look things up in your Rimo meeting notes and answer you in plain language — right inside the assistant you already use. You ask a question the way you'd ask a colleague, and the assistant reads only the notes **you** can see in Rimo and replies.

There are two ways to connect, and **what you can ask is the same for both**:

- **In a web assistant — Claude, ChatGPT, or Microsoft Copilot.** Nothing to install. You add Rimo once and sign in through your browser. See [Rimo in Claude](rimo-in-claude.md), [Rimo in ChatGPT](rimo-in-chatgpt.md), or [Rimo in Microsoft Copilot](rimo-in-microsoft.md).
- **In a coding tool on your computer — Claude Code, Codex CLI, Cursor, or Claude Desktop.** A one-time setup connects Rimo. See [Rimo in Coding Tools](setup-guide.md).

This page is about *what you can do* once connected. For *how to connect*, follow one of the links above.

---

## Things you can ask

Just talk to the assistant naturally — no commands to memorise. For example:

- **Find a meeting** — *"Show me my Rimo notes from this week."* · *"Which Rimo meetings did I attend last sprint?"*
- **Read a meeting** — *"Get the transcript of my last Rimo meeting."* · *"What documents are attached to that note?"*
- **Search across meetings** — *"Find my Rimo notes about pricing strategy."* · *"Find my notes about onboarding — even the ones that don't use that exact word."*
- **Get an answer, not just links** — *"Looking at my Rimo notes, what did we decide about the Q3 release?"*
- **See who was there** — *"Who was in that meeting?"*
- **See your teams** — *"List the teams in my Rimo organization."*

The assistant only ever shows what **you** can see in Rimo. A note a colleague never shared with you will not show up.

---

## What Rimo can do for the assistant

In plain terms, an assistant connected to Rimo can:

- **List your notes** — the meetings you own or attended, filterable by date.
- **Open a note** — read its transcript, attached documents, or meeting-chat log.
- **Search your notes** — by exact keyword, or by *meaning* (e.g. "notes about pricing") even when the wording is different.
- **Answer a question** — read the relevant notes and write a short answer, telling you which meetings it used.
- **List the participants** of a meeting, and the **teams** in your organization.

The list grows as new features ship — this page is the place to check what is available.

---

## Tool reference (for developers)

> Everyday users can skip this section — it is here for anyone wiring Rimo into an
> agent and tuning which tool gets called. The same tools are available whether you
> connect through a web assistant or a coding tool.

The connection exposes these typed tools:

| Tool name                | What it does                                                                |
|--------------------------|-----------------------------------------------------------------------------|
| `note_list`              | List your notes. Supports `page_size` / `page_token` for pagination.        |
| `note_list_attended`     | List notes you participated in as an attendee.                              |
| `note_get`               | Fetch one note by ID. Metadata only by default; `meta=false` for full contents. |
| `note_read`              | Read a note's contents as text/markdown (`format=document`/`transcript`/`full`/`meeting_chat`/`document_by_id`). |
| `note_list_participants` | List a note's participants (join against transcript `speaker_uuid`).        |
| `note_list_documents`    | List documents attached to a note.                                          |
| `note_get_document`      | Fetch one document by ID from a note.                                       |
| `note_get_meeting_chat`  | Fetch a note's meeting-chat log.                                            |
| `note_search`            | Keyword search across your notes.                                           |
| `note_semantic_search`   | Concept / meaning-based retrieval (returns ranked notes; no AI answer).     |
| `note_ask`               | Natural-language Q&A — returns an AI-synthesised answer plus source notes.  |
| `team_list`              | List teams in your organization. Supports `page_size` / `page_token`.      |
| `rimo_auth_status`       | List configured accounts (same shape as `rimo auth status`).                |

**Picking the right retrieval tool**

- `note_search` — exact keywords. Cheapest.
- `note_semantic_search` — describe a concept ("notes about pricing strategy"); ranked notes back, no AI answer.
- `note_ask` — ask a question and get a synthesised answer. Calls the LLM; budget accordingly.

**Reserved arguments** — every Rimo tool accepts these in addition to its own parameters. They mirror the CLI's global flags.

| Argument   | Type    | Effect                                                                      |
|------------|---------|-----------------------------------------------------------------------------|
| `account`  | string  | Use a specific configured account (same as `--account`).                    |
| `fields`   | string  | Comma-separated allowlist of response fields to keep (same as `--fields`).  |
| `excludes` | string  | Comma-separated denylist of response fields to drop (same as `--excludes`). |
| `dry_run`  | boolean | Simulate without side effects (same as `--dry-run`).                        |

- **Multi-account switching.** If you have multiple Rimo accounts, append the alias to your prompt — *"…using my `work` account."* The tool passes `account="work"` and resolves the matching token before the call. (Local `rimo mcp` only; run `rimo_auth_status` first to see the aliases.)
- **Shrinking agent context.** Long notes can blow the agent's context window. Use `fields` or `excludes` to filter responses — most agents apply them on their own if you say *"…and just give me the title, ID, and held_at."*

---

## See also

- [Rimo in Claude](rimo-in-claude.md) / [Rimo in ChatGPT](rimo-in-chatgpt.md) / [Rimo in Microsoft Copilot](rimo-in-microsoft.md) — connect in a web assistant; nothing to install
- [Rimo in Coding Tools](setup-guide.md) — connect in a coding tool on your machine (Claude Code, Codex CLI, Cursor, Claude Desktop)
- [Authentication](authentication.md) — login flows, token storage, multi-account
