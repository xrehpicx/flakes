{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/linux-secureboot.nix
    ../../modules/basic-packages.nix
  ];

  networking = {
    hostName = "black";
    networkmanager.enable = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  users.users.raj = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    # you'll still run `passwd raj` after first boot
  };

  # Enable SSH login with more secure defaults
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Desktop environment configuration
  services.xserver = {
    enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "breeze";
    };
    desktopManager.plasma6.enable = true;
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Essential packages
  environment.systemPackages = with pkgs; [ 
    home-manager 
  ];

  # Enable flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # State version should rarely change
  system.stateVersion = "24.11";
} 