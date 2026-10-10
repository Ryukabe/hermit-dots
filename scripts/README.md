# Hermit scripts

Every script the keybinds, shells and menus call lives here. This folder is linked
to ~/.config/hermit/scripts, so call scripts from that path.

- End the file name in .sh. The installer makes every .sh file under config/ executable.
- Keep a script's paths absolute (for example $HOME/.config/ags/...), not relative to the script.

| Script | Called by | What it does |
| --- | --- | --- |
