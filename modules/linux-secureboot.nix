{ pkgs, lib, ... }:

let
  sbctlBin = "${pkgs.sbctl}/bin/sbctl";
in
{
  environment.systemPackages = with pkgs; [ sbctl ];

  # Only create/enroll keys if Secure Boot is not already set up
  system.activationScripts.sbctl-enroll = lib.mkBefore ''
    if ! ${sbctlBin} status | grep -q "Installed:\	✓ sbctl is installed"; then
      ${sbctlBin} create-keys
      ${sbctlBin} enroll-keys -m
    fi
  '';

  # Automatically sign all known files in the database on each activation
  system.activationScripts.sbctl-sign = lib.mkAfter ''
    ${sbctlBin} sign-all
  '';
} 