# Rimo — Claude Desktop Extension (`.mcpb`)

This directory is the source of truth for the **Rimo Claude Desktop extension**: a
one-click bundle that wires the `rimo mcp` server into [Claude Desktop](https://claude.ai/download)
without editing `claude_desktop_config.json` by hand.

| File | Role |
|------|------|
| `manifest.json` | Extension metadata + MCP server launch definition. **Single source of truth for the extension `version`.** |
| `icon.png` | Extension icon shown in Claude Desktop (the Rimo brand mark, from the `rimo` GitHub org avatar). |
| `icon-16.png`, `icon-32.png`, `icon-128.png` | Small variants (downscaled from `icon.png` via `sips`), listed in the manifest `icons` array so compact UI surfaces (e.g. the connectors menu) can pick an exact size. Claude Desktop still shows a letter avatar in some menus for local extensions — upstream [mcpb#154](https://github.com/modelcontextprotocol/mcpb/issues/154). |
| `server/` | **Gitignored build output** — the bundled `rimo` binaries staged here right before packing (`make mcpb-server-binaries` locally; the release workflow copies the signed goreleaser outputs). |
| `.mcpbignore` | Files kept out of the packed bundle. |

## Binary strategy — Option B (bundled binaries)

The bundle **embeds the `rimo` binaries**, so installing the extension requires no
separate CLI install and no PATH configuration:

- `server/rimo` — macOS **universal** binary (Intel + Apple Silicon via
  goreleaser `universal_binaries`/lipo), Developer ID **signed and notarized** by
  the release pipeline. A fat binary is required because the manifest's
  `platform_overrides` selects per **OS**, not per arch.
- `server/rimo.exe` — Windows amd64 (runs on ARM Windows under emulation).
  **Unsigned until #152** (Authenticode) — Claude Desktop launches it fine as a
  child process, but signing remains the trust gap for directory submission.
- Linux is not in `compatibility.platforms`: Claude Desktop does not ship for Linux.

The manifest launches `${__dirname}/server/rimo` (win32 override:
`${__dirname}/server/rimo.exe`). There is no `rimo_path` user-config field —
Option A (PATH-dependent launch of a separately installed CLI, shipped in v0.1.0)
was replaced by this in v0.2.0 once macOS signing/notarization landed (#124).

**Never parameterize `args` with `user_config` values.** `args` stays the
hardcoded `["mcp"]`. Routing user config into `args` would widen the injection
surface for no benefit — pass user config via `env` instead.

## Auth — two paths

The manifest exposes an optional **`api_key`** user-config field (`sensitive: true`,
so Claude Desktop masks the input and stores the value securely) that is injected
into the server's environment as `RIMO_API_KEY` — already the CLI's top token
resolution priority. A personal API key created in the Rimo web app therefore
gives a fully terminal-free sign-in. Left blank, the value is empty and the CLI
treats an empty `RIMO_API_KEY` as unset, falling back to the OS-keyring session
from `rimo auth login` — so users who also have the CLI get zero-config auth.
There is no in-extension OAuth sign-in; that would require the remote-transport
work (#198).

## Build

From the repo root:

```bash
make mcpb-validate          # schema-check manifest.json
make mcpb-server-binaries   # cross-build server/rimo (universal) + server/rimo.exe — macOS only (lipo)
make mcpb-pack              # → dist/rimo.mcpb (fails fast if server/ binaries are missing)
```

Locally built binaries are **unsigned** — fine for your own testing; Gatekeeper
does not quarantine files you build yourself. The release pipeline packs the
signed + notarized binaries instead.

Pack/validate shell out to the official `@anthropic-ai/mcpb` CLI via `npx`
(Node required; version pinned in the Makefile). `dist/` and `server/` are
gitignored; the `.mcpb` is a release artifact, not committed.

## Release / versioning

- Every stable release repacks the bundle with **that release's binaries** and
  attaches `rimo.mcpb` + `rimo.mcpb.sha256` (the `Release` workflow copies the
  signed goreleaser outputs into `server/` and runs `make mcpb-pack`). Users
  update the bundled CLI by reinstalling the latest `rimo.mcpb`.
- Bump the semver `version` in `manifest.json` when the **extension itself**
  changes user-visibly (launch contract, settings fields, descriptions). The
  bundled CLI version rides along with each release automatically and is *not*
  a reason to bump.
- The extension `version` is independent of the Claude Code plugin
  (`../.claude-plugin/plugin.json`) and the `rimo` CLI release.

User-facing setup lives in [`../docs/en/mcp.md`](../docs/en/mcp.md#claude-desktop-one-click-extension).
