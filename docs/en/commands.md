# Commands

[English](../en/commands.md) | [日本語](../ja/commands.md)

Complete reference for every `rimo` command. For installation see
[Installation](installation.md); for the output contract and error format see
[Output & errors](output-and-errors.md).

**Output contract.** All commands print JSON to stdout by default. A few
human-facing commands print plain text on success (errors are always JSON):
`rimo version`, `rimo upgrade`, `rimo note ask`, and `rimo note get` with
`--transcript` / `--document` / `--all` / `--document-id`.

**Global flags** (apply to every command):

| Flag | Description |
|------|-------------|
| `--account` | Account alias to use (overrides `default_account` in config) |
| `--token` | API token (overrides saved credentials; prefer the `RIMO_TOKEN` env var) |
| `--fields` | Fields to include: `""` (all), `"compact"`, or `"f1,f2"` |
| `--excludes` | Comma-separated fields to exclude from output |
| `--dry-run` | Simulate the command without side effects (writes only) |

---

## Authentication

### `rimo auth login`

Authenticate with Rimo using the OAuth 2.0 Device Authorization Grant.

**Syntax**

```
rimo auth login
```

(also available as the top-level `rimo login`.)

**Flow**

1. Prints a user code and a verification URL to stderr.
2. Waits for Enter, then opens your default browser to the verification URL
   (`open` on macOS, `xdg-open` on Linux, `start` on Windows).
3. Waits until you approve the request in your browser.
4. Stores the access + refresh tokens securely using your OS credential store.
5. Registers an alias in `~/.config/rimo/config.yaml` and sets it active.

**Alias generation.** Auto-generated from the email and org name:

| Email | Org name | Generated alias |
|-------|----------|-----------------|
| `alice@rimo.app` | (empty) | `alice-rimo-personal` |
| `alice@rimo.app` | "Client A" | `alice-rimo-client-a` |
| `bob@gmail.com` | "Acme Co" | `bob-gmail-acme-co` |

Re-logging in to the same `(user_id, org_id)` keeps the original alias and
refreshes the metadata.

**Output (stdout, JSON)**

```json
{
  "status": "logged_in",
  "alias": "alice-rimo-personal",
  "email": "alice@rimo.app",
  "name": "Alice",
  "org": "Personal"
}
```

**Errors**

- `device_authorization_failed` — the authorization request was rejected.
- `token_exchange_failed` — the request was not approved, or the code expired.

---

### `rimo auth logout`

Revoke the token (best-effort) and remove the account from config + credential store.

**Syntax**

```
rimo auth logout [--account <alias|email|org>]
```

If `--account` is omitted, the active account is logged out. When no active
account is configured, the command lists saved accounts and asks you to specify
one with `--account`.

**Behavior**

1. Resolves the input to an exact alias (alias, then email, then org name).
2. Calls the revoke endpoint (best-effort — failures are logged to stderr
   but do not abort).
3. Deletes the token from your OS credential store.
4. Removes the account from `config.yaml`. If it was active, the active account is
   cleared (no auto-promotion).

**Output (stdout, JSON)**

```json
{
  "status": "logged_out",
  "alias": "alice-rimo-personal",
  "active_account": ""
}
```

---

### `rimo auth status`

List all saved accounts and their token status.

**Syntax**

```
rimo auth status
```

**Output (stdout, JSON)**

```json
{
  "active_account": "alice-rimo-personal",
  "accounts": [
    {
      "alias": "alice-rimo-personal",
      "email": "alice@rimo.app",
      "name": "Alice",
      "org": "Personal",
      "active": true,
      "token_status": "valid"
    }
  ]
}
```

`token_status` values: `valid`, `expiring_soon`, `expired`, `unknown` (token expiry
could not be determined).

---

### `rimo auth switch`

Switch the active account.

**Syntax**

```
rimo auth switch <alias|email|org-name> [--org <org-name>]
```

Also available as `rimo auth use`.

**Resolution order**

1. Exact alias match.
2. Email match — errors if the email maps to multiple orgs and `--org` is not given.
3. Org-name match within the current email's accounts, then globally.

**Flags**

| Flag | Description |
|------|-------------|
| `--org` | Org name to disambiguate when an email is registered under multiple orgs. |

**Examples**

```bash
rimo auth switch alice-rimo-personal                       # exact alias
rimo auth switch alice@rimo.app                            # by email (errors if multiple orgs)
rimo auth switch "Client A"                                # by org name
rimo auth switch alice@rimo.app --org "Rimo Engineering"   # email + org disambiguation
```

**Output (stdout, JSON)**

```json
{
  "status": "switched",
  "alias": "alice-rimo-client-a",
  "email": "alice@rimo.app",
  "name": "Alice",
  "org": "Client A"
}
```

---

## Notes

**Visibility & permissions.** What the note commands return depends on your access:

- `rimo note list` (default) returns only notes **you own**.
- `rimo note list --attended` returns notes **you participated in**.
- Notes shared with you by URL only (not via ownership or participation) do **not**
  appear in any list, but you can still fetch one directly with
  `rimo note get <id>` if you have the ID.
- `rimo note get` on a note you cannot access returns `not_found` (exit 3) rather
  than revealing that the note exists.

### `rimo note list`

List notes.

**Syntax**

```
rimo note list [--attended] [--page-size <int>] [--page-token <string>]
```

**Default mode.** Lists notes created by the authenticated user.

**`--attended` mode.** Lists notes the authenticated user participated in
(cursor-paginated).

**Flags**

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--attended` | bool | `false` | List notes you participated in |
| `--page-size` | int | `0` | Page size — **only valid with `--attended`** |
| `--page-token` | string | `""` | Cursor from a previous call — **only valid with `--attended`** |

Passing `--page-size` or `--page-token` without `--attended` returns a validation
error.

**Examples**

```bash
rimo note list
rimo note list --fields id,title,created_at
rimo note list --attended --page-size 50
rimo note list --attended --page-size 50 --page-token "eyJpZCI6..."
```

**Output (stdout, JSON)**

```json
{
  "notes": [
    {
      "id": "note_abc123",
      "title": "Weekly sync",
      "created_at": "2026-05-12T08:30:00Z",
      "owner": { "email": "alice@rimo.app" }
    }
  ],
  "next_page_token": "..."
}
```

---

### `rimo note get`

Get a single note. Default output is metadata JSON; flags switch into
content-rendering modes.

**Syntax**

```
rimo note get <note_id> [flags]
```

**Flags**

| Flag | Description |
|------|-------------|
| `--transcript` | Print the transcript as plain text in `Speaker: content` form. |
| `--document` | Print the primary document as markdown plain text. |
| `--all` | Print transcript followed by the primary document. |
| `--list-documents` | List documents attached to the note (JSON). |
| `--document-id <id>` | Print a specific document's markdown by ID. |

**Mutual exclusivity**

- `--list-documents` / `--document-id` cannot be combined with `--transcript` /
  `--document` / `--all`.
- `--list-documents` and `--document-id` are mutually exclusive.

The content flags (`--transcript`, `--document`, `--all`, `--document-id`) print
plain text to stdout because transcript and document text is meant to be read or
piped, not parsed. Errors are still JSON, so a missing-note error stays
machine-readable.

**Examples**

```bash
rimo note get note_abc123                          # metadata JSON
rimo note get note_abc123 --transcript             # plain-text transcript
rimo note get note_abc123 --document               # primary document markdown
rimo note get note_abc123 --all                    # transcript + document
rimo note get note_abc123 --list-documents         # JSON list of documents
rimo note get note_abc123 --document-id doc_xyz    # specific document markdown
rimo note get note_abc123 --fields id,title        # filter the JSON metadata
```

**Errors**

- `not_found` (exit 3) — note ID does not exist or you do not have access.
- `permission_denied` (exit 2) — token lacks the `notes:read` scope.
- `validation_error` (exit 4) — incompatible flag combination.

---

### `rimo note search`

Find notes by semantic similarity (default) or keyword filter. Returns JSON in the
same `{notes, total_count}` shape as `rimo note list`. Use
[`rimo note ask`](#rimo-note-ask) when you want a synthesised answer instead of a
list.

**Syntax**

```
rimo note search <query> [--mode=semantic|filter] [flags]
```

**Flags**

| Flag | Description |
|------|-------------|
| `--mode` | `semantic` (default) ranks notes by meaning; `filter` does keyword search with pagination. |
| `--limit` | Max results for `--mode=semantic` (defaults to server-side). |
| `--page` | Page number for `--mode=filter` (1-based, default 1). |
| `--per` | Page size for `--mode=filter` (default 10). |
| `--content-type` | Limit `--mode=filter` to one of: `all` `transcripts` `headings` `annotations` `title` `document`. |

**Output**

JSON `{notes: [...], total_count: <int>}` on stdout. A `Fetch a note:` hint is
printed to **stderr** so stdout stays pipe-clean for `| jq`.

```json
{
  "notes": [
    { "id": "wn9K...", "title": "Release plan: Q3 launch", "owner_name": "Aditya Ghai", "held_at": "2026-04-28T09:21:00Z" }
  ],
  "total_count": 12
}
```

Filter mode populates `snippet`, `channel_id`, `owner_name`, `held_at`,
`created_at` on each hit; semantic mode only populates `id` and `title` because
semantic search returns less metadata per result.

**Examples**

```bash
rimo note search "release plan"                                # semantic (default)
rimo note search "release plan" --limit 5
rimo note search "release" --mode=filter --per 5 --content-type transcripts
rimo note search "release" --mode=filter | jq '.notes[].id'
```

**Errors**

- `validation_error` (exit 4) — empty query, invalid `--mode`/`--content-type`, or
  filter-only flags with `--mode=semantic`.
- `permission_denied` (exit 2) — token lacks the `notes:read` scope.

---

### `rimo note ask`

Ask a natural-language question and get an AI-synthesised answer drawn from your
notes. This is the only command that generates an AI answer.

**Syntax**

```
rimo note ask <question>
```

No flags. The model is fixed server-side.

**Output (plain text, streamed)**

```
The release is planned for Q3, with grandfathered pricing for existing
annual contracts until renewal.

Sources:
  - wn9K36p46RKJKaktjDvA  Pricing sync 2026-04-28
  - 3K72YiEy2dEius6xpTHy  Q3 planning offsite

Fetch a note:
  rimo note get wn9K36p46RKJKaktjDvA --document      # markdown
  rimo note get wn9K36p46RKJKaktjDvA --transcript    # speaker: text
  rimo note get wn9K36p46RKJKaktjDvA                 # metadata JSON
```

The answer streams as the model generates it. The `Sources:` block is the
canonical citation surface.

**When to use which**

- `rimo note search` — when you'd open the returned notes and read them yourself.
- `rimo note ask` — when you'd open them to extract a single answer.

**Examples**

```bash
rimo note ask "what did we decide about Q3 pricing?"
rimo note ask "今週の議事録を要約して"
```

**Errors**

- `validation_error` (exit 4) — empty question.
- `permission_denied` (exit 2) — token lacks the `notes:read` scope.

---

## Misc

### `rimo version`

Print the CLI version.

**Syntax**

```
rimo version
```

**Output (stdout, plain text)**

```
rimo version v1.0.0
```

---

### `rimo upgrade`

Self-upgrade the installed binary to the latest GitHub release.

**Syntax**

```
rimo upgrade [--check] [--version <tag>] [--use-sudo]
```

**Flags**

| Flag | Description |
|------|-------------|
| `--check` | Report whether an update is available; do not download or install. |
| `--version <tag>` | Install a specific tag instead of "latest". Useful for pinned downgrades. |
| `--use-sudo` | Retry via `sudo install -m 0755` if the install path is not writable. Opt-in. |

**Output (stdout, plain text)**

One of:

```
Already on the latest version (v1.0.0).
Update available: v1.0.0 → v1.1.0. Run: rimo upgrade
Upgraded rimo from v1.0.0 → v1.1.0.
```

Progress messages go to **stderr**, so a script capturing stdout sees only the
final status line.

**Examples**

```bash
rimo upgrade --check                   # is there a newer release?
rimo upgrade                           # latest
rimo upgrade --version v1.1.0          # specific tag
sudo rimo upgrade --use-sudo           # retry under sudo for root-owned install dirs
```

**Errors**

- `permission_denied` (exit 2) — the install path is not writable and `--use-sudo`
  was not passed. `details.suggested_command` is `sudo rimo upgrade --use-sudo`.
- General `error` (exit 1) — dev-build refusal, download failure (asset not found
  for OS/arch, network), or extract failure.

**Startup update notice**

Every invocation runs a non-blocking background version check. If a newer release
is available, a single line is written to **stderr** (never stdout):

```
rimo: update available v1.0.0 → v1.1.0 (run: rimo upgrade)
```

The notice is suppressed when the binary is a local dev build, when
`RIMO_NO_UPDATE_CHECK` is set, when `CI` is set, or for the `upgrade`, `version`,
and `--help` invocations. The result is cached for 24 hours.
