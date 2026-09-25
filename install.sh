#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.local/bin"
ln -sfn "$ROOT/bin/backpack-lid" "$HOME/.local/bin/backpack-lid"
echo "Installed: $HOME/.local/bin/backpack-lid -> $ROOT/bin/backpack-lid"
"$HOME/.local/bin/backpack-lid" status || true
