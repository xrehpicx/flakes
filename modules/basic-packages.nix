{ pkgs, ... }:

{
  # Essential system packages that should be available to all users
  environment.systemPackages = with pkgs; [
    # Core utilities
    git
    vim
    wget
    curl
    htop
    ripgrep
    fd
    tree
    unzip
    
    # System tools
    smartmontools  # For disk health monitoring
    pciutils       # For lspci
    usbutils       # For lsusb
    
    # Network tools
    dig
    whois
    iftop
    nmap
  ];
  
  # Enable some default programs system-wide
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    
    bash.completion.enable = true;
    fish.enable = true;
  };
} 