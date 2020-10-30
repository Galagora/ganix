# Update them with `niv update && sudo nix-channel upgrade` before running `sudo nixos-rebuild switch`

{ config ? {},
  pkgs ? (import ./nix/sources.nix).nixpkgs,
  options
, lib
, ...
}:
let
  sources = import ./nix/sources.nix;
  # pkgs = sources.nixpkgs;
  # config = (import pkgs {})
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    /etc/nixos/cachix.nix
    (import sources.home-manager {}).nixos
    <nixpkgs/nixos/modules/profiles/hardened.nix>
    # ./hardened.nix
    ./home.nix
    ./binbash.nix
  ];
  # nix.nixPath = ["nixos-config=/etc/nixos/configuration.nix"];
  nixpkgs.pkgs = import sources.nixpkgs {config = {
    allowUnfree = true;
    # Build all packages with pulseaudio support
    pulseaudio = true;
    android_sdk.accept_license = true;
  };};
  nixpkgs.overlays = [
    (final: prev: {
      inherit sources;
      master = import final.sources.nixpkgs-master {config.allowUnfree = true;};
      ganixpkgs = import final.sources.ganixpkgs {
        config.allowUnfree = true;
      };
      nur = (import final.sources.NUR {
        pkgs = import final.sources.nixpkgs {};
      }).repos;
        # (oldAttrs: with lib; with lists; with attrsets; with builtins;
        #   mapAttrsRecursive (kList: v:
        #     replaceStrings ["/lib/openjdk"] ["/lib/openjdk7"] v)
        #     (filterAttrsRecursive (kList: v: (typeOf v) == "string")
        #     oldAttrs)
        # );
      chromium-dev-ozone = import final.sources.nixpkgs-chromium;
      efl = prev.efl.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ "-D wl=true";
      });
    })
    (import sources.emacs-overlay)
  ];

  environment.binbash.enable = true;
  nix.binaryCaches = [ "https://aseipp-nix-cache.global.ssl.fastly.net" ];
  # nix.trustedUsers = ["@wheel"];
  # # VirtualBox
  # nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Shell utilities
    mkpasswd gitAndTools.gitFull wget unzip tealdeer pavucontrol
    jq /*Parse JSON*/ neofetch ripgrep parted fd /*find*/
    iftop cdrkit /*genisoimage*/ strace
    # (lib.lowPrio busybox) /*traceroute*/
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
    enlightenment.terminology termite st kitty rxvt-unicode hyper
    # TUI apps
    tmux lynx ranger
    # Development
    vim atom vscode
    # sqlite /*for emacs*/
    # Android
    androidStudioPackages.canary
    androidStudioPackages.stable
    # emacsGcc
    jetbrains-mono
    jetbrains.jdk
    androidenv.androidPkgs_9_0.androidsdk
    p7zip
    heimdall heimdall-gui
    flutter dart
    gitAndTools.git-secret
    # SIM/Modem
    usbutils atinout modemmanager minicom tio ganixpkgs.modem-manager-gui
    unrar gcc gdb
    usb-modeswitch
    glib /*gdbus*/ qt512.qttools /*qdbus*/
    # bustle
    dfeet gnome3.gnome-software
    # openjdk11
    # Shells and scripting languages
    zsh fish elvish
    nodejs_latest
    perl
    (python38.withPackages (ps: with ps; [
      beautifulsoup4 requests regex flask
    ]))
    python-language-server
    # Haskell
    stack cabal-install
    # Nix stuff
    direnv lorri niv any-nix-shell
    nix-prefetch-scripts nix-prefetch-github
    cachix
    appimage-run patchelf file steam-run
    # Internet
    firefox-wayland shadowfox # tridactyl-native
    dejsonlz4
    # chromium-dev-ozone
    chromium
    gnome3.file-roller
    qutebrowser epiphany netsurf.browser
    buku transmission-gtk deluge aria2
    # Entertainment
    youtube-dl mpv vlc spotify
    # Documents
    zathura # joplin-desktop
    graphviz shotwell
    # Virtualization
    virt-manager qemu spice_gtk
    # Security
    polkit_gnome apparmor-bin-utils pass pinentry-gnome
    # UI
    qt5.qtwayland ly adwaita-qt breeze-icons
    yaru-theme ubuntu-themes
    # Desktop
    gnome3.nautilus dolphin
    xdg_utils xorg.xdpyinfo xorg.xrdb
    playerctl brightnessctl
  ] ++ ( with pkgs.python38Packages; [
    # python-language-server
  ]);

  services.flatpak.enable = true;
  xdg.portal.enable       = true;
  xdg.portal.gtkUsePortal = true;
  # 1. Samsung phones aren't modems
  # 2. Modeswitch for the usb modem
  services.udev.extraRules = ''
    ATTRS{idVendor}=="04e8", ATTRS{product}=="Gadget Serial", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{MTP_NO_PROBE}="1"
    # Don't use flow-control with the SIM800C RS232 (i.e. serial) USB modem! (ENV{ID_MM_TTY_BAUDRATE}="115200")
    # Page 18: https://simcom.ee/documents/SIM800C/SIM800C_EVB%20kit_User%20Guide_V1.01.pdf
    ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523",  ENV{ID_MM_TTY_FLOW_CONTROL}="none", ENV{ID_MM_DEVICE_PROCESS}="1"
  '';

  programs.command-not-found = {
    enable = true;
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

  programs.adb.enable = true;
  environment.pathsToLink = [
    "/jars"
  ];
  services.emacs = {
   enable = true;
   defaultEditor = true;
   package = with pkgs; ((emacsPackagesNgGen emacsUnstable).emacsWithPackages (epkgs: [
     epkgs.vterm
   ]));
  };

  programs.zsh.enable = true;
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
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  # Use zsh in nix-shell
  programs.zsh.promptInit = ''
    any-nix-shell zsh --info-right | source /dev/stdin
  '';

  services.xserver.displayManager = {
    gdm = {
      enable = true;
    };
    defaultSession = "sway";
  };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; with xorg; with sway-contrib; [
      swaylock swayidle mako wofi waybar dmenu bemenu
      grimshot
      wmfocus /*focus windows by label*/
      xeyes wev /*record wayland kb events*/
      # xwayland
      alacritty
    ];
    extraSessionCommands = ''
      # export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      # export QT_QPA_PLATFORM=wayland
      # export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd'

    '';
  };
  programs.waybar.enable = true;

  # Implement XDG autostart
  systemd.user.targets.autostart = {
    unitConfig = {
      Description="Current graphical user session";
      Documentation="man:systemd.special(7)";
      RefuseManualStart = "no";
      StopWhenUnneeded = "no";
    };
  };
  systemd.user.services = with builtins;
    fromJSON (readFile ./generated/autostart.json );

  # fonts.enableDefaultFonts = true;
  # fonts.fontconfig.defaultFonts.sansSerif = ["Ubuntu"];
  # fonts.fonts = with pkgs; [
  #   source-code-pro source-sans-pro source-serif-pro
  #   ubuntu_font_family font-awesome
  # ];

  # networking.networkmanager.enable = true;
  systemd.services.ModemManager ={
    enable = true;
    wantedBy = ["multi-user.target"];
  };
  services.udev.packages = with pkgs; [
    usb-modeswitch-data
  ];
  # services.connman.enable = true;
  # services.openvpn.servers = {
  #   USA = {
  #     config = "config /home/ao/downloads/us-bdn.prod.surfshark.comsurfshark_openvpn_udp.ovpn";
  #     autoStart = false;
  #     updateResolvConf = true;
  #     authUserPass = with builtins; with (fromJSON (readFile ./secrets.json)).surfshark-USA; {
  #       inherit username password;
  #     };
  #   };
  # };

  # Use GNOME's authentication agent
  services.gnome3.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  # GUI
  programs.seahorse.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };
  programs.gnupg.package = pkgs.gnupg.override {
    pinentry = pkgs.pinentry-gnome;
    guiSupport = true;
  };

  security.allowUserNamespaces = true;
  security.allowSimultaneousMultithreading = true;
  # Hardened default is scudo, but it causes segfaults
  environment.memoryAllocator.provider = "libc";
  # True prevents finding the EFI bootloaders of other Linuxes in GRUB
  security.lockKernelModules = false;

  # VM guests are all trusted, so don't flush CPU cache before
  # entering
  security.virtualisation.flushL1DataCache = "never";
  # Needed to store virt-manager settings
  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [gnome3.dconf];

  virtualisation.libvirtd.enable = true;
  # Needed for passing through USB devices to VMs
  security.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice_gtk}/bin/spice-client-glib-usb-acl-helper";
  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  #   # package = pkgs.virtualbox;
  # };

  programs.qt5ct.enable = true;
  # qt5 = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };
  # Don't manage users except through Nix
  users.mutableUsers = false;
  users.users.ao = {
    shell = pkgs.zsh;
    extraGroups = [
      "wheel" "networkmanager" "libvirtd" "vboxusers" "adbusers"
      "libvirt" "kvm"
      "dialout" /*to access tty devices*/
    ];
    createHome = true;
    isNormalUser = true;
    home = "/home/ao";
    hashedPassword = with builtins; (fromJSON (readFile ./secrets.json)).ao;
  };

  users.users.root.hashedPassword = with builtins; (fromJSON (readFile ./secrets.json)).root;

  # system.autoUpgrade.enable = true;

  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub = {
    enable = true;
    # Generate GRUB boot menu, but don't install GRUB
    devices = ["nodev"];
    useOSProber = true;
    efiSupport = true;
  };

  # Don't automatically enter NixOS
  boot.loader.timeout = null;

  # Deprecated
  networking.useDHCP = false;
  networking.interfaces.enp37s0.useDHCP = true;

  time.timeZone = "Asia/Istanbul";

  # When there's < 3GiB free, delete until 10GiB is free
  nix.extraOptions = ''
    min-free = ${toString (3 * 1024 * 1024 * 1024)}
    # max-free = ${toString (10 * 1024 * 1024 * 1024)}
  '';

  sound = {
    enable = true;
    # Legacy sound system emulation
    enableOSSEmulation = false;
    # Keyboard volume control.
    # FIXME: Default keys not present on TKL (small) keyboard
    mediaKeys.enable = true;
  };
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [pkgs.pulseaudio-modules-bt];
  hardware.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    config = {
      # General = { ControllerMode = "bredr"; };
    };
  };
  services.blueman.enable = true;

  services.printing.enable = true;

  # services.dbus.socketActivated = true;
  services.xserver.videoDrivers = [
    "amdgpu" "radeon"
    "cirrus" "vesa" "vmware" "modesetting"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest_hardened;
  # boot.resumeDevice = "/dev/disk/by-uuid/bd7707d9-7022-46de-96fb-a63a6573cbe8";

  # swapDevices = [{
  #   device = "/swapfile";
  #   size = 16032;
  # }];

  # Resume hiberntion from swap
  # boot.resumeDevice = "/dev/disk/by-uuid/30ff6e00-92e3-40bc-a982-8e15f7f7942e";
  # boot.kernelParams = [
  #   "resume_offset=6227968"
  # ];

  boot.kernel.sysctl = {
    # Don't swap, except in a crisis
    "vm.swappiness" = 1;
    "kernel.unprivileged_userns_clone" = 1;
    # For Android Studio
    "fs.inotify.max_user_watches" = 524288;
  };

  boot.kernelModules = [
    "usbnet" "cdc_ether"
  ];
  # Fix sound
  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel
  ''; # options snd_hda_intel enable=0,1

  # Disable unintelligible output device
  boot.blacklistedKernelModules = [ "snd_pcsp" ];
  # DO NOT CHANGE!
  system.stateVersion = "20.03"; # Did you read the comment?
}
