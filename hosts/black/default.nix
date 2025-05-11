{ config, pkgs, lib, ... }:

let
  ourModules = [
    ./hardware-configuration.nix
    ../../modules/shared-packages.nix
    ../../modules/linux-desktop.nix
    ../../modules/linux-secureboot.nix
  ];
in {
  imports = ourModules;

  networking.hostName = "black";

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint     = "/boot";

  users.users.raj = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "audio" ];
    # you'll still run `passwd raj` after first boot
  };

  # (optional) any host-specific overrides here…
} 