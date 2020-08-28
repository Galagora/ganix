Install by dumping somewhere in `$HOME` and symlinking [configuration.nix](configuration.nix) to `/etc/nixos/configuration.nix`. Everything is in there, unless specified otherwise

Features:

- Nixpkgs pinned with niv
- XDG Autostart without a DE via systemd ([adexd.sh](adexd.sh)), as recommended by [dex](https://github.com/jceb/dex#autostart-alternative)
- Working (SIMCOM SIM800C) USB modem with ModemManager or atinout (minicom works out-of-the-box). Just turn off flow control in udev
- /bin/bash
- Surfshark (wip). Tip: for free, ad-free Spotify, run it in a cgroup (systemd slice) together with a VPN (which is a systemd service) pointed to a location where Spotify is not available. I disclaim all liability
- Firefox with tabs and the URL bar at the bottom of the window ([userChrome.css](dotfiles/userChrome.css)), and some extensions and privacy settings ([home.nix](home.nix))
- Working `<nixpkgs/nixos/modules/profiles/hardened.nix>` (no segfaults, OSProber)
- Includes Sway, Zsh, QEMU (virt-manager), Chromium, [Emacs](https://github.com/galagora/.doom.d) (Doom)
