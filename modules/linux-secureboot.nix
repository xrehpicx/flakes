{ pkgs, lib, ... }:

let
  sbctlBin = "${pkgs.sbctl}/bin/sbctl";
  sbDir = "/etc/sbctl";
in
{
  environment.systemPackages = with pkgs; [ sbctl ];

  # generate and enroll Secure Boot keys once, before activation
  system.activationScripts.sbctl-enroll = lib.mkBefore ''
    if [ ! -f ${sbDir}/db.crt ]; then
      ${sbctlBin} create-keys --directory ${sbDir}
      ${sbctlBin} enroll-keys -m --directory ${sbDir} --yes
    fi
  '';

  # automatically re-sign every EFI entry in your ESP on each activation
  system.activationScripts.sbctl-sign = lib.mkAfter ''
    ${sbctlBin} sign --key-dir ${sbDir} --batch /boot/EFI/nixos/*.efi
  '';
} 