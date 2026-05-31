---
name: rimo-cli
description: Use the `rimo` CLI to interact with the Rimo Voice platform — list/read/search meeting notes, transcripts, and documents, and ask AI questions across them. Trigger when the user mentions Rimo, asks about meeting notes/minutes/transcripts/documents stored in Rimo, or invokes `rimo` directly.
---

# rimo CLI Skill

This skill teaches AI coding agents (Claude Code, Codex, and others) how to use the [`rimo` command-line tool](https://github.com/rimoapp/cli) to access [Rimo Voice](https://rimo.app) meeting notes, transcripts, documents, and AI-powered Q&A — all from the terminal.

`rimo` is purpose-built for both humans and AI agents:

- **JSON-first** on stdout (a few narrow plain-text exceptions, see §3 below).
- **Errors are JSON too**, on stdout — exit code distinguishes success from failure.
- **Field filtering** (`--fields`, `--excludes`) is a first-class feature so responses stay small.
- **`--dry-run`** simulates writes without side effects.

If anything below is out of date with the installed binary, prefer `rimo <command> --help`.

---

## Using this skill

This skill works with any AI agent that can read markdown documentation and execute shell commands.

### With Claude Code

Claude Code auto-discovers skills placed in either of these locations:

```bash
# Project-local (recommended for team-shared usage — commit to your repo)
mkdir -p .claude/skills/rimo-cli
curl -fsSL https://raw.githubusercontent.com/rimoapp/cli/main/skills/rimo-cli/SKILL.md \
  -o .claude/skills/rimo-cli/SKILL.md

# Or user-global (available across all your projects)
mkdir -p ~/.claude/skills/rimo-cli
curl -fsSL https://raw.githubusercontent.com/rimoapp/cli/main/skills/rimo-cli/SKILL.md \
  -o ~/.claude/skills/rimo-cli/SKILL.md
```

Then just ask naturally in Claude Code:

> "Summarize my Rimo notes from this week"
> "Find my Rimo notes about the Q3 release plan"

Claude Code loads the skill automatically when it detects a Rimo-related request.

### With Codex (or other AI agents)

For agents that don't auto-load skills, point them at this file at the start of a session:

```bash
# Hand the skill to the agent as context
cat ~/.claude/skills/rimo-cli/SKILL.md
```

Or include the contents of this file in the agent's system/initial prompt. Any agent that can run shell commands and read documentation can follow the operating manual below.

### Prerequisites

Make sure `rimo` is installed and you have an authenticated session:

```bash
# Install
curl -fsSL https://rimo.app/cli/install.sh | sh

# Authenticate — opens your browser, token is saved securely in the OS keyring
rimo auth login

# Verify
rimo auth status
```

---

# Agent operating manual

Everything below is intended for the AI agent driving the CLI.

## 1. Check before doing anything

```bash
rimo version          # confirm the binary exists, see the installed version
rimo auth status      # confirm there is an authenticated account
```

If `rimo` is not on `PATH`, stop and tell the user to install it:

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

(Or download the archive for their OS/arch from <https://github.com/rimoapp/cli/releases>, verify it against the published `checksums.txt`, and put `rimo` on their `PATH`.) Do not try to install it silently.

## 2. Authentication

The recommended way to authenticate is `rimo auth login`. It opens the browser, completes a secure consent flow, and stores the token in the OS keyring. Tokens auto-refresh transparently on every call, so the agent does not need to manage refresh.

### Recommended: `rimo auth login` (browser-based)

In an interactive session with a user present, it is fine to run `rimo auth login` yourself — just walk the user through it. The flow:

1. You run `rimo auth login`.
2. The CLI opens the user's default browser to authorize this CLI.
3. The user signs in if needed and approves the request.
4. On success the CLI prints a JSON line to stdout (`{"status":"logged_in", ...}`), stores the token in the OS keyring, and sets the new account as active. You can proceed with the original task.

If the user is on a machine without a usable browser (SSH, container, headless CI), run `rimo auth login --no-browser` instead: the CLI prints a URL, the user opens it on any other device, approves, and pastes the short code from the page back into the terminal.

If `rimo auth login` takes more than ~10 minutes the code expires — re-run if the user is still with you.

When to instead ask the user to run it themselves:

- **Non-interactive agent run** (no human attached to relay the stderr code) — `rimo auth login` will hang. Bail out and tell the user.
- **User declines** — never push.

### Token resolution order (first hit wins)

1. `--account <alias>` flag → keyring
2. `default_account` in `~/.config/rimo/config.yaml` → keyring
3. Otherwise the command exits 1 with a JSON error to stdout — run `rimo auth login` (or ask the user to)

### If already authenticated

Just use it. `rimo auth status` confirms which account is active and its `token_status` (`valid` / `expiring_soon` / `expired` / `unknown`). Tokens auto-refresh transparently on each call.

### Other account ops (only when the user asks)

```bash
rimo auth status                    # JSON list of accounts + token_status
rimo auth switch <alias|email|org>  # change active account
rimo auth logout [--account <id>]   # revoke + remove
```

## 3. Output contract

| Surface           | Format             |
|-------------------|--------------------|
| Success (default) | JSON on stdout     |
| Errors            | JSON on stdout (always, regardless of mode) |
| `rimo version`    | Plain text on stdout |
| `rimo upgrade`    | Plain text on stdout; progress on stderr |
| `rimo note get --transcript / --document / --full / --document-id` | Plain text on stdout |
| `rimo note ask <question>` | Plain text on stdout (streamed); `Sources:` / `Fetch a note:` blocks follow |

Everything you pipe to `jq` is safe **except** the plain-text exceptions above. For plain-text modes, treat stdout as opaque markdown/text.

## 4. Error format

Any failure writes a JSON error to **stdout** and exits with code 1:

```json
{ "code": "error", "message": "unknown flag: --bogus" }
```

`code` is currently always `error`. Inspect `message` for the cause
(validation text, API status, etc.) and surface it to the user. Treat the
exit code (0 vs non-zero) as the reliable success/failure signal — do not
parse `message` for control flow.

## 5. Commands you can use today

### `rimo note list`

```bash
rimo note list                                  # notes owned by the authenticated user
rimo note list --attended                       # notes the user attended
rimo note list --page-size 50
rimo note list --attended --page-size 50 --page-token "<cursor>"
rimo note list --fields id,title,created_at     # smaller payload
```

- Both modes are cursor-paginated via `--page-size` / `--page-token`.
- Response shape: `{ "notes": [...], "next_page_token": "..." }`. Loop until `next_page_token` is empty when you need everything.

### `rimo note get`

Default mode = metadata JSON (backend gets `meta=true`, so it's cheap).

**Note ID, not URL.** This command (and every other `rimo note ...` command that takes an ID) accepts only the raw note ID, never a URL. If the user pastes a link like `https://rimo.app/notes/iYEMKt5JzQATX6pozGvF`, the ID is the path segment **after** `/notes/` — here `iYEMKt5JzQATX6pozGvF`. Strip the prefix yourself before calling the CLI; do not pass the URL.

```bash
rimo note get <note_id>                        # metadata JSON
rimo note get <note_id> --fields id,title      # filter the metadata JSON
rimo note get <note_id> --transcript           # plain text: "Speaker: content" lines
rimo note get <note_id> --document             # plain text: primary document markdown
rimo note get <note_id> --full                 # plain text: transcript + document
rimo note get <note_id> --list-documents       # JSON list of attached documents
rimo note get <note_id> --document-id <doc_id> # plain text: specific document markdown
```

Mutually exclusive groups (combining them is rejected with an error):

- `--list-documents` / `--document-id` ⛔ `--transcript` / `--document` / `--full`
- `--list-documents` ⛔ `--document-id`

When the user asks "summarize this Rimo note", the cheapest correct flow is usually:

```bash
rimo note get <note_id> --full     # one call, transcript + document as text
```

### `rimo note search`

Find notes by semantic similarity (default) or keyword filter. Returns JSON in the same `{notes, total_count}` shape as `rimo note list` — use this when you want a *list of candidate notes*. Use `rimo note ask` when you want a synthesised answer instead.

```bash
rimo note search "release plan"                                # semantic (default)
rimo note search "release plan" --limit 5                      # cap semantic results
rimo note search "release" --mode=filter --per 5 --content-type transcripts
rimo note search "release" --mode=filter --page 2 --per 20
rimo note search "release" --fields id,title | jq '.notes'
```

Flags:

| Flag             | Mode     | Meaning                                                                 |
|------------------|----------|-------------------------------------------------------------------------|
| `--mode`         | both     | `semantic` (default, meaning-based) or `filter` (keyword + pagination). |
| `--limit`        | semantic | Max results (defaults to server-side).                                  |
| `--page`         | filter   | 1-based page number (defaults to 1).                                    |
| `--per`          | filter   | Page size (defaults to 10).                                             |
| `--content-type` | filter   | Restrict to `all`/`transcripts`/`headings`/`annotations`/`title`/`document`. |

Passing a filter-only flag with `--mode=semantic` is rejected with an error. Filter mode populates `snippet`, `channel_id`, `owner_name`, `held_at`, `created_at` on each hit; semantic mode returns only `id` and `title` per hit (the semantic backend exposes less metadata). A `Fetch a note:` hint is written to **stderr** so stdout stays pipe-clean for `| jq`.

### `rimo note ask`

The only command that calls the LLM. Streams a synthesised plain-text answer drawn from the user's notes.

```bash
rimo note ask "what did we decide about Q3 pricing?"
rimo note ask "今週の議事録を要約して"
```

No flags — the model is fixed server-side. Output structure:

```
<streamed plain-text answer, multiple lines>

Sources:
  - <note_id>  <title>
  - <note_id>  <title>

Fetch a note:
  rimo note get <note_id> --document      # markdown
  rimo note get <note_id> --transcript    # speaker: text
  rimo note get <note_id>                 # metadata JSON
  other IDs in this result: <id> <id> ...
```

Inline `[xxxxx]` chunk-ref citations the model emits are stripped from the visible answer — treat the `Sources:` block as the canonical citation surface. Pipe the IDs from there into `rimo note get` when the user wants to drill in.

**Choose between search and ask:**

- `rimo note search` — when the user would open the returned notes one by one and read them.
- `rimo note ask` — when the user wants a *single answer* extracted from across notes.

### `rimo version` / `rimo upgrade`

Plain text. `rimo upgrade` downloads the latest release over HTTPS and verifies its checksum before replacing the binary — no GitHub login or extra tooling is required, and there is no flag to pin or downgrade. Do not run `rimo upgrade` autonomously — let the user trigger it.

### Support under development

The following commands are planned but not yet available — support is under active development. If the user asks for one of these, let them know it is coming soon and avoid calling them:

- `rimo note delete`, `rimo note share`
- `rimo team *`, `rimo user *`
- `rimo transcribe *`
- `rimo commands` (introspection)

## 6. Global flags — use these to keep responses small

| Flag         | Use                                                                       |
|--------------|---------------------------------------------------------------------------|
| `--fields`   | `""` (all), `"compact"` (long strings → `"[omitted]"`), or `"f1,f2,..."` |
| `--excludes` | Drop noisy fields (e.g. `transcript,document_markdown`) — applied after `--fields` |
| `--dry-run`  | Simulate a write — currently no write commands are implemented, so this is mainly future-proofing |
| `--account`  | Override default account                                                  |

```bash
rimo note list --fields compact
rimo note list --fields id,title,created_at
rimo note list --excludes transcript,document_markdown
```

## 7. Recipes

**"List my recent notes":**

```bash
rimo note list --fields id,title,created_at | jq '.notes[:10]'
```

**"Show the transcript of note X":**

```bash
rimo note get <note_id> --transcript
```

**"Summarize note X":** fetch transcript + document, then summarize from the text yourself.

```bash
rimo note get <note_id> --full
```

**"What meetings did I attend last week?":** the CLI does **not** interpret relative dates — you must convert "last week", "yesterday", etc. into absolute `YYYY-MM-DD` values yourself (using today's date from your context), then filter with `jq`.

```bash
# Step 1: compute the absolute date range from today.
#   Example — if today is 2026-05-28 (Thu), "last week" spans 2026-05-18 (Mon) → 2026-05-24 (Sun).
# Step 2: pull the attended notes and filter on created_at.
rimo note list --attended --page-size 50 --fields id,title,created_at \
  | jq '.notes[] | select(.created_at >= "2026-05-18" and .created_at < "2026-05-25")'
```

The same pattern works for any time range — always substitute the absolute start/end dates, never pass relative phrases to `jq` or the CLI.

**"Find me notes about X":** prefer search (cheap, list back) over ask (LLM, single answer).

```bash
rimo note search "<topic>" --fields id,title
```

**"What did we decide about X across all our meetings?":** this is the ask case.

```bash
rimo note ask "<question>"
```

## 8. Things NOT to do

- ❌ Don't run `rimo auth login` in a non-interactive context (CI, headless, no human attached) — it blocks on Enter and a browser flow. In an interactive session it's fine; see §2.
- ❌ Don't hit the Rimo backend with raw `curl` — use `rimo`. The CLI handles token resolution, refresh, and error normalization.
- ❌ Don't assume `note delete` / `note share` / `team *` / `user *` / `transcribe *` work — support is still under development.
- ❌ Don't ignore the exit code. JSON on stdout + nonzero exit = error, not data.
- ❌ Don't pipe `--transcript` / `--document` / `--full` / `--document-id` / `note ask` / `version` / `upgrade` into `jq` — those are plain text on stdout.
- ❌ Don't try `--yes` or any confirmation-skip flag — they don't exist. Safety is enforced via token scopes.
- ❌ Don't run `rimo upgrade` on your own — let the user decide when to update.
- ❌ Don't pass relative dates ("last week", "yesterday") to `jq` filters or CLI flags — convert to absolute `YYYY-MM-DD` first.

## 9. When in doubt

```bash
rimo --help
rimo <command> --help
rimo <command> <subcommand> --help
```

Every command supports `--help` and follows the conventions above.
