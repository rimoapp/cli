---
name: rimo-cli
description: Use the `rimo` CLI to interact with the Rimo Voice platform — list/read/search meeting notes, transcripts, and documents, and ask AI questions across them, via the Third-Party API. Trigger when the user mentions Rimo, asks about meeting notes/minutes/transcripts/documents stored in Rimo, or invokes `rimo` directly.
---

# rimo CLI — agent operating manual

`rimo` is a Go CLI that wraps the **Rimo Voice Third-Party API**. It is explicitly designed for AI agents:

- **Always JSON on stdout** (a few narrow plain-text exceptions, see §3).
- **Errors are JSON too**, on stdout — exit code distinguishes success from failure.
- **Field filtering** (`--fields`, `--excludes`) is a first-class feature so you can keep responses small.
- **`--dry-run`** simulates writes without side effects.

If anything below is out of date with the installed binary, prefer `rimo <command> --help`.

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

Tokens are stored in the OS keyring. For agent use, the simplest pattern is the `RIMO_TOKEN` env var:

```bash
export RIMO_TOKEN=...      # takes priority over keyring; used as-is, no refresh
rimo note list
```

Resolution order (first hit wins):

1. `RIMO_TOKEN` env var
2. `--account <alias>` flag → keyring
3. `default_account` in `~/.config/rimo/config.yaml` → keyring
4. Exit 2 with `auth_error` → run `rimo auth login` (or ask the user to)

### If already authenticated

Just use it. `rimo auth status` confirms which account is active and its `token_status` (`valid` / `expiring_soon` / `expired` / `unknown`). Tokens auto-refresh transparently on each call, so you don't need to manage that yourself.

### If not authenticated

In an interactive session with a user present, it is fine to run `rimo auth login` yourself — just walk the user through it. The flow:

1. You run `rimo auth login`.
2. The CLI prints a user code and a verification URI to **stderr**, then waits for the user to press **Enter** before opening the browser. Surface those values to the user verbatim so they can verify the code matches.
3. After the user presses Enter, the CLI opens the browser (`open` on macOS, `xdg-open` on Linux, `start` on Windows) and polls the backend until they finish the consent screen.
4. On success the CLI prints a JSON line to stdout (`{"status":"logged_in", ...}`), stores the token in the OS keyring, and sets the new account as active. You can proceed with the original task.

When to instead ask the user to run it themselves:

- **Headless / CI / no browser** — guide them to set `RIMO_TOKEN` instead.
- **Non-interactive agent run** (no way to relay the stderr code, no human attached) — `rimo auth login` will hang. Bail out and tell the user.
- **User declines** — never push.

If you start `rimo auth login` and it takes more than ~10 minutes the code expires (`token_exchange_failed`) — re-run if the user is still with you.

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

```json
{ "code": "not_found", "message": "note not found: note_abc123" }
```

| Code                | Exit | Meaning                                                     |
|---------------------|------|-------------------------------------------------------------|
| `error`             | 1    | Generic (network, parse, unexpected)                        |
| `auth_error`        | 2    | Token missing/invalid — ask user to `rimo auth login`       |
| `permission_denied` | 2    | Token lacks required scope (see `details.scope_required`)   |
| `not_found`         | 3    | Resource doesn't exist or you can't see it                  |
| `validation_error`  | 4    | Bad flag/arg combo                                          |
| `unknown_command`   | 1    | Typo — check `details.suggestion`                           |

Parse `code` first; do not try to interpret `message` for control flow.

## 5. Commands you can use today

### `rimo note list`

```bash
rimo note list                                  # notes owned by the authenticated user
rimo note list --attended                       # notes the user attended (cursor-paginated)
rimo note list --attended --page-size 50
rimo note list --attended --page-size 50 --page-token "<cursor>"
rimo note list --fields id,title,created_at     # smaller payload
```

- `--page-size` / `--page-token` are **only valid with `--attended`** — passing them in the default mode is a `validation_error`.
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

Mutually exclusive groups (combining them is a `validation_error`):

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

Passing a filter-only flag with `--mode=semantic` is a `validation_error`. Filter mode populates `snippet`, `channel_id`, `owner_name`, `held_at`, `created_at` on each hit; semantic mode returns only `id` and `title` per hit (the semantic backend exposes less metadata). A `Fetch a note:` hint is written to **stderr** so stdout stays pipe-clean for `| jq`.

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

### Not implemented yet — do NOT call

`rimo note delete`, `rimo note share`, `rimo team *`, `rimo user *`, `rimo transcribe *`, `rimo commands` (introspection). If the user asks for one of these, say it's not implemented yet.

## 6. Global flags — use these to keep responses small

| Flag         | Use                                                                       |
|--------------|---------------------------------------------------------------------------|
| `--fields`   | `""` (all), `"compact"` (long strings → `"[omitted]"`), or `"f1,f2,..."` |
| `--excludes` | Drop noisy fields (e.g. `transcript,document_markdown`) — applied after `--fields` |
| `--dry-run`  | Simulate a write — currently no write commands are implemented, so this is mainly future-proofing |
| `--account`  | Override default account                                                  |
| `--token`    | Inline token (prefer `RIMO_TOKEN` env var so it doesn't show up in shell history) |

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

**"What meetings did I attend last week?":**

```bash
rimo note list --attended --page-size 50 --fields id,title,created_at \
  | jq '.notes[] | select(.created_at >= "2026-05-15")'
```

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
- ❌ Don't assume `note delete` / `note share` / `team *` / `user *` / `transcribe *` work — they're not implemented.
- ❌ Don't ignore the exit code. JSON on stdout + nonzero exit = error, not data.
- ❌ Don't pipe `--transcript` / `--document` / `--full` / `--document-id` / `note ask` / `version` / `upgrade` into `jq` — those are plain text on stdout.
- ❌ Don't try `--yes` or any confirmation-skip flag — they don't exist. Safety is enforced via token scopes.
- ❌ Don't run `rimo upgrade` on your own — let the user decide when to update.

## 9. When in doubt

```bash
rimo --help
rimo <command> --help
rimo <command> <subcommand> --help
```

Every command supports `--help` and follows the conventions above.
