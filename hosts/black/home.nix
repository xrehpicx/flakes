{ config, pkgs, inputs, system, ... }:

{
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

  home.packages = with pkgs; [
    vim
    neovim
    kitty
    wget
    git
  ];

  home.stateVersion = "24.11";
} 