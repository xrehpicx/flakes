{ config, pkgs, lib, ... }:

let
  ourModules = [
    ./hardware-configuration.nix
    ../../modules/linux-secureboot.nix
  ];
in {
  imports = ourModules;

  networking.hostName = "black";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint     = "/boot";

  users.users.raj = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "audio" ];
    # you'll still run `passwd raj` after first boot
  };

  # Enable SSH login
  services.openssh.enable = true;

  # Enable SDDM display manager
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # (optional) any host-specific overrides here…
} 