#!/usr/bin/env bash
# Undoes install.sh: restores the newest backup of each config (or removes it if there was none)
# and removes the starship block install.sh added to your shell rc. Leaves the font and the
# starship binary installed.
set -euo pipefail

MARK_BEGIN="# >>> ghostty-rex >>>"
MARK_END="# <<< ghostty-rex <<<"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

restore() {
  local dest="$1" latest
  latest="$(ls -1 "$dest".bak-* 2>/dev/null | sort | tail -n 1 || true)"
  if [ -n "$latest" ]; then
    rm -f "$dest"
    mv "$latest" "$dest"
    say "restored $dest from $latest"
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    rm -f "$dest"
    say "removed $dest"
  fi
}

restore "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
restore "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes/rex-abyssal-trench"
restore "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

for rc in "${ZDOTDIR:-$HOME}/.zshrc" "$HOME/.bashrc" "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"; do
  [ -f "$rc" ] && grep -qF "$MARK_BEGIN" "$rc" || continue
  tmp="$(mktemp)"
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '$0==b{skip=1; next} $0==e{skip=0; next} !skip' "$rc" >"$tmp"
  cat "$tmp" >"$rc" && rm -f "$tmp"
  say "removed starship block from $rc"
done

say "done. Open a new Ghostty window and shell to see the change."
