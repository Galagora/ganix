Install by dumping somewhere in `$HOME` and symlinking [configuration.nix](configuration.nix) to `/etc/nixos/configuration.nix`. Everything is in there, unless specified otherwise

Features:

- Nixpkgs pinned with niv
- XDG Autostart without a DE via systemd ([adexd.sh](adexd.sh)), as recommended by [dex](https://github.com/jceb/dex#autostart-alternative)
- Working (SIMCOM SIM800C) USB modem with ModemManager or atinout (minicom works out-of-the-box). Just turn off flow control in udev
- /bin/bash
- Surfshark (wip)
- Firefox with tabs and the URL bar at the bottom of the window ([userChrome.css](dotfiles/userChrome.css)), and some extensions and privacy settings ([home.nix](home.nix))
- Fixes to some problems I had with the hardened profile (segfaults, non-functional OSProber)
- Includes Sway, Zsh, QEMU (virt-manager), Chromium, [Emacs](https://github.com/galagora/.doom.d) (Doom)
