# Installation

[English](../en/installation.md) | [日本語](../ja/installation.md)

## Quick install (recommended)

### Linux / macOS

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

### Windows

In PowerShell:

```powershell
irm https://rimo.app/cli/install.ps1 | iex
```

The script detects your architecture, downloads the matching release from GitHub,
verifies its checksum, and installs `rimo.exe` to `%USERPROFILE%\.local\bin`.
No administrator privileges are required.

If the install directory is not on your user `PATH`, the script adds it for you.
Open a new PowerShell window after the install completes for the change to take
effect.

### Verify the install

```bash
rimo version
```

## Manual install

Prefer not to pipe a script into your shell? Download the archive for your platform
from the [releases page](https://github.com/rimo/cli/releases), extract the
`rimo` binary, and place it on your `PATH`.

Each release publishes these archives plus a `checksums.txt`:

| OS | Arch | Archive |
|----|------|---------|
| Linux | amd64 | `rimo_<ver>_linux_amd64.tar.gz` |
| Linux | arm64 | `rimo_<ver>_linux_arm64.tar.gz` |
| Mac | amd64 | `rimo_<ver>_darwin_amd64.tar.gz` |
| Mac | arm64 | `rimo_<ver>_darwin_arm64.tar.gz` |
| Windows | amd64 | `rimo_<ver>_windows_amd64.zip` |
| Windows | arm64 | `rimo_<ver>_windows_arm64.zip` |

### Linux / macOS

```bash
# Example: macOS arm64 (Apple Silicon)
VERSION=1.0.0
curl -fsSL -O "https://github.com/rimo/cli/releases/download/v${VERSION}/rimo_${VERSION}_darwin_arm64.tar.gz"
tar -xzf "rimo_${VERSION}_darwin_arm64.tar.gz"
mv rimo ~/.local/bin/
rimo version
```

Verify the checksum before installing:

```bash
curl -fsSL -O "https://github.com/rimo/cli/releases/download/v${VERSION}/checksums.txt"
shasum -a 256 -c checksums.txt --ignore-missing
```

### Windows

```powershell
# Example: Windows amd64
$Version = "1.0.0"
$Archive = "rimo_${Version}_windows_amd64.zip"
$BinDir  = "$env:USERPROFILE\.local\bin"
Invoke-WebRequest -Uri "https://github.com/rimo/cli/releases/download/v${Version}/${Archive}" -OutFile $Archive
Expand-Archive -Path $Archive -DestinationPath . -Force
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
Move-Item -Path .\rimo.exe -Destination $BinDir -Force
rimo version
```

Verify the checksum before installing:

```powershell
Invoke-WebRequest -Uri "https://github.com/rimo/cli/releases/download/v${Version}/checksums.txt" -OutFile "checksums.txt"
$line = (Select-String -Path checksums.txt -Pattern $Archive).Line
$expected = ($line.Trim() -split '\s+')[0]
$actual = (Get-FileHash -Algorithm SHA256 -Path $Archive).Hash.ToLower()
if ($expected -ne $actual) { throw "checksum mismatch" }
```

If `%USERPROFILE%\.local\bin` is not on your `PATH`, add it from PowerShell:

```powershell
[Environment]::SetEnvironmentVariable(
    "PATH",
    "$env:USERPROFILE\.local\bin;" + [Environment]::GetEnvironmentVariable("PATH", "User"),
    "User"
)
```

Open a new PowerShell window after the change for it to take effect.

## Upgrading

```bash
rimo upgrade           # upgrade to the latest release
rimo upgrade --check   # report whether a newer version exists, without installing
```

Alternatively, re-run the install script — it always fetches the latest release:

```bash
# Linux / macOS
curl -fsSL https://rimo.app/cli/install.sh | sh
```

```powershell
# Windows
irm https://rimo.app/cli/install.ps1 | iex
```

See [`rimo upgrade`](commands.md#rimo-upgrade) for all flags.

## Uninstall

### Linux / macOS

```bash
rimo auth logout          # revoke and remove stored tokens (optional)
rm ~/.local/bin/rimo      # remove the binary
rm -rf ~/.config/rimo     # remove configuration (optional)
```

### Windows

```powershell
rimo auth logout                                     # revoke and remove stored tokens (optional)
Remove-Item "$env:USERPROFILE\.local\bin\rimo.exe"   # remove the binary
Remove-Item -Recurse "$env:USERPROFILE\.config\rimo" # remove configuration (optional)
```
