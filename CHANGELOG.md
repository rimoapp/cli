# Changelog

All notable changes to the Rimo CLI are documented here. This project follows
[Semantic Versioning](https://semver.org/).

## v1.3.0

### Added

- `rimo note create` — create a note from the CLI, with an editable document
  created alongside it. Seed it with markdown from an argument, a file, or
  standard input, and set the title, team, and locale. Needs a token that is
  allowed to write notes.
- `rimo note append` — merge markdown into a note's document as a new section,
  either at the end or at the start. Heading and list structure is preserved.

### Fixed

- `rimo auth login` now tells you how to authenticate with a personal API key
  when your system has no usable keyring (for example a container or a headless
  Linux machine), instead of failing with an unclear error.

### Changed

- The Claude Code plugin's bundled skill now covers the two write commands —
  run `/plugin update rimo` to pick it up.
- The "Rimo in Microsoft Copilot" guide has been reworked with screenshots in
  both English and Japanese.

## v1.2.2

### Added

- **Claude Desktop extension** — install `rimo` in Claude Desktop with one
  click. The extension bundles the CLI binaries, so you can connect Rimo in
  Claude Desktop without touching a terminal.
- `rimo note list --today` / `--week` — list notes held today or this week
  (JST) without typing out a date range.
- `rimo mcp` `note_read` — read a note's contents as text or markdown directly
  from MCP clients, instead of fetching raw JSON.

### Changed

- `rimo mcp` tools now have clearer English titles and "when to use"
  descriptions, so MCP clients present them better.

### Fixed

- `rimo mcp` `note_get` now returns a note's metadata only by default, instead
  of pulling its full contents unexpectedly.

## v1.2.1

### Added

- Personal API key authentication — set `RIMO_API_KEY` to a `rimo_pat_…` key to
  use the CLI without a browser login (ideal for headless and CI use). See the
  personal API key guide.
- `rimo note search` — new filters in filter mode: `--team`, `--participant`,
  `--note-tag`, and `--since` / `--until` for a date range.
- `rimo note get --meeting-chat` — fetch the in-meeting chat (Zoom / Google
  Meet) for a note.

### Fixed

- The `rimo mcp` server now marks `note_ask` and `note_semantic_search` as
  read-only, so MCP clients correctly show that they make no changes.

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
