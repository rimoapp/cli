# Changelog

All notable changes to the Rimo CLI are documented here. This project follows
[Semantic Versioning](https://semver.org/).

## v1.2.0

### Added

- Claude Code plugin — install the `rimo` agent skill in one command with
  `/plugin marketplace add rimo/cli`, then `/plugin install rimo@rimo`.
- `rimo note list` — new filters: `--team` lists a team's notes across its
  members, and `--since` / `--until` / `--updated-since` filter notes by date.

## v1.1.0

### Added

- `rimo team list` — list the teams you belong to (paged automatically for
  large accounts).
- Windows installation support — you can now install rimo on Windows via
  PowerShell. See the installation guide for the command.

### Fixed

- `rimo upgrade` now retries automatically when a download is interrupted, so a
  brief network problem no longer makes the upgrade fail.
- `rimo auth` commands now show a clear error when `--dry-run` is used, since
  that option does not apply to them.

## v1.0.1

### Fixed

- `--fields` and `--excludes` now apply consistently across every command,
  including `rimo note search`. List and object responses keep their metadata
  (e.g. `total_count`) while the records inside are filtered.
- `rimo auth status` now refreshes renewable tokens before reporting, so an
  account whose session is still valid is shown as `valid`.

## v1.0.0

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
