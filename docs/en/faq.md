# FAQ

## Installation & setup

### Where is the binary installed?

By default, the install script places `rimo` (or `rimo.exe` on Windows) at `~/.local/bin/rimo`. You can override this with the `RIMO_INSTALL_DIR` environment variable before running the install script.

### Do I need admin / root access to install?

No. The default install location (`~/.local/bin`) is in your home directory. No `sudo` or administrator privileges are needed.

### Does `rimo` work in CI environments?

Yes. The simplest option for non-interactive runs is a **personal API key**: set `RIMO_API_KEY` (a `rimo_pat_…` key from the web app) as a CI secret and skip the login step entirely — see [Personal API keys](personal-api-keys.md). Alternatively, authenticate once with `rimo auth login --no-browser`; tokens are stored in the OS credential store, so in CI you may need to configure the credential helper appropriately for your runner. Either way, set `CI=true` in your environment to suppress the update-available notice.

### How do I keep `rimo` up to date?

```bash
rimo upgrade
```

Or re-run the original install script — it always downloads the latest release.

---

## Authentication

### Where are my tokens stored?

Tokens are stored in your operating system's credential store (Keychain on macOS, the Secret Service on Linux, Windows Credential Manager on Windows). They are **never** written to a config file in plain text.

### Can I use multiple Rimo accounts?

Yes. Run `rimo auth login` for each account. Each creates an alias (e.g. `alice-rimo-personal`, `alice-company-engineering`). Switch between them with `rimo auth switch <alias>` or pass `--account <alias>` to any command.

### Can I authenticate without a browser (CI/CD)?

Yes. Set the `RIMO_API_KEY` environment variable to a personal API key created in the Rimo web app — no `rimo auth login` needed. It takes priority over any logged-in account and is the recommended way to run `rimo` in CI/CD. See [Personal API keys](personal-api-keys.md).

### What happens if my token expires?

The command will fail with an authentication error. Run `rimo auth login` again to refresh. `rimo auth status` shows `token_status: expired` if a token has expired.

---

## Commands & output

### Why does `rimo` always output JSON?

Consistency. A command that formats output differently in a terminal vs. a pipe is hard to script and hard for AI agents to parse. JSON output is always the same, so it works reliably in both. A few commands (`rimo version`, `rimo upgrade`, `rimo note ask`, `rimo note get --transcript/--document/--full`) print plain text because a JSON wrapper would genuinely get in the way. Errors are always JSON regardless.

### What is the difference between `rimo note search` and `rimo note ask`?

- **`rimo note search`** finds and returns a list of notes. You get note IDs and metadata, then decide what to read next. Use it when you want to browse results yourself (or pass them to another command).
- **`rimo note ask`** synthesises an AI answer from your notes. It reads the relevant notes for you and returns a single text answer with citations. Use it when you want a direct answer rather than a list to read.

### How do I reduce the output size for AI agent use?

Use `--fields` to request only the fields you need:

```bash
rimo note list --fields id,title,created_at
```

Or use `--fields compact` to include all fields but truncate long strings. Either approach significantly reduces token usage.

### What does `--dry-run` do?

It simulates a write command without executing any side effects. Useful for verifying that a command would succeed before running it for real. Currently applies to write-type commands.

---

## MCP server

### Do I need a separate login for `rimo mcp`?

No. The MCP server reuses the same authentication as the CLI. Authenticate once with `rimo auth login` and the server will use the same token.

### What if the Rimo tools don't appear in my MCP client?

The most common cause is that `rimo` is not on the `PATH` visible to your MCP client. Try specifying the absolute path to the binary in your `.mcp.json`:

```json
{
  "mcpServers": {
    "rimo": {
      "type": "stdio",
      "command": "/home/alice/.local/bin/rimo",
      "args": ["mcp"]
    }
  }
}
```

### Can I use both the MCP server and the agent skill at the same time?

Yes. They are independent. The MCP server (`rimo mcp`) provides typed tools to MCP-capable clients. The agent skill is a markdown file that any agent can read to learn how to drive the CLI through shell commands. You can have both configured simultaneously.

---

## Troubleshooting

### `rimo: command not found`

The install directory is not on your `PATH`. See [Troubleshooting](troubleshooting.md) for the fix.

### Something isn't working right

Check [Troubleshooting](troubleshooting.md) for common issues, or open an issue in the [CLI repository](https://github.com/rimo/cli) with your `rimo version`, OS, and the exact command and output.
