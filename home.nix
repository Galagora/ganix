{home-manager, pkgs, ...}:
let
  sources = import ./nix/sources.nix;
in {
  # home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ao = {lib, ...}: {
    # home.packages = with pkgs.unstable; [
    #  firefox/*-wayland shadowfox tridactyl-native*/
    # ];
    # services.emacs.enable = true;
    services.lorri.enable = true;
    programs.direnv.enable = true;
    programs.direnv.enableNixDirenvIntegration = true;
    programs.zsh = {
      localVariables = {
        SLICE = 54;
      };
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git" "python" "man" "vi-mode"
        ];
        theme = "agnoster";
        # customPkgs = with pkgs; [
        #   nix-zsh-completions deer fzf-zsh
        # ];
      };
      # defaultKeymap = "viins";
      enableAutosuggestions = true;
      # syntaxHighlighting.enable = true;
      # Use zsh in nix-shell
      initExtra = ''
        any-nix-shell zsh --info-right | source /dev/stdin
      '';
    };

    xdg.enable = true;
    xdg.userDirs = {
      enable = true;
      desktop     = "$HOME/desktop";
      documents   = "$HOME/documents";
      download    = "$HOME/downloads";
      music       = "$HOME/music";
      pictures    = "$HOME/pictures";
      publicShare = "$HOME/public";
      templates   = "$HOME/templates";
      videos      = "$HOME/videos";
    };
    programs.git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "galagora";
      userEmail = "lightningstrikeiv@gmail.com";
      extraConfig = {
        credential.helper = "libsecret";
        github = {
          user = "galagora";
        };
      };
    };

    programs.firefox = {
      enable = true;
      extensions = with pkgs.nur.rycee.firefox-addons; [
        darkreader ublock-origin https-everywhere # umatrix
        bitwarden violentmonkey # tridactyl
        old-reddit-redirect
      ];
      profiles.default = {
        id = 0;
        isDefault = true;
        userChrome = lib.strings.fileContents ./dotfiles/userChrome.css;
        settings = {
          "devtools.theme" = "dark";
          "browser.tabs.insertAfterCurrent" = true;
          # Performance (Hardware video accceleration)
          "widget.wayland-dmabuf-vaapi.enabled" = true;
          "gfx.webrender.all" = true;
          "media.ffvpx.enabled" = false;
          # Privacy
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "network.cookie.lifetimePolicy" = 2; # Delete cookies on close
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          ## Telemetry
          "network.allow-experiments" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          # Turn off WebRTC
          "media.peerconnection.turn.disable" = true;
          "media.peerconnection.use_document_iceservers" = false;
          "media.peerconnection.video.enabled" = false;
          "media.peerconnection.identity.timeout" = 1;
          # Turn off warnings
          "browser.aboutConfig.showWarning" = false;
          "browser.tabs.warnOnClose" = false;
          "browser.shell.checkDefaultBrowser" = false;
          # Misc.
          "extensions.pocket.enabled" = false;
        };
      };
    };

    gtk = with pkgs; with gnome3; {
      enable = true;
      iconTheme = {
        name = "Suru";
        package = ubuntu-themes;
      };
      theme.name = "Yaru-dark";
      theme.package = yaru-theme;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    home.file = {
      "userChrome.css".source = ./dotfiles/userChrome.css;
      # ".bashrc".source = ./dotfiles/.bashrc;
      ".zshrc".source = ./dotfiles/.zshrc;
      "zsh-vim-mode".source = sources.zsh-vim-mode;
      # ".profile".source = ./dotfiles/.profile;

      # "spacemacs".source = sources.spacemacs;
      # "spacemacs".recursive = true;
      # "doom-emacs".source = pkgs.fetchFromGitHub {
      #   owner = "hlissner";
      #   repo = "doom-emacs";
      #   rev = "99eea1d3e25d8bf6034ff31d231e4ecfc3dc628c";
      #   sha256 = "0km1q1dgvixvx1si4plzyn9vnk9kidrgc6p07xx956i85mg8ami9";
      # };
      # "doom-emacs".recursive = true;

      ".ghci".source = ./dotfiles/.ghci;
      ".stack/config.yaml".source = ./dotfiles/stack.yaml;

      #".mozilla/native-messaging-hosts/tridactyl.json" = {
      #  source = ../../.nix-profile/lib/mozilla/native-messaging-hosts/tridactyl.json;
      #};
      #".local/share/tridactyl/native_main.py" = {
      #  source = ../../.nix-profile/share/tridactyl/native_main.py;
      #};

      ".config/sway/config".source = ./dotfiles/sway.conf.sh;
      ".Xresources".source = ./dotfiles/.Xresources;
      ".config/waybar/config".source = ./dotfiles/waybar.json;
      ".config/waybar/style.css".source = ./dotfiles/waybar.css;
      ".config/neofetch/config".source = ./dotfiles/neofetch.conf.sh;
      ".config/mako/config".source = ./dotfiles/mako.conf;
      ".config/alacritty/alacritty.yml".source = ./dotfiles/alacritty.yml;
      ".xkb/symbols/mylayout".source = ./dotfiles/mylayout.xkb;
      ".emacs-profiles.el".source = ./dotfiles/eprofiles.el;
    };
    programs.home-manager.enable = true;

    home.stateVersion = "20.03"; # Do not edit
    home.packages = with pkgs; [
      # oguri
      # Shell utilities
      mkpasswd gitAndTools.gitFull wget unzip tealdeer pavucontrol
      jq /*Parse JSON*/ neofetch ripgrep parted fd /*find*/
      iftop cdrkit /*genisoimage*/ strace traceroute
      dtrx /*non-braindead extract*/ trash-cli
      moreutils
      # binutils-unwrapped
      # System info
      lshw lsof /*list open files*/ glxinfo inxi /*debugging info*/
      pciutils /*lspci*/ hardinfo libva-utils
      # Graphical utils
      gparted brasero
      # Monitoring
      htop tree ncdu psmisc /*pstree killall fuser*/
      # Network
      nethogs bmon tcptrack slurm bind /*DNS*/
      # speedometer
      # Terminal Emulators
      termite st kitty rxvt-unicode hyper
      # enlightenment.terminology
      # TUI apps
      tmux lynx ranger
      # Development
      # vimHugeX atom vscode
      python38Packages.grip
      # sqlite /*for emacs*/
      # Android
      # androidStudioPackages.canary
      # androidStudioPackages.stable
      # emacsGcc
      jetbrains-mono
      jetbrains.jdk
      # androidenv.androidPkgs_9_0.androidsdk
      p7zip
      # heimdall heimdall-gui
      flutter dart
      gitAndTools.git-secret
      # SIM/Modem
      usbutils atinout modemmanager minicom tio modem-manager-gui ofono
      unrar gcc gdb
      usb-modeswitch
      glib /*gdbus*/ qt512.qttools /*qdbus*/
      # bustle
      dfeet gnome3.gnome-software
      # openjdk11
      # Shells and scripting languages
      zsh
      # fish elvish
      shellcheck
      perl
      sqlitebrowser
      # Nix stuff
      hydra-check
      lorri niv any-nix-shell
      nix-prefetch-scripts nix-prefetch-github
      nixpkgs-review nixfmt
      cachix
      appimage-run patchelf file
      # steam-run
      # Internet
      # firefox-wayland shadowfox # tridactyl-native
      # dejsonlz4
      # chromium-dev-ozone
      chromium
      gnome3.file-roller
      buku transmission-gtk deluge aria2
      gnutls
      # Entertainment
      youtube-dl mpv vlc spotify
      # calibre
      # Documents
      zathura # joplin-desktop
      # graphviz shotwell pandoc
      # Virtualization
      # virt-manager qemu spice_gtk
      # Security
      polkit_gnome apparmor-bin-utils pass pinentry-gnome
      # UI
      # qt5.qtwayland
      ly adwaita-qt breeze-icons
      yaru-theme ubuntu-themes
      # Desktop
      gnome3.nautilus
      # dolphin gnome3.gnome-system-monitor ksysguard
      xdg_utils xorg.xdpyinfo xorg.xrdb
      playerctl brightnessctl
      insync
      postman
      # JS
      nodejs_latest nodePackages.http-server
      # clojure lumo
      # Python
      poetry nodePackages.pyright
      # python-language-server
      # Haskell
      stack
      # ghcide-ghc8102
      haskell-language-server
    ]
    # ++ (with pkgs.hls-ghc8102; [
    #   hls hls-wrapper hls-renamed
    #   # hls-wrapper
    # ])
    ++ (with haskellPackages; [
      hpack implicit-hie cabal-install hoogle
    ]) ++ (with haskell.packages.ghc8102; [
      ghc
    ]) ++ (with python38Packages; [
      pip python
    ])
    ++ (with pkgs; [((emacsPackagesNgGen emacsGcc).emacsWithPackages (epkgs: [
     epkgs.vterm
    ]))]);
    # ++ (with pkgs; with xorg; with sway-contrib; [
    #   swaylock swayidle mako wofi waybar dmenu bemenu
    #   grimshot
    #   wmfocus /*focus windows by label*/
    #   xwayland xeyes wev /*record wayland kb events*/
    #   alacritty
    # ]);
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      "jinjaccalgkegednnccohejagnlnfdag" # Violentmonkey
      "dcpihecpambacapedldabdbpakmachpb;https://github.com/iamadamdev/bypass-paywalls-chrome/raw/master/updates.xml"
      "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
    ];
  };
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [
       "git" "python" "man" "vi-mode"
    ];
    theme = "agnoster";
    customPkgs = with pkgs; [
      nix-zsh-completions deer fzf-zsh
    ];
  };
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  # programs.zsh.syntaxHighlighting.enable = true;
}
