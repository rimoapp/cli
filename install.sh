#!/bin/sh
# install.sh — official installer for the Rimo CLI (`rimo`).
#
# Usage:
#   curl -fsSL https://rimo.app/cli/install.sh | sh
#
# It detects your OS/arch, downloads the matching release archive from GitHub,
# verifies its checksum, and installs the `rimo` binary (no sudo required).
#
# Environment variables (documented):
#   RIMO_VERSION       Pin a version, e.g. v1.0.0. Default: latest release.
#   RIMO_INSTALL_DIR   Install directory. Default: $HOME/.local/bin.
#
# Advanced (optional):
#   RIMO_INSTALL_REPO  Override the GitHub repo to install from. Default: rimoapp/cli.
#   GITHUB_TOKEN / GH_TOKEN
#                      Optional GitHub token, sent only to the API to avoid
#                      anonymous rate limits.

set -eu

REPO="${RIMO_INSTALL_REPO:-rimoapp/cli}"
INSTALL_DIR="${RIMO_INSTALL_DIR:-$HOME/.local/bin}"
BINARY="rimo"
TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

# ---- helpers ---------------------------------------------------------------
err()  { printf 'rimo install: %s\n' "$1" >&2; exit 1; }
info() { printf '%s\n' "$1" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# get <url> <output|->  — download to a file, or stream to stdout when "-"
get() {
  _url="$1"; _out="$2"
  if have curl; then
    if [ -n "$TOKEN" ]; then
      curl -fsSL -H "Authorization: Bearer $TOKEN" -o "$_out" "$_url"
    else
      curl -fsSL -o "$_out" "$_url"
    fi
  elif have wget; then
    if [ -n "$TOKEN" ]; then
      wget -q --header="Authorization: Bearer $TOKEN" -O "$_out" "$_url"
    else
      wget -q -O "$_out" "$_url"
    fi
  else
    err "need curl or wget installed"
  fi
}

# ---- detect platform -------------------------------------------------------
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

# ---- resolve version -------------------------------------------------------
version="${RIMO_VERSION:-}"
if [ -z "$version" ]; then
  info "Resolving latest release of $REPO..."
  version="$(get "https://api.github.com/repos/$REPO/releases/latest" - \
    | grep '"tag_name"' | head -n1 \
    | sed -E 's/.*"tag_name" *: *"([^"]+)".*/\1/')" \
    || err "could not query the releases API for $REPO"
  [ -n "$version" ] || err "no release found for $REPO (is it public and does it have a release?)"
fi

# goreleaser strips a leading 'v' from the version in archive names.
ver_no_v="${version#v}"
archive="${BINARY}_${ver_no_v}_${os}_${arch}.tar.gz"
base_url="https://github.com/$REPO/releases/download/$version"

# ---- download into a temp dir ----------------------------------------------
tmp="$(mktemp -d 2>/dev/null || mktemp -d -t rimo)"
trap 'rm -rf "$tmp"' EXIT INT TERM

info "Downloading $archive ($version)..."
get "$base_url/$archive"     "$tmp/$archive"      || err "download failed: $base_url/$archive"
get "$base_url/checksums.txt" "$tmp/checksums.txt" || err "could not download checksums.txt"

# ---- verify checksum -------------------------------------------------------
info "Verifying checksum..."
if   have sha256sum; then sum_cmd="sha256sum"
elif have shasum;    then sum_cmd="shasum -a 256"
else err "need sha256sum or shasum to verify the download"
fi

expected="$(awk -v f="$archive" '$2==f {print $1}' "$tmp/checksums.txt")"
[ -n "$expected" ] || err "no checksum entry for $archive in checksums.txt"
actual="$(cd "$tmp" && $sum_cmd "$archive" | awk '{print $1}')"
[ "$expected" = "$actual" ] || err "checksum mismatch for $archive"

# ---- extract + install -----------------------------------------------------
tar -xzf "$tmp/$archive" -C "$tmp" || err "failed to extract $archive"
[ -f "$tmp/$BINARY" ]              || err "binary '$BINARY' not found in archive"

mkdir -p "$INSTALL_DIR" || err "could not create $INSTALL_DIR"
if ! install -m 0755 "$tmp/$BINARY" "$INSTALL_DIR/$BINARY" 2>/dev/null; then
  cp "$tmp/$BINARY" "$INSTALL_DIR/$BINARY" || err "could not install to $INSTALL_DIR"
  chmod 0755 "$INSTALL_DIR/$BINARY"        || err "could not set permissions on $INSTALL_DIR/$BINARY"
fi

info ""
info "rimo $version installed to $INSTALL_DIR/$BINARY"

# ---- PATH hint -------------------------------------------------------------
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
