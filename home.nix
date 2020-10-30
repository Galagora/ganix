{home-manager, pkgs, ...}:
let
  sources = import ./nix/sources.nix;
in {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ao = {lib, ...}: {
    # home.packages = with pkgs.unstable; [
    #  firefox/*-wayland shadowfox tridactyl-native*/
    # ];
    # services.emacs.enable = true;
    services.lorri.enable = true;

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

      "spacemacs".source = sources.spacemacs;
      "spacemacs".recursive = true;
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
      ".xkb/symbols/mylayout".source = ./dotfiles/mylayout.xkb.sh;
      ".emacs-profiles.el".source = ./dotfiles/eprofiles.el;
    };
    programs.home-manager.enable = true;

    home.stateVersion = "20.03"; # Do not edit
  };

}
