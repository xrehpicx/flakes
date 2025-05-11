{ pkgs, lib, ... }:

let sbDir = "/etc/sbctl"; in
{
  environment.systemPackages = with pkgs; [ sbctl ];

  # generate and enroll Secure Boot keys once, before activation
  system.activationScripts.sbctl-enroll = lib.mkBefore ''
    if [ ! -f ${sbDir}/db.crt ]; then
      sbctl create-keys --directory ${sbDir}
      sbctl enroll-keys -m --directory ${sbDir} --yes
    fi
  '';

  # automatically re-sign every EFI entry in your ESP on each activation
  system.activationScripts.sbctl-sign = lib.mkAfter ''
    sbctl sign --key-dir ${sbDir} --batch /boot/EFI/nixos/*.efi
  '';
} 