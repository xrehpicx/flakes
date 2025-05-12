{ config, pkgs, lib, inputs, zen-browser, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/linux-secureboot.nix
    ../../modules/basic-packages.nix
    ../../modules/surface-laptop.nix
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
    packages = [
      zen-browser.packages.${pkgs.system}.default
    ];
    # you'll still run `passwd raj` after first boot
  };

  # Enable SSH login with more secure defaults
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Desktop environment configuration
  services.xserver.enable = true; # X server itself

  services.displayManager.sddm = { # SDDM configuration
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };

  services.desktopManager.plasma6.enable = true; # Plasma 6 configuration

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
  };
  
  # Audio services (previously in home.nix)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Printing services (previously in home.nix)
  services.printing.enable = true;

  # Session variables (previously in home.nix)
  environment.sessionVariables = {
    EDITOR = "vim";
    TERMINAL = "kitty";
  };

  
  environment.systemPackages = with pkgs; [
    kitty
    firefox
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

  # Fix dual-boot time skew: use localtime for RTC
  time.timeZone = "UTC";  # adjust to your timezone
  hardware.clock.localTime = true;
} 