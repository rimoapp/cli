# Installation

[English](../en/installation.md) | [日本語](../ja/installation.md)

## Quick install (recommended)

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

The script detects your OS and architecture, downloads the matching release from
GitHub, verifies its checksum, and installs the `rimo` binary to `~/.local/bin`.
No `sudo` is required.

If `~/.local/bin` is not on your `PATH`, the script prints the line to add to your
shell profile. For example:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Verify the install:

```bash
rimo version
```

## Manual install

Prefer not to pipe a script into your shell? Download the archive for your platform
from the [releases page](https://github.com/rimoapp/cli/releases), extract the
`rimo` binary, and place it on your `PATH`.

Each release publishes these archives plus a `checksums.txt`:

| OS | Arch | Archive |
|----|------|---------|
| linux | amd64 | `rimo_<ver>_linux_amd64.tar.gz` |
| linux | arm64 | `rimo_<ver>_linux_arm64.tar.gz` |
| darwin | amd64 | `rimo_<ver>_darwin_amd64.tar.gz` |
| darwin | arm64 | `rimo_<ver>_darwin_arm64.tar.gz` |
| windows | amd64 | `rimo_<ver>_windows_amd64.zip` |
| windows | arm64 | `rimo_<ver>_windows_arm64.zip` |

```bash
# Example: macOS arm64 (Apple Silicon)
VERSION=1.0.0
curl -fsSL -O "https://github.com/rimoapp/cli/releases/download/v${VERSION}/rimo_${VERSION}_darwin_arm64.tar.gz"
tar -xzf "rimo_${VERSION}_darwin_arm64.tar.gz"
mv rimo ~/.local/bin/
rimo version
```

Verify the checksum before installing:

```bash
curl -fsSL -O "https://github.com/rimoapp/cli/releases/download/v${VERSION}/checksums.txt"
shasum -a 256 -c checksums.txt --ignore-missing
```

## Upgrading

```bash
rimo upgrade           # upgrade to the latest release
rimo upgrade --check   # report whether a newer version exists, without installing
```

Alternatively, re-run the install script — it always fetches the latest release:

```bash
curl -fsSL https://rimo.app/cli/install.sh | sh
```

See [`rimo upgrade`](commands.md#rimo-upgrade) for all flags.

## Uninstall

```bash
rimo auth logout          # revoke and remove stored tokens (optional)
rm ~/.local/bin/rimo      # remove the binary
rm -rf ~/.config/rimo     # remove configuration (optional)
```
