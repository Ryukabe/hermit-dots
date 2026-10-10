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
| **Quickshell** | A single floating island bar at the top of the screen. It shows a clock at rest and morphs into media controls, volume and brightness, an app launcher, a power menu and a control center. Written in QML/JS only. Inspired by SaneAspect's Quickshell setup. |
| **AGS** | A GTK4 shell built on [AGS](https://github.com/Aylur/ags) and the Astal libraries, with a dashboard and a quick settings panel, both toggled with `ags request`. Its widgets cover workspaces, media, Wi-Fi, volume, battery, notifications and a Bluetooth toggle, and its styles are compiled from SCSS with dart-sass. It also starts a small polkit helper written in Vala, which the launch script rebuilds whenever its source changes. |

Waybar is not part of this setup for now. It is a status bar, not a shell, and may come back later as an optional bar.

## Installation

Requires an Arch-based distro. The Hyprland config is written in Lua (`hyprland.lua`), so you need a Hyprland build that supports Lua configs.

```bash
git clone https://github.com/Ryukabe/hermit-dots.git ~/hermit-dots
cd ~/hermit-dots
./install/install.sh
```

The installer first asks which shells you want: both, Quickshell only, or AGS only. Then it runs its modules in order:

| Module | What it does |
| --- | --- |
| `base` | Optional system update, build tools, git, and an AUR helper (builds `yay` if you have neither `yay` nor `paru`) |
| `hyprland` | Hyprland, hypridle, hyprlock, hyprpicker, hyprshot, wlogout, clipboard tools (`wl-clipboard`, `cliphist`, `wl-clip-persist`), audio and media tools, `awww` (wallpaper daemon) and `matugen` |
| `quickshell` | Quickshell (skipped if you didn't choose it) |
| `fonts` | Material Symbols, plus SF Pro, SF Serif and SF Mono downloaded into `/usr/local/share/fonts/otf` |
| `theme` | The Bibata-Modern-Ice cursor, applied with `gsettings` |
| `apps` | kitty, alacritty, thunar, nautilus, neovim, zsh, fish, and optionally zen-browser, helium-browser, VS Code, Obsidian and Spotify |
| `dotfiles` | Symlinks everything in `config/` into `~/.config` |
| `ags` | AGS, the Astal libraries, the polkit helper's build dependencies, then `npm install` in `~/.config/ags` (skipped if you didn't choose it) |
| `network` | Optional. Switches NetworkManager's Wi-Fi backend to iwd. It asks first and defaults to no, because it affects the whole system |

Things worth knowing:

- **Symlinks.** Your `~/.config` entries point back into the repo, so keep the clone where it is. The installer refuses to run from `/tmp`.
- **Nothing is overwritten.** Anything already in `~/.config` is renamed to `<name>.bak-<timestamp>` first.
- **Apps are optional.** The `apps` module asks before each group (terminals, file managers, shells, browsers, VS Code, Obsidian, Spotify), so you can skip any of them.
- **Single-shell installs.** If you pick only one shell, the other shell's config is not linked, and `~/.config/hypr/.active-shell` is set so Hyprland loads the right binds. Your choice is saved in `~/.local/state/hermit-dots/shells`.
- **Updating.** Settings > About checks GitHub and pulls new commits (fast-forward only). Because the configs are symlinks, a pull updates them straight away.
- **Resuming.** If a module fails, the installer stops and prints the command to resume, for example `./install/install.sh --only fonts`.

Options:

| Command | Effect |
| --- | --- |
| `./install/install.sh --list` | List the modules |
| `./install/install.sh --shells qs` | Choose shells without being asked (`qs`, `ags` or `both`) |
| `./install/install.sh --only quickshell,dotfiles` | Run only these modules |
| `./install/install.sh --skip fonts,network` | Run everything except these modules |
| `./install/install.sh --yes` | Accept every prompt's default answer (uses your saved shell choice, or both on a first run) |

Each module also runs on its own, for example `bash install/modules/40-fonts.sh`.

The binds depend on these programs: Hyprland, Quickshell, AGS, `brightnessctl`, WirePlumber (`wpctl`), `playerctl`, `hyprshot`, `hyprpicker`, `hyprlock`, `wlogout`, `cliphist`, kitty, alacritty, nautilus, thunar, zen-browser, helium-browser, VS Code, Obsidian and Spotify. The AGS polkit helper is built with `valac` and needs the polkit agent and gobject libraries, GIO and json-glib. The screenshot bind targets the monitor named `eDP-1`, so change that in `common.lua` if your display has a different name.

## Switching shells

The active shell is stored in `~/.config/hypr/.active-shell`. Whenever Hyprland loads or reloads, `binds.lua` reads that file and loads the bind modules in this order: `submaps`, `common`, the active shell's file (`qs` or `ags`), then `custom`. If the file is missing or contains anything other than `ags`, the Quickshell binds are used. Only one shell's file is loaded at a time, so both shells can use the same keys (such as the volume keys) for different commands without clashing.

| Keys | Action |
| --- | --- |
| `Super + Ctrl + Alt + Q` | Switch to Quickshell (stops it if it is already running) |
| `Super + Ctrl + Alt + A` | Switch to AGS (stops it if it is already running) |

Both keys run `scripts/switch-shell.sh` with `qs` or `ags`. If the shell you asked for is already running, the script just stops it and leaves `.active-shell` as it was. Otherwise it stops the other shell, writes the new name to `.active-shell`, reloads Hyprland so the matching binds load, and starts the new shell. AGS is started and stopped through `ags-launch-kill.sh`, which also manages the polkit helper and launches AGS with `GSK_RENDERER=gl`.

The bind files live in `~/.config/hypr/modules/binds/`:

| File | Purpose |
| --- | --- |
| `mainmod.lua` | Defines the main modifier (Super) in one place |
| `common.lua` | Binds that work in every mode |
| `qs.lua` | Quickshell binds, all through `qs ipc call` |
| `ags.lua` | AGS binds, through `ags request` plus direct commands |
| `custom.lua` | Binds written by Quickshell's Settings > Keybinds page |
| `submaps.lua` | The capture submap used while rebinding; `Esc` exits it |

## Keybinds

`Super` is the main modifier.

### Quickshell mode

| Keys | Action |
| --- | --- |
| `Super + ,` | Settings |
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
| `Super + Alt + R` | Reload AGS |
| Brightness and volume keys | Run `brightnessctl` and `wpctl` directly (volume can go up to 150%) |

### Windows and workspaces (always on)

| Keys | Action |
| --- | --- |
| `Super + arrows` | Move focus |
| `Super + 1-0` | Go to workspace |
| `Super + Shift + 1-0` | Move window to workspace |
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
| `Super + Shift + R` | Reload Hyprland (re-reads the binds) |
| `Super + Ctrl + Alt + Return` | Run `system_reload.sh` (reload Hyprland and restart the active shell) |
| `Super + F4` | wlogout |
| `Shift + Alt + L` | hyprlock |
| `Super + Print` / `Super + Shift + Print` | Screenshot of the screen / of a region |
| `Super + P` | Color picker (copies hex) |
| `Super + Shift + V` | Wipe clipboard history |
| Media keys | Play/pause, next, previous (`playerctl`) |

## Palette

A graphite base with warm text and one sage accent.

| Role | Hex |
| --- | --- |
| Base (deep / default / surface) | `#0A0A0A` / `#101010` / `#1C1C1C` |
| Text (primary / muted) | `#F6F1EA` / `#8C8C8C` |
| Accent (primary / light / deep) | `#77B0A8` / `#8FC8BF` / `#5F8F87` |
| Status (success / warning / error) | `#8CCF7E` / `#FCB163` / `#DF5B61` |

The full palette, including the terminal colors, is in [`palette.json`](palette.json).

## Credits

- Island concept inspired by SaneAspect's Quickshell setup. SaneAspect is a Hyprland ricing YouTuber.
- Status and terminal colors adapted from the Everblush and rxyhn themes. The sage accent is my own pick.
- Cursor: [Bibata](https://github.com/ful1e5/Bibata_Cursor) by ful1e5.
- Fonts: SF Pro, SF Serif and SF Mono belong to Apple. They are not included in this repo; the installer downloads them from [thelioncape/San-Francisco-family](https://github.com/thelioncape/San-Francisco-family).

## License

Released under the [MIT License](LICENSE).
