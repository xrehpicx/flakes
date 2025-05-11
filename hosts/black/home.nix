{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "raj";
    homeDirectory = "/home/raj";
    
    # Packages installed in user profile
    packages = with pkgs; [
      vim
      neovim
      kitty
      wget
      git
      firefox
      
      # Add more user packages here
    ];
    
    # This value should rarely change
    stateVersion = "24.11";
    
    # Session variables set for the user environment
    sessionVariables = {
      EDITOR = "vim";
      TERMINAL = "kitty";
    };
  };
  
  # Enable proper management of dotfiles by home-manager
  xdg.enable = true;
  
  # Enable KDE Plasma configuration
  programs.plasma = {
    enable = true;
    # Add more Plasma-specific user settings here if needed
  };

  # Enable Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland; # Using hyprland from nixpkgs for stability
    package = pkgs.hyprland;
    systemd.enable = true;
    xwayland.enable = true;
  };

  # Terminal configuration
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Raj";
    userEmail = "raj@example.com"; # Replace with your email
  };

  # Enable direnv with nix-direnv for per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Audio services
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Printing services
  services.printing.enable = true;
  
  # Let Home Manager manage itself
  programs.home-manager.enable = true;
} 