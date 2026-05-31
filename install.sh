#!/bin/sh
# install.sh — official installer for the Rimo CLI (`rimo`).
#
# Usage:
#   curl -fsSL https://rimo.app/cli/install.sh | sh
#
# It detects your OS/arch, downloads the latest release archive from GitHub,
# verifies its checksum, and installs the `rimo` binary (no sudo required).
#
# Environment variables (optional):
#   RIMO_INSTALL_DIR   Install directory. Default: $HOME/.local/bin.
#   GITHUB_TOKEN / GH_TOKEN
#                      GitHub token, sent only to the GitHub API to avoid
#                      anonymous rate limits.

set -eu

err()  { printf 'rimo install: %s\n' "$1" >&2; exit 1; }
info() { printf '%s\n' "$1" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# get <url> <output|->  — download to a file, or stream to stdout when "-"
get() {
  _url="$1"; _out="$2"
  # Only forward the token to the GitHub API (never to asset/redirect hosts).
  _auth=""
  case "$_url" in
    https://api.github.com/*) [ -n "${TOKEN:-}" ] && _auth=1 ;;
  esac
  if have curl; then
    if [ -n "$_auth" ]; then
      curl -fsSL --connect-timeout 10 --max-time 300 --max-filesize 209715200 \
        --retry 3 --retry-delay 2 \
        -H "Authorization: Bearer $TOKEN" -o "$_out" "$_url"
    else
      curl -fsSL --connect-timeout 10 --max-time 300 --max-filesize 209715200 \
        --retry 3 --retry-delay 2 \
        -o "$_out" "$_url"
    fi
  elif have wget; then
    if [ -n "$_auth" ]; then
      wget -q --timeout=30 --tries=3 \
        --header="Authorization: Bearer $TOKEN" -O "$_out" "$_url"
    else
      wget -q --timeout=30 --tries=3 -O "$_out" "$_url"
    fi
  else
    err "need curl or wget installed"
  fi
}

# All side-effecting logic lives in main(), which is only invoked on the very
# last line. A truncated `curl | sh` download fails to parse main() (or never
# reaches the call) and therefore executes nothing.
main() {
  REPO="rimoapp/cli"
  BINARY="rimo"
  TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

  [ -n "${HOME:-}" ] || [ -n "${RIMO_INSTALL_DIR:-}" ] \
    || err "\$HOME is not set; please set RIMO_INSTALL_DIR explicitly"
  INSTALL_DIR="${RIMO_INSTALL_DIR:-${HOME}/.local/bin}"

  # ---- detect platform -----------------------------------------------------
  os="$(uname -s)"
  case "$os" in
    Linux)  os="linux" ;;
    Darwin) os="darwin" ;;
    *) err "unsupported OS '$os' (Linux/macOS only; for Windows download from https://github.com/$REPO/releases)" ;;
  esac

  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)  arch="amd64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) err "unsupported architecture '$arch'" ;;
  esac

  # ---- resolve the latest release ------------------------------------------
  info "Resolving latest release of $REPO..."
  version="$(get "https://api.github.com/repos/$REPO/releases/latest" - \
    | grep '"tag_name"' | head -n1 \
    | sed -E 's/.*"tag_name" *: *"([^"]+)".*/\1/')" \
    || err "could not query the GitHub releases API"
  [ -n "$version" ] || err "could not determine the latest release (the GitHub API may be rate-limiting you); please try again shortly"

  # goreleaser strips a leading 'v' from the version in archive names.
  ver_no_v="${version#v}"
  archive="${BINARY}_${ver_no_v}_${os}_${arch}.tar.gz"
  base_url="https://github.com/$REPO/releases/download/$version"

  # ---- download into a temp dir --------------------------------------------
  tmp="$(mktemp -d 2>/dev/null || mktemp -d -t rimo)"
  trap 'rm -rf "$tmp"' EXIT HUP INT TERM

  info "Downloading $archive ($version)..."
  get "$base_url/$archive"      "$tmp/$archive"      || err "download failed: $base_url/$archive"
  get "$base_url/checksums.txt" "$tmp/checksums.txt" || err "could not download checksums.txt"

  # ---- verify checksum -----------------------------------------------------
  info "Verifying checksum..."
  if   have sha256sum; then sum_cmd="sha256sum"
  elif have shasum;    then sum_cmd="shasum -a 256"
  else err "need sha256sum or shasum to verify the download"
  fi

  expected="$(awk -v f="$archive" '$2==f {print $1}' "$tmp/checksums.txt")"
  [ -n "$expected" ] || err "no checksum entry for $archive in checksums.txt"
  actual="$(cd "$tmp" && $sum_cmd "$archive" | awk '{print $1}')"
  [ "$expected" = "$actual" ] || err "checksum mismatch for $archive"

  # ---- extract + install ---------------------------------------------------
  tar -xzf "$tmp/$archive" -C "$tmp" || err "failed to extract $archive"
  [ -f "$tmp/$BINARY" ]              || err "binary '$BINARY' not found in archive"

  mkdir -p "$INSTALL_DIR" || err "could not create $INSTALL_DIR"

  # Stage + atomic rename so a re-install never produces a half-written
  # binary or hits "text file busy" against a running `rimo`.
  staged="$INSTALL_DIR/.$BINARY.$$.tmp"
  if ! cp "$tmp/$BINARY" "$staged" 2>/dev/null; then
    rm -f "$staged"
    err "could not write to $INSTALL_DIR (permission denied?)"
  fi
  chmod 0755 "$staged" || { rm -f "$staged"; err "could not set permissions on $staged"; }
  mv -f "$staged" "$INSTALL_DIR/$BINARY" \
    || { rm -f "$staged"; err "could not install to $INSTALL_DIR/$BINARY"; }

  info ""
  info "rimo $version installed to $INSTALL_DIR/$BINARY"

  # ---- PATH hint -----------------------------------------------------------
  case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
      info ""
      info "$INSTALL_DIR is not on your PATH. Add this to your shell profile:"
      info "  export PATH=\"$INSTALL_DIR:\$PATH\""
      ;;
  esac

  info ""
  info "Run 'rimo auth login' to get started."
}

main "$@"
