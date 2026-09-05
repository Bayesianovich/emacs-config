#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/home" "$TMP/core/bin" "$TMP/config"
for cmd in emacs git rg fd cmake; do
  printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/$cmd"
  chmod +x "$TMP/bin/$cmd"
done
printf '#!/bin/sh\nprintf "%%s\\n" "$*" >> "$HOME/doom-calls"\n' > "$TMP/core/bin/doom"
chmod +x "$TMP/core/bin/doom"
echo original > "$TMP/config/local.el"
run() { env HOME="$TMP/home" PATH="$TMP/bin:/usr/bin:/bin" DOOMDIR="$TMP/config" EMACSDIR="$TMP/core" bash "$ROOT/install.sh" "$@"; }
run --dry-run
test ! -e "$TMP/config/init.el"
run
test -f "$TMP/config/init.el"
test "$(cat "$TMP/config/local.el")" = original
run
test "$(find "$TMP" -maxdepth 1 -name 'config.backup-*' | wc -l | tr -d ' ')" = 2
mkdir "$TMP/not-doom"
if env HOME="$TMP/home" PATH="$TMP/bin:/usr/bin:/bin" DOOMDIR="$TMP/config" EMACSDIR="$TMP/not-doom" bash "$ROOT/install.sh"; then
  echo 'Expected refusal for non-Doom core' >&2; exit 1
fi
test -f "$TMP/config/init.el"
echo 'Installer smoke tests passed.'
