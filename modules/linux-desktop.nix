{ pkgs, ... }:

{
  # Minimal X needed for SDDM
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable        = true;
    wayland.enable = true;          # only show Wayland sessions
  };

  # KDE Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Also install and enable Hyprland as a second session
  programs.hyprland.enable = true;

  # Audio & printing
  services.pipewire = {
    enable      = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.printing.enable = true;
} 