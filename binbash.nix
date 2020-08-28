{config, lib, pkgs, ...}:
with lib;
{
  options = {
    environment.binbash = {
      enable = mkEnableOption "/bin/bash symlink";
      package = mkOption {
        default = "${pkgs.bash}/bin/bash";
        example = literalExample ''
          "''${pkgs.bash_5}/bin/bash"
        '';
        type = types.nullOr types.path;
        # visible = false;
        description = ''
          The bash(1) executable that is linked system-wide to
          <literal>/bin/bash</literal>.
        '';
      };
    };
  };
  config = {
    system.activationScripts.binbash =
      if config.environment.binbash.enable == true
      then ''
        mkdir -m 0755 -p /bin
        ln -sfn "${config.environment.binbash.package}" /bin/.bash.tmp
        mv /bin/.bash.tmp /bin/bash # atomically replace /bin/bash
      ''
      else ''
        rm -f /bin/bash
        rmdir --ignore-fail-on-non-empty /bin
      '';
  };
}
