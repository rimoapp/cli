# Authentication

[English](../en/authentication.md) | [日本語](../ja/authentication.md)

`rimo` authenticates with Rimo Voice through a browser-based login. Tokens are
stored securely by your OS credential store, never in a text file.

For automation where no one can open a browser — CI/CD pipelines, scripts,
scheduled jobs — authenticate with a **personal API key** instead. See
[API key authentication (CI/CD)](#api-key-authentication-cicd) below, and
[Personal API keys](personal-api-keys.md) for how to create and manage keys.

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

## API key authentication (CI/CD)

For non-interactive use, set the `RIMO_API_KEY` environment variable to a
personal API key created in the Rimo web app. No browser login is needed:

```bash
export RIMO_API_KEY="rimo_pat_…"
rimo note list        # authenticates with the key directly
```

When `RIMO_API_KEY` is set it takes precedence over any logged-in account (see
[Account selection priority](#account-selection-priority)). Create the key in
**Settings → API Key** and store it as a CI secret. Full instructions —
including expiry, the per-organization policy, and deactivation — are in
[Personal API keys](personal-api-keys.md).

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

When a command needs credentials, `rimo` resolves them in this order:

1. `RIMO_API_KEY` environment variable — a personal API key (`rimo_pat_…`), used
   as-is. See [Personal API keys](personal-api-keys.md).
2. `--account <alias>` flag → config lookup → stored credentials.
3. `active_account` from config → stored credentials.
4. If none resolve, the command exits with an authentication error and the
   message *"Run `rimo auth login`"*.

## Where credentials live

- **Tokens** — stored securely by your OS credential store (never in the config file).
- **Account metadata** (alias, email, org, default account) — `~/.config/rimo/config.yaml`.

See [Configuration](configuration.md) for the file format.
