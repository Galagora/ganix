{ config, lib, pkgs, ... }:
with pkgs; appimageTools.wrapType2 { # or wrapType1
  name = "patchwork";


  src = fetchurl {
    url = "https://github.com/appium/appium-desktop/releases/download/v1.18.0/Appium-linux-1.18.0.AppImage";
    sha256 =  "1blsprpkvm0ws9b96gb36f0rbf8f5jgmw4x6dsb1kswr4ysf591s";
  };
  extraPkgs = pkgs: with pkgs; [ ];


}
