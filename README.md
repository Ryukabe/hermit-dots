<p align="center">
  <img src="assets/logo.svg" width="160" alt="hermit-dots logo">
</p>

<h1 align="center">hermit-dots</h1>

<p align="center">
  Two shells, one setup. Quickshell and AGS on Hyprland, switched with a single keybind.
</p>

---

## Preview

<!-- TODO: screenshots, ideally a GIF of the island morphing (clock -> media -> launcher) -->

## Why "hermit"?

A hermit crab moves between shells. So does this setup: you can swap the whole desktop shell without touching the rest of your config.

## The shells

| Shell | What it is |
| --- | --- |
| **Quickshell** | A single floating island bar at the top of the screen. It shows a clock at rest and morphs into media controls, volume and brightness, an app launcher, a power menu and a control center. Written in QML/JS only. Inspired by Sane's Quickshell setup. |
| **AGS** | A dashboard and quick settings panel, toggled with `ags request`. <!-- TODO: describe the AGS shell --> |

## Switching shells

The active shell is stored in `~/.config/hypr/.active-shell`. Whenever Hyprland loads or reloads, `binds.lua` reads that file and loads the bind modules in this order: `submaps`, `common`, the active shell's file (`qs` or `ags`), then `custom`. If the file is missing or contains anything other than `ags`, the Quickshell binds are used. Only one shell's file is loaded at a time, so both shells can use the same keys (such as the volume keys) for different commands without clashing.

| Keys | Action |
| --- | --- |
| `Super + Ctrl + Alt + Q` | Switch to Quickshell |
| `Super + Ctrl + Alt + A` | Switch to AGS |
| `Super + Shift + R` | Reload Hyprland (and re-read the binds) |

<!-- TODO: confirm what switch-shell.sh does (stops the running shell, starts the other, writes .active-shell) -->

The bind files live in `~/.config/hypr/modules/binds/`:

| File | Purpose |
| --- | --- |
| `mainmod.lua` | Defines the main modifier (Super) in one place |
| `common.lua` | Binds that work in every mode |
| `qs.lua` | Quickshell binds, all through `qs ipc call` |
| `ags.lua` | AGS binds, through `ags request` plus direct commands |
| `custom.lua` | Binds written by Quickshell's Settings > Keybinds page |
| `submaps.lua` | The capture submap used while rebinding; `Esc` exits it |

## Palette

A graphite base with warm text and one sage accent.

| Role | Hex |
| --- | --- |
| Base (deep / default / surface) | `#0A0A0A` / `#101010` / `#1C1C1C` |
| Text (primary / muted) | `#F6F1EA` / `#8C8C8C` |
| Accent (primary / light / deep) | `#77B0A8` / `#8FC8BF` / `#5F8F87` |
| Status (success / warning / error) | `#8CCF7E` / `#FCB163` / `#DF5B61` |

The full palette, including the terminal colors, is in [`palette.json`](palette.json).

## Installation

TODO: install or symlink steps for the configs in `config/`.

The binds depend on these programs: Hyprland, Quickshell, AGS, `brightnessctl`, WirePlumber (`wpctl`), `playerctl`, `hyprshot`, `hyprpicker`, `hyprlock`, `wlogout`, `cliphist`, kitty, alacritty, nautilus, thunar, zen-browser, helium-browser, VS Code, Obsidian and Spotify. The screenshot bind targets the monitor named `eDP-1`, so change that if your display has a different name.

## Keybinds

`Super` is the main modifier.

### Quickshell mode

| Keys | Action |
| --- | --- |
| `Super + ,` | Settings |
| `Super + Tab` | Workspace switcher |
| `Super + Space` | App launcher |
| `Super + V` | Clipboard history |
| `Super + A` | Control center |
| `Super + N` | Notification center |
| `Super + Esc` | Power menu |
| `Super + L` | Lock screen |
| `Super + T` | Theme switcher |
| `Super + W` | Wallpaper switcher |
| Brightness and volume keys | Adjust through the island |

### AGS mode

| Keys | Action |
| --- | --- |
| `Super + grave` | Quick settings |
| `Super + Shift + grave` | Dashboard |
| Brightness and volume keys | Run `brightnessctl` and `wpctl` directly |

### Windows and workspaces (always on)

| Keys | Action |
| --- | --- |
| `Super + arrows` | Move focus |
| `Super + 1-0` | Go to workspace |
| `Super + Shift + 1-0` | Move window to workspace |
| `Alt + Tab` | Cycle windows |
| `Super + left mouse` / `right mouse` | Drag / resize window |
| `Super + Shift + F` | Toggle floating |
| `Super + Shift + P` | Pseudo-tile |
| `Super + Alt + K` | Change layout |
| `Alt + F4` | Close window |
| `Ctrl + Alt + Delete` | Kill a window (click it) |

### Apps (always on)

| Keys | App |
| --- | --- |
| `Super + Return` / `Super + Alt + Return` | kitty / alacritty |
| `Super + F` / `Super + Alt + F` | nautilus / thunar |
| `Super + B` / `Super + Alt + B` | zen-browser / helium-browser |
| `Super + E` | VS Code |
| `Super + O` | Obsidian |
| `Super + S` | Spotify |

### System (always on)

| Keys | Action |
| --- | --- |
| `Super + Ctrl + Alt + Return` | Run the system reload script |
| `Super + Alt + R` | Reload AGS |
| `Super + F4` | wlogout |
| `Shift + Alt + L` | hyprlock |
| `Super + Print` / `Super + Shift + Print` | Screenshot of the screen / of a region |
| `Super + P` | Color picker (copies hex) |
| `Super + Shift + V` | Wipe clipboard history |
| Media keys | Play/pause, next, previous (`playerctl`) |

## Credits

- Island concept inspired by Sane's Quickshell setup
- Status and terminal colors adapted from the Everblush and rxyhn themes

## License

TODO
