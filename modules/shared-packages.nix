{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    neovim
    kitty
    wget
    git
  ];
} 