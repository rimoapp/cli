# Authentication

[English](../en/authentication.md) | [日本語](../ja/authentication.md)

`rimo` authenticates with Rimo Voice through a browser-based login. Tokens are
stored securely by your operating system's credential store, never in a
plain-text file.

## Logging in

```bash
rimo auth login
```

1. `rimo` prints a one-time user code and a verification URL.
2. Press Enter to open the URL in your browser (or open it manually).
3. Approve the request in the browser.
4. The access and refresh tokens are saved securely by your OS credential store; an
   account alias is registered in `~/.config/rimo/config.yaml` and set as active.

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

## Token resolution priority

When a command needs a token, `rimo` resolves it in this order:

1. `--account <alias>` flag → config lookup → stored credentials.
2. `default_account` from config → stored credentials.
3. If none resolve, the command exits with an authentication error (exit code 2)
   and the message *"Run `rimo auth login`"*.

## Where credentials live

- **Tokens** — stored securely by your OS credential store (never in the config file).
- **Account metadata** (alias, email, org, default account) — `~/.config/rimo/config.yaml`.

See [Configuration](configuration.md) for the file format.
