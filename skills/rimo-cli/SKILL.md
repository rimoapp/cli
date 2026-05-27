---
name: rimo-cli
description: "Search and fetch Rimo Voice meeting notes from the CLI for AI agent workflows"
---

# Rimo CLI

The `rimo` CLI wraps the Rimo Voice API so an agent can search, fetch, and ask
about meeting notes. Every command outputs JSON by default.

## Install

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

## Authenticate

```bash
rimo auth login   # OAuth device flow; opens a browser
```

For non-interactive or CI use, set the `RIMO_TOKEN` environment variable instead.

## Common workflows

List notes you participated in, then read one:

```bash
rimo note list --attended
rimo note get <note-id> --document
```

Find notes by meaning, then get a synthesised answer:

```bash
rimo note search "Q3 pricing decision"
rimo note ask "what did we decide about pricing?"
```

## Output and parsing

- JSON on stdout by default. Use `--fields` to keep only the fields you need
  (token-efficient) and `--excludes` to drop fields.
- `rimo note ask` streams a plain-text answer.
- The exit code is non-zero on failure; errors are emitted as JSON on stdout.

## Permissions

`rimo` never returns more than the authenticated user can access:

- `rimo note list` returns notes you own; `--attended` adds notes you
  participated in.
- `rimo note get <id>` fails if you do not have access to that note.
