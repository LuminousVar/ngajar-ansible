#!/usr/bin/env bash
# Installs a pinned uv release (tarball checked against its sha256), then ansible-core
# and ansible-lint as a single uv tool. Executables land in /usr/local/bin, so root
# can run them without activating anything.
# Safe to re-run. Override versions with UV_VERSION, ANSIBLE_SPEC and PYTHON_VERSION.
set -Eeuo pipefail

UV_VERSION="${UV_VERSION:-0.13.1}"
ANSIBLE_SPEC="${ANSIBLE_SPEC:-ansible-core>=2.21,<2.22}"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
UV=/usr/local/bin/uv
export UV_TOOL_BIN_DIR=/usr/local/bin

if [[ $("$UV" --version 2>/dev/null) != "uv $UV_VERSION "* ]]; then
  asset="uv-$(uname -m)-unknown-linux-gnu"
  url="https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${asset}.tar.gz"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL --retry 3 -o "$tmp/$asset.tar.gz" "$url"
  curl -fsSL --retry 3 -o "$tmp/$asset.tar.gz.sha256" "$url.sha256"
  (cd "$tmp" && sha256sum -c --quiet "$asset.tar.gz.sha256")
  tar -xzf "$tmp/$asset.tar.gz" -C "$tmp"
  install -m 0755 "$tmp/$asset/uv" "$tmp/$asset/uvx" /usr/local/bin/
fi

"$UV" tool install --force --python "$PYTHON_VERSION" --with-executables-from ansible-lint "$ANSIBLE_SPEC"

# Later `uv tool install` or `uv tool upgrade` runs from an interactive shell keep using /usr/local/bin
rc="${HOME:-/root}/.bashrc"
grep -qxF 'export UV_TOOL_BIN_DIR=/usr/local/bin' "$rc" 2>/dev/null \
  || echo 'export UV_TOOL_BIN_DIR=/usr/local/bin' >> "$rc"

ansible --version | head -n 1
