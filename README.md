# ghostty-rex

A [Ghostty](https://ghostty.org) setup built from Rex Beta's own design tokens: **Static Noir** (dark) and **Ivory Gallery** (light), JetBrains Mono, a seamless titlebar, macOS glass, and Rex's pane and tab keymap. It also installs a two-line [Starship](https://starship.rs) prompt.

## Install

```sh
git clone https://github.com/ctaho19/ghostty-rex.git ~/.ghostty-rex
~/.ghostty-rex/install.sh
```

Then open a new Ghostty window (or press `Cmd+Shift+,`) and start a new shell.

You don't need Homebrew or admin rights. The script:

- downloads JetBrains Mono into your user font folder, unless it's already installed
- copies `ghostty/config` and the `ghostty/themes/rex-*` palettes to `~/.config/ghostty/`
- installs Starship (with Homebrew if you have it, otherwise to `~/.local/bin`), copies `starship/starship.toml` to `~/.config/starship.toml`, and adds `starship init` to your `.zshrc`, `.bashrc`, or `config.fish`
- runs `ghostty +validate-config`

Any file it would replace is first renamed to `<file>.bak-<timestamp>`. You can run it again safely.

| Option | Effect |
| --- | --- |
| `--link` | Symlink the configs to the clone, so `git pull` updates them |
| `--no-font` | Skip the font |
| `--no-starship` | Skip Starship entirely |

## What matches Rex

- **Palette**: the exact Static Noir dark and Ivory Gallery light colors from Rex Beta, including all 16 ANSI colors. Abyssal Trench is also included as an alternative dark theme.
- **Type**: JetBrains Mono, the font GoRex embeds and the one in its screenshot.
- **Window**: transparent titlebar, 14pt pane inset, macOS glass at 0.97, inactive-pane fade.
- **Keys**: split right/down, pane focus, zoom, command palette, and prompt jumps already match Ghostty's macOS defaults. The config adds `Cmd+Enter` split auto, `Ctrl+Cmd+F` fullscreen, `Ctrl+Tab` tabs, and `Alt+Cmd+W` close tab.

## What Ghostty can't do

Rex's pane cards with program headers, pill tabs, activity dots, and persistent sessions are Rex's own views. Ghostty has no UI plugin API, so this setup leaves them out. The nearest equivalents are Ghostty 1.4's split drag handles, `Cmd+Shift+P` command palette, native tabs, and shell-integrated titles.

## Notes

- Ghostty 1.4+ on macOS 26+ is needed for `background-blur = macos-glass-regular`. On older macOS, change it to `background-blur = 20`; on older Ghostty, remove the line.
- On macOS, Ghostty also reads `~/Library/Application Support/com.mitchellh.ghostty/config`, and settings in that file win. The installer warns you if that file has any.
- The Starship prompt is independent of the Ghostty palette; edit `starship/starship.toml` if you want its colors to track the theme.

## Uninstall

```sh
~/.ghostty-rex/uninstall.sh
```

This puts back the newest backup of each config (or deletes the config if there wasn't one), removes the Rex themes, and removes the Starship lines from your shell rc. The font and the `starship` binary stay installed.
