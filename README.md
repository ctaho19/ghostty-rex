# ghostty-rex

A [Ghostty](https://ghostty.org) setup inspired by the Rex demos from Superlogical: opaque Tokyo Night colors, JetBrains Mono 13pt, a seamless titlebar, a non-blinking block cursor, and a two-line [Starship](https://starship.rs) prompt.

## Install

```sh
git clone https://github.com/ctaho19/ghostty-rex.git ~/.ghostty-rex
~/.ghostty-rex/install.sh
```

Then open a new Ghostty window (or press `Cmd+Shift+,`) and start a new shell.

You don't need Homebrew or admin rights. The script:

- downloads JetBrains Mono into your user font folder, unless it's already installed
- copies `ghostty/config` to `~/.config/ghostty/config`
- installs Starship (with Homebrew if you have it, otherwise to `~/.local/bin`), copies `starship/starship.toml` to `~/.config/starship.toml`, and adds `starship init` to your `.zshrc`, `.bashrc`, or `config.fish`
- runs `ghostty +validate-config`

Any file it would replace is first renamed to `<file>.bak-<timestamp>`. You can run it again safely.

| Option | Effect |
| --- | --- |
| `--link` | Symlink the configs to the clone, so `git pull` updates them |
| `--no-font` | Skip the font |
| `--no-starship` | Skip Starship entirely |

## Uninstall

```sh
~/.ghostty-rex/uninstall.sh
```

This puts back the newest backup of each config (or deletes the config if there wasn't one) and removes the Starship lines from your shell rc. The font and the `starship` binary stay installed.

## Notes

- You need Ghostty 1.2 or newer, because older versions call the theme `tokyonight` instead of `TokyoNight`.
- On macOS, Ghostty also reads `~/Library/Application Support/com.mitchellh.ghostty/config`, and settings in that file win. The installer warns you if that file has any.
- Ghostty can't do the parts of Rex outside the terminal itself (floating rounded panes, the sidebar, peek view), so this setup leaves them out.
