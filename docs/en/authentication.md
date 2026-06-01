# Authentication

[English](../en/authentication.md) | [日本語](../ja/authentication.md)

`rimo` authenticates with Rimo Voice through a browser-based login. Tokens are
stored securely by your OS credential store, never in a text file.

## Logging in

```bash
rimo auth login
```

1. `rimo` opens your browser to authorize this CLI.
2. Sign in if needed and approve the request.
3. The access and refresh tokens are saved securely by your OS credential
   store; an account alias is registered in `~/.config/rimo/config.yaml`
   and set as active.

### No browser available

On machines without a usable browser (SSH session, container, CI runner),
add `--no-browser`:

```bash
rimo auth login --no-browser
```

1. `rimo` prints a URL.
2. Open the URL on any other device with a browser. Sign in if needed and
   approve the request; the page shows a short code.
3. Paste the code back into your terminal.
4. Tokens are stored as above.

## Multiple accounts

Each successful login creates an account alias derived from your email and
organization (for example `alice-rimo-personal`). You can hold several accounts at
once and switch between them.

```bash
rimo auth status                  # list saved accounts and token status
rimo auth switch <alias|email|org>   # change the active account
rimo auth logout                  # remove the active account (or pass --account)
```

See the [commands reference](commands.md#authentication) for full flags and
resolution rules.

## Account selection priority

When a command needs an account, `rimo` resolves it in this order:

1. `--account <alias>` flag → config lookup → stored credentials.
2. `active_account` from config → stored credentials.
3. If none resolve, the command exits with an authentication error and the
   message *"Run `rimo auth login`"*.

## Where credentials live

- **Tokens** — stored securely by your OS credential store (never in the config file).
- **Account metadata** (alias, email, org, default account) — `~/.config/rimo/config.yaml`.

See [Configuration](configuration.md) for the file format.
