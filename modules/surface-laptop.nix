{ config, lib, pkgs, inputs, ... }:

let
  # Get nixos-unstable from inputs
  nixos-unstable = inputs.nixos-unstable;
  
  # Import the unstable channel properly
  unstablePkgs = import nixos-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  
  # Determine if the Surface kernel is available
  hasSurfaceKernel = builtins.hasAttr "linuxPackages_surface" unstablePkgs;
in
{
  # Import the common Surface module with the correct path
  imports = [
    # The path should match the repository structure: microsoft/surface/common
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
  ];

  # Override the boot.kernelPackages from the Surface module using mkForce
  # Use the prebuilt Surface kernel from nixos-unstable if available, otherwise use regular kernel
  boot.kernelPackages = lib.mkForce (
    if hasSurfaceKernel 
    then unstablePkgs.linuxPackages_surface 
    else pkgs.linuxPackages_latest
  );

  # Add useful Surface utilities
  environment.systemPackages = with pkgs; [
    libwacom          # For tablet input devices
    powertop          # For power consumption analysis
    acpi              # For battery status
    brightnessctl     # For display brightness control
    iio-sensor-proxy  # For automatic screen rotation
    linux-firmware    # Required firmware for various devices
    libcamera         # For camera support in browsers
  ] ++ (if builtins.hasAttr "surfacectl" unstablePkgs then [ unstablePkgs.surfacectl ] else [])
    ++ (if builtins.hasAttr "iptsd" unstablePkgs then [ unstablePkgs.iptsd ] else [ iptsd ]);

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

  # Add udev rule for surface-control (to avoid needing the surface-control group)
  services.udev.extraRules = ''
    # Surface control devices
    SUBSYSTEM=="surface", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_WANTS}="surface-control.service"
    KERNEL=="surface_aggregator", GROUP="input", MODE="0660"
  '';
} 