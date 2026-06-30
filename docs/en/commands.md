# Commands

[English](../en/commands.md) | [日本語](../ja/commands.md)

Complete reference for every `rimo` command. For installation see
[Installation](installation.md); for the output contract and error format see
[Output & errors](output-and-errors.md).

**Output contract.** All commands print JSON to stdout by default. A few
human-facing commands print plain text on success (errors are always JSON):
`rimo version`, `rimo upgrade`, `rimo note ask`, and `rimo note get` with
`--transcript` / `--document` / `--full` / `--meeting-chat` / `--document-id`.

**Global flags** (apply to every command):

| Flag | Description |
|------|-------------|
| `--account` | Account alias to use (overrides `active_account` in config) |
| `--fields` | Fields to include: `""` (all), `"compact"`, or `"f1,f2"` |
| `--excludes` | Comma-separated fields to exclude from output |
| `--dry-run` | Simulate the command without side effects (writes only) |

---

## Authentication

### `rimo auth login`

Authenticate with Rimo through a browser-based login.

**Syntax**

```
rimo auth login
```

(also available as the top-level `rimo login`.)

**Flow**

By default, `rimo auth login` opens your browser:

1. Opens your default browser to authorize this CLI.
2. Waits for you to sign in if needed and approve the request.
3. Stores the access + refresh tokens securely using your OS credential store.
4. Registers an alias in `~/.config/rimo/config.yaml` and sets it active.

**`--no-browser` flow**

For machines without a usable browser:

1. Prints a URL to stderr.
2. Open the URL on any other device, sign in if needed and approve; the page
   shows a short code.
3. Paste the code back into the terminal at the prompt.
4. Stores tokens and registers the alias as above.

**Flags**

| Flag | Description |
|------|-------------|
| `--no-browser` | Print a URL to open on another device, then paste the displayed code back into the terminal. |

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

---

### `rimo auth logout`

Revoke the token and remove the account from config + credential store.

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

1. Exact `alias` match.
2. `email` match — errors if the `email` maps to multiple orgs and `--org` is not given.
3. `org-name` match — orgs belonging to the currently active email are preferred.

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

What the note commands return depends on your access:

- `rimo note list` (default) returns only notes **you own**.
- `rimo note list --attended` returns notes **you participated in**.
- `rimo note list --team <id>` returns **a team's notes across all its members**
  (you must be a member of that team). Get team IDs with `rimo team list`.
- Notes shared with you by URL only (not via ownership or participation) do **not**
  appear in any list, but you can still fetch one directly with
  `rimo note get <id>` if you have the ID.
- `rimo note get` on a note you cannot access returns a not-found error rather
  than revealing that the note exists.

### `rimo note list`

List notes.

**Syntax**

```
rimo note list [--attended] [--team <id>] [--since <date>] [--until <date>]
               [--updated-since <date>] [--page-size <int>] [--page-token <string>]
```

**Default mode.** Lists notes created by the authenticated user.

**`--attended` mode.** Lists notes the authenticated user participated in.

**`--team` mode.** Lists a team's notes across all its members. You must be a
member of the team; otherwise the request is rejected. `--attended` cannot be
combined with `--team` or the date filters.

`--since` / `--until` filter by meeting time — a note's `held_at`, or its
creation time if it has none. `--updated-since` filters by when a note was last
updated, so you can fetch only what changed since your last run. Dates accept
`YYYY-MM-DD` (read as JST) or an RFC3339 timestamp. `--until` is exclusive: a
note held on the `--until` date itself is not returned.

All modes are paginated via `--page-size` and `--page-token`.

**Flags**

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--attended` | bool | `false` | List notes you participated in |
| `--team` | string | `""` | List a team's notes across its members (team ID from `rimo team list`) |
| `--since` | string | `""` | Only notes held on or after this date (`YYYY-MM-DD` or RFC3339) |
| `--until` | string | `""` | Only notes held before this date (`YYYY-MM-DD` or RFC3339) |
| `--updated-since` | string | `""` | Only notes updated on or after this date (`YYYY-MM-DD` or RFC3339) |
| `--page-size` | int | `0` | Page size (`0` lets the server pick the default) |
| `--page-token` | string | `""` | Cursor from a previous call's `next_page_token` |

**Examples**

```bash
rimo note list
rimo note list --fields id,title,created_at
rimo note list --page-size 50
rimo note list --attended --page-size 50
rimo note list --attended --page-size 50 --page-token "eyJpZCI6..."
rimo note list --team J9yyjDQLJWqhiSTH0sAT --since 2026-06-01 --until 2026-07-01
rimo note list --team J9yyjDQLJWqhiSTH0sAT --updated-since 2026-06-08
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

Get a single note. By default, only metadata is output as JSON. Additional flags
let you retrieve the transcript or document content.

**Syntax**

```
rimo note get <note_id> [flags]
```

**Flags**

| Flag | Description |
|------|-------------|
| `--transcript` | Print the transcript as plain text in `Speaker: content` form. |
| `--document` | Print the primary document as markdown plain text. |
| `--full` | Print transcript followed by the primary document. |
| `--meeting-chat` | Print the web meeting chat (Zoom/Meet, captured via Recall) as plain text in `[HH:MM] sender: text` form. |
| `--list-documents` | List documents attached to the note (JSON). |
| `--document-id <id>` | Print a specific document's markdown by ID. |

**Notes**

- `--list-documents` / `--document-id` cannot be combined with `--transcript` /
  `--document` / `--full`.
- `--list-documents` and `--document-id` are mutually exclusive.
- `--meeting-chat` is its own output and cannot be combined with `--transcript` /
  `--document` / `--full` / `--list-documents` / `--document-id`.
- The content flags (`--transcript`, `--document`, `--full`, `--meeting-chat`,
  `--document-id`) print plain text to stdout, not JSON.

**Examples**

```bash
rimo note get note_abc123                          # metadata JSON
rimo note get note_abc123 --transcript             # plain-text transcript
rimo note get note_abc123 --document               # primary document markdown
rimo note get note_abc123 --full                    # transcript + document
rimo note get note_abc123 --meeting-chat           # plain-text Zoom/Meet chat
rimo note get note_abc123 --list-documents         # JSON list of documents
rimo note get note_abc123 --document-id doc_xyz    # specific document markdown
rimo note get note_abc123 --fields id,title        # filter the JSON metadata
```

**Errors**

See [Output & errors](output-and-errors.md) for the error JSON shape and exit code.

---

### `rimo note search`

Find notes by semantic similarity (default), or by keyword and attribute filter.
Returns JSON in the same `{notes, total_count}` shape as `rimo note list`. Use
[`rimo note ask`](#rimo-note-ask) when you want a synthesised answer instead of a
list.

**Syntax**

```
rimo note search [query] [--mode=semantic|filter] [flags]
```

In `--mode=filter` the `query` is **optional**: omit it to browse by filters alone
(team, date range, participant, tag), newest first.

**Flags**

| Flag | Description |
|------|-------------|
| `--mode` | `semantic` (default) ranks notes by meaning; `filter` does keyword and/or attribute search with pagination. |
| `--limit` | Max results for `--mode=semantic`. |
| `--page` | Page number for `--mode=filter` (1-based, default 1). |
| `--per` | Page size for `--mode=filter` (default 10, max 100). |
| `--content-type` | Limit `--mode=filter` to one of: `all` `transcripts` `headings` `annotations` `title` `document`. |
| `--team` | `--mode=filter` only: restrict to one or more teams. Repeatable or comma-separated; team IDs come from `rimo team list`. |
| `--participant` | `--mode=filter` only: restrict to notes with these participant user IDs. Repeatable or comma-separated. |
| `--note-tag` | `--mode=filter` only: restrict to notes with these tag IDs. Repeatable or comma-separated. |
| `--since` | `--mode=filter` only: only notes held on or after this date. `YYYY-MM-DD` (interpreted as JST) or an RFC3339 timestamp. |
| `--until` | `--mode=filter` only: only notes held before this date. Same formats as `--since`. |

**Output**

JSON `{notes: [...], total_count: <int>}` on stdout. A `Fetch a note:` hint is
printed to **stderr** so stdout stays pipe-clean for `| jq`.

```json
{
  "notes": [
    { "id": "wn9K...", "title": "Release plan: Q3 launch", "owner_name": "Alice Smith", "held_at": "2026-04-28T09:21:00Z" }
  ],
  "total_count": 12
}
```

Filter mode includes `snippet`, `channel_id`, `owner_name`, `held_at`,
`created_at` on each result; semantic mode only includes `id` and `title` because
semantic search returns less metadata per result.

**Examples**

```bash
rimo note search "release plan"                                # semantic (default)
rimo note search "release plan" --limit 5
rimo note search "release" --mode=filter --per 5 --content-type transcripts
rimo note search "release" --mode=filter --team T_abc123        # keyword, scoped to a team
rimo note search --mode=filter --team T_abc --since 2026-04-01  # filter-only browse (no query)
rimo note search --mode=filter --since 2026-04-01 --until 2026-07-01
rimo note search "release" --mode=filter | jq '.notes[].id'
```

**Errors**

See [Output & errors](output-and-errors.md) for the error JSON shape and exit code.

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

See [Output & errors](output-and-errors.md) for the error JSON shape and exit code.

---

## Teams

### `rimo team list`

List teams in your organization. The returned team IDs can be passed to
`rimo note list --team <id>` to list a team's notes across all its members.

**Syntax**

```
rimo team list [--page-size <int>] [--page-token <string>]
```

**Flags**

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--page-size` | int | `0` | Page size (`0` lets the server pick the default, currently 20) |
| `--page-token` | string | `""` | Cursor from a previous call's `next_page_token` |

**Examples**

```bash
rimo team list
rimo team list --page-size 5
rimo team list --page-size 5 --page-token "eyJpZCI6..."
rimo team list --fields id,name
```

**Output (stdout, JSON)**

```json
{
  "teams": [
    { "id": "team_abc123", "name": "Engineering" },
    { "id": "team_def456", "name": "Design" }
  ],
  "next_page_token": "..."
}
```

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
rimo version 1.0.0
```

---

### `rimo upgrade`

Upgrade the installed binary to the latest release.

`rimo upgrade` always installs the **latest** release — there is no flag to pin or downgrade to an older version. The release archive is downloaded over HTTPS and its checksum is verified against the release's `checksums.txt` before the running binary is replaced; no login is required.

**Syntax**

```
rimo upgrade [--check] [--use-sudo]
```

**Flags**

| Flag | Description |
|------|-------------|
| `--check` | Report whether an update is available; do not download or install. |
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
sudo rimo upgrade --use-sudo           # retry under sudo for root-owned install dirs
```

**Errors**

See [Output & errors](output-and-errors.md) for the error JSON shape and exit code.

**Startup update notice**

Every invocation runs a non-blocking background version check. If a newer release
is available, a single line is written to **stderr** (never stdout):

```
rimo: update available v1.0.0 → v1.1.0 (run: rimo upgrade)
```

The notice is suppressed when the binary is a local dev build, when
`RIMO_NO_UPDATE_CHECK` is set, when `CI` is set, or for the `upgrade`, `version`,
and `--help` invocations. The result is cached for 24 hours.
