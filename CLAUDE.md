# CLAUDE.md

NixOS flake config.

- `configuration.nix`: system; `security.lsm` drops bpf, see the comment there.
- `home.nix`: home-manager.
- `hyprland.nix`, `waybar.nix`: desktop.
- `github-runners.nix`, `github-runner/`: 3 local GramrEMS CI runners (systemd --user `gramr-runner-r1..3`).
- `suspend-and-hibernate.nix`; `scripts/` (rofi, wallpaper).

Do not kill or relaunch the user's browser; give the command instead.
