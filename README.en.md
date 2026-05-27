# rimo

[English](README.en.md) | [日本語](README.md)

`rimo` is the command-line interface for the [Rimo Voice](https://rimo.app) platform. It wraps the Rimo Voice API so you can search, fetch, and ask questions about your meeting notes from the terminal.

Built for both humans and AI agents (Claude Code, Codex, etc.): every command speaks JSON by default and exposes its behavior through `--help`, so it slots cleanly into scripts and agent workflows.

## Install

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

This installs the latest `rimo` binary to `~/.local/bin` (no `sudo` required). See [Installation](docs/en/installation.md) for other options, version pinning, upgrades, and uninstall.

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
| [`rimo auth login`](docs/en/commands.md#rimo-auth-login)   | Authenticate via OAuth Device Authorization Grant |
| [`rimo auth logout`](docs/en/commands.md#rimo-auth-logout) | Revoke tokens and remove a saved account |
| [`rimo auth status`](docs/en/commands.md#rimo-auth-status) | Show authenticated accounts |
| [`rimo auth switch`](docs/en/commands.md#rimo-auth-switch) | Switch the active account |
| [`rimo note list`](docs/en/commands.md#rimo-note-list)     | List notes (`--attended` for notes you participated in) |
| [`rimo note get`](docs/en/commands.md#rimo-note-get)       | Get a note by ID (metadata, transcript, or document) |
| [`rimo note search`](docs/en/commands.md#rimo-note-search) | Find notes by semantic similarity or keyword |
| [`rimo note ask`](docs/en/commands.md#rimo-note-ask)       | Ask a question and get an AI-synthesised answer |
| [`rimo version`](docs/en/commands.md#rimo-version)         | Print the CLI version |
| [`rimo upgrade`](docs/en/commands.md#rimo-upgrade)         | Self-upgrade to the latest release |

Full flag-by-flag reference: [Commands](docs/en/commands.md).

## Global flags

```
--account <alias>    Account alias to use (overrides default_account in config)
--token <string>     API token (overrides saved credentials; prefer the RIMO_TOKEN env var)
--fields <spec>      Fields to include: "" (all), "compact", or "field1,field2"
--excludes <list>    Comma-separated fields to exclude from output
--dry-run            Simulate the command without side effects (writes only)
```

## Documentation

- [Installation](docs/en/installation.md) — install, pin a version, upgrade, uninstall
- [Authentication](docs/en/authentication.md) — device-grant login, accounts, `RIMO_TOKEN` for CI
- [Commands](docs/en/commands.md) — full reference with flags and examples
- [Configuration](docs/en/configuration.md) — `config.yaml`, credential storage, environment variables
- [Output & errors](docs/en/output-and-errors.md) — JSON design, `--fields`/`--excludes`, exit codes

## AI agents

`rimo` ships a [Claude Code skill](skills/rimo-cli/SKILL.md) so agents can install, authenticate, and pull note content autonomously.

## Support

Found a bug or have a feature request? Open an issue in this repository.
