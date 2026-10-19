#!/usr/bin/env bash
# Installs the Rex-inspired Ghostty setup: Ghostty config, Starship prompt, JetBrains Mono.
# Usage: ./install.sh [--link] [--no-font] [--no-starship]
#   --link         symlink configs to this repo (so `git pull` updates them) instead of copying
#   --no-font      skip installing JetBrains Mono
#   --no-starship  skip Starship (install, config, and shell hook)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONT_VERSION="2.304"
STAMP="$(date +%Y%m%d-%H%M%S)"
MARK_BEGIN="# >>> ghostty-rex >>>"
MARK_END="# <<< ghostty-rex <<<"

LINK=0 DO_FONT=1 DO_STARSHIP=1
for arg in "$@"; do
  case "$arg" in
    --link) LINK=1 ;;
    --no-font) DO_FONT=0 ;;
    --no-starship) DO_STARSHIP=0 ;;
    -h | --help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg (try --help)" >&2; exit 1 ;;
  esac
done

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }

# place SRC DEST: back up DEST if it exists and differs, then copy or symlink SRC there.
place() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    say "$dest already linked"; return
  fi
  if [ "$LINK" = 0 ] && [ -f "$dest" ] && [ ! -L "$dest" ] && cmp -s "$src" "$dest"; then
    say "$dest already up to date"; return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak-$STAMP"
    say "backed up $dest -> $dest.bak-$STAMP"
  fi
  if [ "$LINK" = 1 ]; then ln -s "$src" "$dest"; else cp "$src" "$dest"; fi
  say "installed $dest"
}

case "$(uname -s)" in
  Darwin) FONT_DIR="$HOME/Library/Fonts" ;;
  *) FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts" ;;
esac

have_font() {
  if command -v fc-list >/dev/null 2>&1; then
    fc-list 2>/dev/null | grep -qi 'JetBrains Mono.*style=.*Bold' && return 0
  fi
  local d
  for d in "$FONT_DIR" /Library/Fonts; do
    compgen -G "$d/JetBrainsMono-Bold.ttf" >/dev/null && return 0
    compgen -G "$d/JetBrainsMono\[wght\].ttf" >/dev/null && return 0
  done
  return 1
}

# Downloads straight from JetBrains' GitHub release into the user font folder: no Homebrew or
# admin rights needed, and it doesn't trip over font files that are already installed.
install_font() {
  if have_font; then say "JetBrains Mono already installed"; return; fi
  say "installing JetBrains Mono $FONT_VERSION to $FONT_DIR"
  local tmp f
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/jbm.zip" \
    "https://github.com/JetBrains/JetBrainsMono/releases/download/v$FONT_VERSION/JetBrainsMono-$FONT_VERSION.zip"
  unzip -q -j "$tmp/jbm.zip" 'fonts/ttf/*.ttf' -d "$tmp/ttf"
  mkdir -p "$FONT_DIR"
  for f in "$tmp"/ttf/*.ttf; do
    [ -e "$FONT_DIR/$(basename "$f")" ] || cp "$f" "$FONT_DIR/"
  done
  rm -rf "$tmp"
  if command -v fc-cache >/dev/null 2>&1; then fc-cache -f "$FONT_DIR" >/dev/null; fi
}

install_ghostty_config() {
  place "$REPO_DIR/ghostty/config" "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"

  # On macOS Ghostty also loads this file *after* ~/.config, so any settings in it win.
  local mac_cfg="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  if [ -f "$mac_cfg" ] && grep -qvE '^[[:space:]]*(#|$)' "$mac_cfg"; then
    warn "$mac_cfg has settings that override the Rex config; comment them out if the look is off"
  fi
}

install_starship() {
  local bin_dir=""
  if command -v starship >/dev/null 2>&1 || [ -x "$HOME/.local/bin/starship" ]; then
    say "starship already installed"
  elif command -v brew >/dev/null 2>&1; then
    say "installing starship with Homebrew"
    brew install starship
  else
    bin_dir="$HOME/.local/bin"
    say "installing starship to $bin_dir"
    mkdir -p "$bin_dir"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$bin_dir" >/dev/null
  fi

  place "$REPO_DIR/starship/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

  local shell rc hook
  shell="$(basename "${SHELL:-zsh}")"
  case "$shell" in
    zsh) rc="${ZDOTDIR:-$HOME}/.zshrc"; hook='eval "$(starship init zsh)"' ;;
    bash) rc="$HOME/.bashrc"; hook='eval "$(starship init bash)"' ;;
    fish) rc="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"; hook='starship init fish | source' ;;
    *) warn "unknown shell '$shell'; add the starship init line yourself (see starship.rs)"; return ;;
  esac

  if [ -f "$rc" ] && grep -q 'starship init' "$rc"; then
    say "$rc already starts starship"; return
  fi
  mkdir -p "$(dirname "$rc")"
  {
    printf '\n%s\n' "$MARK_BEGIN"
    if [ -n "$bin_dir" ]; then
      if [ "$shell" = fish ]; then
        printf 'fish_add_path $HOME/.local/bin\n'
      else
        printf 'export PATH="$HOME/.local/bin:$PATH"\n'
      fi
    fi
    printf '%s\n%s\n' "$hook" "$MARK_END"
  } >>"$rc"
  say "added starship to $rc"
}

validate() {
  local g=""
  if command -v ghostty >/dev/null 2>&1; then
    g="$(command -v ghostty)"
  elif [ -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]; then
    g=/Applications/Ghostty.app/Contents/MacOS/ghostty
  fi
  if [ -z "$g" ]; then warn "Ghostty not found; install it from https://ghostty.org"; return; fi
  if "$g" +validate-config >/dev/null 2>&1; then
    say "ghostty +validate-config passed"
  else
    warn "ghostty +validate-config reported problems:"
    "$g" +validate-config >&2 || true
  fi
}

[ "$DO_FONT" = 1 ] && install_font
install_ghostty_config
[ "$DO_STARSHIP" = 1 ] && install_starship
validate

say "done. Open a new Ghostty window (or press Cmd+Shift+, to reload) and start a new shell."
