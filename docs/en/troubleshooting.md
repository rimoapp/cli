# Troubleshooting

[English](../en/troubleshooting.md) | [日本語](../ja/troubleshooting.md)

## `rimo: command not found`

The install directory is not on your `PATH`. The installer prints the line to
add; for the default location:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Add it to your shell profile (`~/.zshrc`, `~/.bashrc`, …) and restart the shell.

## `permission denied` when running `rimo`

Ensure the binary is executable:

```bash
chmod +x ~/.local/bin/rimo
```

## macOS: "Apple could not verify 'rimo' is free of malware"

If macOS Gatekeeper blocks the binary on first run, clear the quarantine
attribute:

```bash
xattr -d com.apple.quarantine ~/.local/bin/rimo
```

(Binaries installed via the `curl … | sh` one-liner are normally not
quarantined, so you usually only hit this with a manual browser download.)

## `rimo auth login` does not open a browser

`rimo auth login` prints a URL and a code. If no browser opens automatically,
open the printed URL manually and enter the code.

## Login code expires or fails

The login code is short-lived. Re-run `rimo auth login` to get a fresh code,
and complete the browser step promptly.

## Behind a proxy or firewall

The CLI talks to `https://rimo.app` and `https://api.github.com` (the latter for
installs/upgrades). Ensure outbound HTTPS to both is allowed, and that your
`HTTPS_PROXY` environment variable is set if you use a proxy.

## A stale version keeps running

Check which binary is first on your `PATH`:

```bash
which -a rimo
rimo version
```

Remove older copies, or re-run the install script to refresh `~/.local/bin/rimo`.

## Checksum mismatch during install

The downloaded archive did not match `checksums.txt`. Re-run the install — a
partial/corrupted download is the usual cause. If it persists, report it via the
[Security Policy](../../SECURITY.md).

Still stuck? Open an issue in this repository with your `rimo version`, OS, and
the exact command and output.
