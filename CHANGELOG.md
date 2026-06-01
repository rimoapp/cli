# Changelog

All notable changes to the Rimo CLI are documented here. This project follows
[Semantic Versioning](https://semver.org/).

## v1.0.0 — 2026-06-01

Initial public release.

### Added

- `rimo auth login` / `logout` / `switch` / `status` — browser-based login
  with credentials stored in your OS keyring.
- `rimo note list` — list your notes (`--attended` for notes you participated in).
- `rimo note get` — fetch a note by ID (metadata, transcript, or document).
- `rimo note search` — find notes by semantic similarity or keyword.
- `rimo note ask` — ask a question and get an AI-synthesised answer from your notes.
- `rimo version` — print the CLI version.
- JSON-first output with `--fields` / `--excludes` filtering and `--dry-run`.
- Install script: `curl -fsSL https://rimo.app/cli/install.sh | sh`.
