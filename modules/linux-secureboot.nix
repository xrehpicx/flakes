{ pkgs, lib, ... }:

{
  # Include sbctl package for UEFI Secure Boot management
  environment.systemPackages = with pkgs; [ sbctl ];

  # Create a wrapper for sbctl to avoid repeating the path
  # and to add common options if needed
  boot.initrd.systemd.enable = true; # Required for proper Secure Boot support

  # Only create/enroll keys if Secure Boot is not already set up
  # This script runs before the normal activation scripts
  system.activationScripts.sbctl-enroll = lib.mkBefore ''
    # Check if sbctl is available in $PATH
    if ! command -v ${pkgs.sbctl}/bin/sbctl &> /dev/null; then
      echo "Warning: sbctl not found in path. Secure Boot enrollment skipped."
      exit 0
    fi

    # Check if keys are already created and sbctl is properly installed
    # Looking for "Installed:" followed by "sbctl is installed" with any characters in between
    if ! ${pkgs.sbctl}/bin/sbctl status | grep -q "Installed:.*sbctl is installed"; then
      echo "Secure Boot keys not detected as installed by sbctl. Attempting to create and enroll keys..."
      ${pkgs.sbctl}/bin/sbctl create-keys || echo "Warning: Failed to create Secure Boot keys (they might already exist or another issue occurred)."
      ${pkgs.sbctl}/bin/sbctl enroll-keys -m || echo "Warning: Failed to enroll Secure Boot keys (system might not be in Setup Mode or keys already enrolled)."
    else
      echo "Secure Boot keys appear to be correctly installed and managed by sbctl."
    fi
  '';

  # Automatically sign all known files in the database on each activation
  # This script runs after the normal activation scripts
  system.activationScripts.sbctl-sign = lib.mkAfter ''
    # Check if sbctl is available in $PATH
    if command -v ${pkgs.sbctl}/bin/sbctl &> /dev/null; then
      echo "Signing EFI binaries with Secure Boot keys..."
      ${pkgs.sbctl}/bin/sbctl sign-all || echo "Warning: Failed to sign some EFI binaries"
    else
      echo "Warning: sbctl not found in path. EFI binaries not signed."
    fi
  '';
} 