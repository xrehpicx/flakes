{ pkgs, lib, ... }:

let sbDir = "/etc/sbctl"; in
{
  environment.systemPackages = with pkgs; [ sbctl ];

  system.activationScripts.sbctl-sign = lib.mkAfter ''
    # automatically re-sign every EFI entry in your ESP
    sbctl sign --key-dir ${sbDir} --batch /boot/EFI/nixos/*.efi
  '';
} 