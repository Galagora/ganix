# Update them with `niv update` before running `sudo nixos-rebuild switch`

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
    ./openvpn.nix
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
      # enlightenment = prev.enlightenment.overrideScope' (
      #   finalE: prevE: {
      #     efl = prevE.efl.overrideAttrs (oldAttrs: {
      #       mesonFlags = oldAttrs.mesonFlags ++ "-D wl=true";
      #     });
      #   }
      # );
      hls-ghc8102 = import final.sources.nix-hls {
        ghcVersion = "ghc8102";
        unstable = true;
        # nixpkgs-pin = ;
      };
      haskell-language-server = prev.haskell-language-server.override {
        supportedGhcVersions = [ "8102" ];
      };
      # haskell-language-server.override { supportedGhcVersions = [ "8102" ]; }
      # stack-master = import ./stack.nix;
      # stack-master = with prev.haskell.lib; justStaticExecutables (overrideSrc
      #   prev.haskellPackages.stack {
      #     src = sources.stack-g;
      #     version = "2.4.0";
      #   }
      # );
      # stack = with prev.haskell.lib; justStaticExecutables (appendPatch
      #   prev.haskellPackages.stack (pkgs.fetchpatch {
      #     url = "https://github.com/commercialhaskell/stack/commit/f8b7bfcf1f8553aeccd5a52720f60a65b8d66361.patch";
      #     sha256 = "18lpr3x7iiz54b44n2xwix6hhrkbz57qm4nl4n3qvjb5wy83gysl";
      #   }));
      # ghcide = haskell.pac
      ghcide-ghc8102 = (import (sources.ghcide-nix) {}).ghcide-ghc8102;
    })
    # (final: prev: {
    #   hls-ghc8102.hls-wrapper = prev.hls-ghc8102.hls-wrapper.overrideAttrs(old: {
    #     patches = [(final.fetchpatch {
    #       url = "https://github.com/haskell/ghcide/commit/0bfce3114c28bd00f7bf5729c32ec0f23a8d8854.patch";
    #       sha256 = "1ph4apd2fyjxkzkfzlp5kkd4hzda2yw8lznhgvixqymbzdmhvsbb";
    #     })];
    #   });
    # })
    (import sources.emacs-overlay)
    # (import sources.nixpkgs-wayland)
  ];

  environment.binbash.enable = true;
  # nix = {
  #  package = pkgs.nixUnstable;
  #  extraOptions = ''
  #    experimental-features = nix-command # flakes
  #    keep-outputs = true
  #    keep-derivations = true
  #    min-free = ${toString (10 * 1024 * 1024 * 1024)}
  #    max-free = ${toString (20 * 1024 * 1024 * 1024)}
  #  '';
  # };
  # nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    min-free = ${toString (10 * 1024 * 1024 * 1024)}
    max-free = ${toString (20 * 1024 * 1024 * 1024)}
  '';
  nix.binaryCaches = [ "https://aseipp-nix-cache.global.ssl.fastly.net" "https://hydra.iohk.io "];
  nix.binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  # nix
  # nix.trustedUsers = ["@wheel"];
  # # VirtualBox
  # nixpkgs.config.allowUnfree = true;

  # services.flatpak.enable = true;
  # xdg.portal.enable       = true;
  # xdg.portal.gtkUsePortal = true;
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

  # programs.adb.enable = true;
  # environment.pathsToLink = [
  #   "/jars"
  # ];
  # services.emacs = {
  #  enable = true;
  #  defaultEditor = true;
  #  package = with pkgs; ((emacsPackagesNgGen emacsGcc).emacsWithPackages (epkgs: [
  #    epkgs.vterm
  #  ]));
  # };

  programs.zsh.syntaxHighlighting.enable = true;
  # Use zsh in nix-shell
  # programs.zsh.promptInit = ''
  #   any-nix-shell zsh --info-right | source /dev/stdin
  # '';

  # services.xserver.displayManager = {
  #   gdm = {
  #     enable = true;
  #   };
  #   defaultSession = "sway";
  # };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; with xorg; with sway-contrib; [
      swaylock swayidle mako wofi waybar dmenu bemenu
      grimshot
      wmfocus /*focus windows by label*/
      xwayland xeyes wev /*record wayland kb events*/
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
      export CALIBRE_USE_DARK_PALETTE=1
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

  fonts.enableDefaultFonts = true;
  fonts.fontconfig.defaultFonts.sansSerif = ["Ubuntu"];
  fonts.fonts = with pkgs; [
    source-code-pro source-sans-pro source-serif-pro
    ubuntu_font_family font-awesome
  ];

  networking.networkmanager.enable = true;
  systemd.services.ModemManager ={
    enable = true;
    wantedBy = ["multi-user.target"];
  };
  hardware.usbWwan.enable = true;
  services.udev.packages = with pkgs; [
    usb-modeswitch-data
  ];
  # services.connman.enable = true;
  services.openvpnl.servers = {
    USA = {
      config = "config /home/ao/downloads/us-bdn.prod.surfshark.comsurfshark_openvpn_udp.ovpn";
      autoStart = false;
      updateResolvConf = true;
      authUserPass = with builtins; with (fromJSON (readFile ./secrets.json)).surfshark-USA; {
        inherit username password;
      };
    };
  };

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

  qt5 = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
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
      General = { ControllerMode = "bredr"; };
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
