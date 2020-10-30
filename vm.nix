{ config ? {},
  pkgs,
  ...
}:
let
  # sources = import ./nix/sources.nix;
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <nixpkgs/nixos/modules/profiles/graphical.nix>
  ];

  # # nix.nixPath = ["nixos-config=/etc/nixos/configuration.nix"];
  # nixpkgs.pkgs = import sources.nixpkgs {
  #   config.allowUnfree = true;
  #   config.pulseaudio = true;
  #   # android_sdk.accept_license = true;
  # };
  # nixpkgs.overlays = [
  #   (self: super: {
  #     inherit sources;
  #     ganixpkgs = import self.sources.ganixpkgs {
  #       config.allowUnfree = true;
  #       config.pulseaudio = true;
  #       # android_sdk.accept_license = true;
  #     };
  #     # openjdk14-bin = pkgs.callPackage ./openjdk14-bin.nix {};
  #   })
  # ];

  # services.xserver = {
  #   enable = true;
  #   displayManager.gdm.enable = true;
  #   displayManager.autoLogin = {
  #     enable = true;
  #     user = "user1";
  #   };
  #   desktopManager.gnome3.enable = true;
  # };
  # # environment.systemPackages = with pkgs; [
  # #   # gitAndTools.gitFull
  # #   # ganixpkgs.androidStudioPackages.beta
  # #   # zsh
  # # ];

  # # Don't manage users except through Nix
  # users.mutableUsers = false;
  # users.users.user1 = {
  #   shell = pkgs.zsh;
  #   extraGroups = [
  #     "wheel" "networkmanager"
  #   ];
  #   createHome = true;
  #   isNormalUser = true;
  #   home = "/home/user1";
  #   hashedPassword = "";
  # };

  # users.users.root.hashedPassword = "";

  # # Deprecated
  # networking.useDHCP = false;
  # networking.interfaces.enp37s0.useDHCP = true;

  # time.timeZone = "Asia/Istanbul";

  # sound = {
  #   enable = true;
  #   # Legacy sound system emulation
  #   enableOSSEmulation = false;
  # };
  # hardware.pulseaudio.enable = true;

  # services.xserver.videoDrivers = [
  #   "amdgpu" "radeon"
  #   "cirrus" "vesa" "vmware" "modesetting"
  # ];

  # boot.kernelPackages = pkgs.linuxPackages_latest_hardened;

  # # Fix sound
  # boot.extraModprobeConfig = ''
  #   options snd slots=snd-hda-intel
  # ''; # options snd_hda_intel enable=0,1

  # # Disable unintelligible output device
  # boot.blacklistedKernelModules = [ "snd_pcsp" ];
  # DO NOT CHANGE!
  system.stateVersion = "20.03"; # Did you read the comment?
}
