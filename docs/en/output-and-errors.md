# Output & errors

[English](../en/output-and-errors.md) | [日本語](../ja/output-and-errors.md)

## JSON-first by design

`rimo` prints JSON to stdout by default — no TTY detection, no table formatting.
The output of a command is the same whether you run it in a terminal or pipe it
into a script, which makes it predictable for both shell pipelines and AI agents.

A few human-facing commands print **plain text** on success instead, because a
JSON wrapper would just get in the way:

- `rimo version` and `rimo upgrade`
- `rimo note ask` (the streamed answer)
- `rimo note get` with `--transcript`, `--document`, `--all`, or `--document-id`

Even for these, **errors are always JSON**, so failures stay machine-readable.

## Field filtering

`--fields` and `--excludes` apply to any command whose output is JSON.

### `--fields`

| Value | Behavior |
|-------|----------|
| `""` (default) | All fields, full values |
| `"compact"` | All fields; long string values replaced with `"[omitted]"` |
| `"f1,f2,f3"` | Only these fields |

```bash
rimo note list --fields compact
rimo note list --fields id,title,created_at
```

### `--excludes`

Comma-separated field names to remove from output. Applied after `--fields`.

```bash
rimo note list --excludes transcript,document_markdown
```

Field filtering is especially useful for AI agents — request only the fields you
need (`--fields id,title`) to keep responses small and cheap to parse.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Authentication / permission error |
| 3 | Not found |
| 4 | Validation error (bad flags/args) |

The exit code is the reliable signal of success vs failure — check it in scripts
rather than parsing output.

## Error format

Any error is written as JSON to stdout and accompanied by a non-zero exit code:

```json
{
  "code": "not_found",
  "message": "note not found: note_abc123"
}
```

| Code | Exit | When |
|------|------|------|
| `error` | 1 | Generic error (network, parse, unexpected) |
| `auth_error` | 2 | Token missing/invalid; run `rimo auth login` |
| `permission_denied` | 2 | Token lacks the required scope (`scope_required` in `details`) |
| `not_found` | 3 | Resource does not exist or is inaccessible |
| `validation_error` | 4 | Bad flag or argument |
| `unknown_command` | 1 | Typo; check `details.suggestion` for the closest match |
