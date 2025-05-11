{ config, pkgs, inputs, system, ... }:

{

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Enable KDE Plasma 6 session (user-level)
  programs.plasma = {
    enable = true;
    # Add more Plasma-specific user settings here if needed
  };

  # Enable Hyprland as a session (user-level)
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
  };

  # Audio (PipeWire, ALSA, PulseAudio)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Printing (CUPS client)
  services.printing.enable = true;

  # Optionally, add user packages or other Home Manager settings here
  home.packages = with pkgs; [
    vim
    neovim
    kitty
    wget
    git
  ];
} 