# Configuration

[English](../en/configuration.md) | [日本語](../ja/configuration.md)

## Config file

Account metadata is stored at `~/.config/rimo/config.yaml`:

```yaml
default_account: alice-rimo-personal
accounts:
  alice-rimo-personal:
    user_id: user_123
    org_id: org_456
    email: alice@rimo.app
    display_name: Alice
    org_name: Personal
```

This file is created and managed by `rimo auth login` / `logout` / `switch` — you
normally do not edit it by hand.

## Token storage

Tokens are **never** written to `config.yaml`. They are stored securely by your
operating system's credential store and are never written in plain text.

See [Authentication](authentication.md) for the login flow and token resolution
order.

## Environment variables

| Variable | Used by | Purpose |
|----------|---------|---------|
| `RIMO_TOKEN` | all commands | API token for headless/CI use. Takes priority over `--account` and `default_account`; used as-is, never refreshed. |
| `RIMO_INSTALL_DIR` | install script | Directory to install the binary into (default `~/.local/bin`). |
| `RIMO_VERSION` | install script | Pin a specific version to install instead of latest. |
| `RIMO_NO_UPDATE_CHECK` | the binary | Set to any non-empty value to disable the background "update available" notice. |
| `CI` | the binary | When set, the background update notice is suppressed automatically. |

## File locations summary

| What | Where |
|------|-------|
| Account metadata | `~/.config/rimo/config.yaml` |
| Tokens | OS credential store (managed by `rimo auth`) |
| Binary (default install) | `~/.local/bin/rimo` |
| Update-check cache | OS cache dir, `rimo/update_check.json` |
