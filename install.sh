#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${DOOMDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/doom}"
CORE="${EMACSDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/emacs}"
REV="$(cat "$ROOT/doom-version")"
DEPS=0
DRY=0
for arg in "$@"; do
  case "$arg" in
    --deps) DEPS=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) echo 'Usage: ./install.sh [--deps] [--dry-run]'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done
if [[ "$DEST" == "$CORE"/* || "$CORE" == "$DEST"/* || "$DEST" == "$ROOT"/doom || "$DEST" == "$CORE" || "$DEST" == / || "$CORE" == / || "$DEST" == "$HOME" || "$CORE" == "$HOME" ]]; then
  echo 'Unsafe or overlapping installation paths.' >&2; exit 1
fi
printf 'Personal config: %s\nDoom core: %s\nDoom revision: %s\n' "$DEST" "$CORE" "$REV"
if (( DRY )); then
  echo 'Dry run: no files changed. Existing config will be backed up; existing Doom core reused.'
  exit 0
fi
if (( DEPS )); then
  [[ "$(uname -s)" == Darwin ]] || { echo '--deps currently supports macOS only.' >&2; exit 1; }
  command -v brew >/dev/null || { echo 'Install Homebrew first: https://brew.sh' >&2; exit 1; }
  xcode-select -p >/dev/null 2>&1 || { echo 'Run xcode-select --install, complete it, then retry.' >&2; exit 1; }
  brew install emacs git ripgrep fd cmake libtool make llvm python uv node lazygit
  brew install --cask font-fira-code-nerd-font
  brew install pyright
  uv tool install ruff
fi
for program in emacs git rg fd cmake; do
  command -v "$program" >/dev/null || { echo "Missing dependency: $program. On macOS use --deps." >&2; exit 1; }
done
emacs --batch -Q --eval '(unless (and (>= emacs-major-version 30) module-file-suffix) (kill-emacs 1))' || {
  echo 'Emacs 30+ with dynamic modules is required.' >&2; exit 1;
}
if [[ -e "$CORE" && ! -x "$CORE/bin/doom" ]]; then
  echo "Existing non-Doom directory at $CORE; move it aside yourself before installing." >&2; exit 1
fi
if command -v uv >/dev/null; then
  DEBUGPY="$HOME/.local/share/emacs-config/debugpy"
  [[ -d "$DEBUGPY" ]] || uv venv "$DEBUGPY"
  uv pip install --python "$DEBUGPY/bin/python" debugpy
fi
if [[ ! -e "$CORE" ]]; then
  mkdir -p "$(dirname "$CORE")"
  git clone https://github.com/doomemacs/doomemacs.git "$CORE"
  git -C "$CORE" checkout "$REV"
else
  echo 'Reusing existing Doom core without changing its revision.'
fi
mkdir -p "$(dirname "$DEST")"
if [[ -e "$DEST" || -L "$DEST" ]]; then
  BACKUP="${DEST}.backup-$(date +%Y%m%d-%H%M%S)-$$"
  mv "$DEST" "$BACKUP"
  echo "Backup: $BACKUP"
fi
mkdir -p "$DEST"
cp "$ROOT"/doom/*.el "$DEST/"
if [[ -n "${BACKUP:-}" && -f "$BACKUP/local.el" ]]; then
  cp "$BACKUP/local.el" "$DEST/local.el"
fi
export DOOMDIR="$DEST" EMACSDIR="$CORE"
"$CORE/bin/doom" -y install --no-config --no-env
"$CORE/bin/doom" -y sync
printf '\nInstalled. Restart Emacs. Run %s/bin/doom doctor to inspect optional dependencies.\n' "$CORE"
