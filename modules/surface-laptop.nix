{ config, lib, pkgs, inputs, nixos-unstable, ... }:

{
  # Import the common Surface module
  imports = [
    inputs.nixos-hardware.nixosModules."microsoft-surface-common"
  ];

  # Use the prebuilt Surface kernel from nixos-unstable binary cache
  boot.kernelPackages = nixos-unstable.legacyPackages.${pkgs.system}.linuxPackages_surface;

  # Add useful Surface utilities
  environment.systemPackages = with pkgs; [
    libwacom          # For tablet input devices
    powertop          # For power consumption analysis
    acpi              # For battery status
    brightnessctl     # For display brightness control
    iio-sensor-proxy  # For automatic screen rotation
    linux-firmware    # Required firmware for various devices
    # Add Surface-specific utilities from nixos-unstable
    nixos-unstable.legacyPackages.${pkgs.system}.surfacectl
    nixos-unstable.legacyPackages.${pkgs.system}.iptsd
  ];

  # Enable better power management
  services.thermald.enable = true;
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  # Improve battery life with TLP
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      
      # Disable USB autosuspend for the Surface Dock
      USB_AUTOSUSPEND = 0;
    };
  };

  # Enable better touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      tappingDragLock = false;
      accelSpeed = "0.3";
      disableWhileTyping = true;
    };
  };

  # Enable camera support
  hardware.enableRedistributableFirmware = true;
  boot.kernelModules = [ "uvcvideo" ];

  # Enable firmware updates through fwupd
  services.fwupd.enable = true;

  # Enable IPTSd daemon for Surface touchscreen/pen support
  systemd.packages = with pkgs; [ iptsd ];
  services.udev.packages = with pkgs; [ iptsd ];
  systemd.services.iptsd.enable = true;

  # Explicitly disable power-profiles-daemon to avoid conflict with TLP
  services.power-profiles-daemon.enable = false;
  
  # Enable Intel microcode updates
  hardware.cpu.intel.updateMicrocode = true;
} 