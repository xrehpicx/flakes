{ config, lib, pkgs, inputs, ... }:

{
  # Import only the common Surface modules
  imports = [
    inputs.nixos-hardware.nixosModules."microsoft-surface-common"
  ];

  # Override common module settings under hardware.microsoft-surface
  hardware.microsoft-surface.kernelVersion = "stable";  # override from default 6.0.17
  hardware.microsoft-surface.surface-control.enable = true;

  # Surface-specific and post-installation packages
  environment.systemPackages = with pkgs; [
    libwacom          # For tablet input devices
    powertop          # For power consumption analysis
    acpi              # For battery status
    brightnessctl     # For display brightness control
    iio-sensor-proxy  # For automatic screen rotation
    linux-firmware    # Required firmware for various devices
    intel-microcode   # CPU microcode updates for Intel processors
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

  # For better display support
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # Enable better touchpad support
  services.xserver.libinput = {
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

  # Use NixOS kernel microcode module for Intel
  hardware.cpu.intel.updateMicrocode = true;

  # Remove incorrect microsoft-surface.ipts option; enable IPTSd correctly
  # Ensure IPTSd daemon is installed and its service is enabled
  systemd.packages = with pkgs; [ iptsd ];
  services.udev.packages = with pkgs; [ iptsd ];
  systemd.services.iptsd.enable = true;

  # Fallback configuration in case the nixos-hardware overlay doesn't work
  # This custom kernel configuration is commented out by default, but can be
  # uncommented if needed
  /*
  boot.kernelPackages = let
    linux_surface = { fetchurl, buildLinux, ... } @ args:
      buildLinux (args // rec {
        version = "6.1.61";
        modDirVersion = version;

        src = fetchurl {
          url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
          sha256 = "3ca2b4dd931c53165d5d87eb3a7d67e6dd69aaae6b5596c23bb688fe45a9d9aa";
        };

        kernelPatches = [
          { 
            name = "surface-patches";
            patch = fetchurl {
              url = "https://github.com/linux-surface/linux-surface/releases/download/6.1.61-1/patch-6.1.61-surface.patch";
              sha256 = "0000000000000000000000000000000000000000000000000000000000000000"; # Replace with actual hash
            };
          }
        ];

        extraConfig = ''
          # Surface specific configs
          SURFACE_ACPI m
          SURFACE_ACPI_NOTIFY y
          SURFACE_ACPI_SSH m
          SURFACE_ACPI_VHF m
          SURFACE_ACPI_DTX m
          SURFACE_ACPI_SAN m
          SURFACE_BUTTON m
          SURFACE_HID m
          BATTERY_SURFACE m
          CHARGER_SURFACE m
          SURFACE_HOTPLUG m
          SURFACE_PLATFORM m
          SURFACE_AGGREGATOR m
          SURFACE_AGGREGATOR_BUS m
          SURFACE_AGGREGATOR_CDEV m
          SURFACE_AGGREGATOR_HUB m
          SURFACE_AGGREGATOR_REGISTRY m
          SURFACE_AGGREGATOR_TABLET m
          SURFACE_DTX m
          SURFACE_GPE m
          SURFACE_KBD m
          SURFACE_PMC m
          SURFACE_SAM m
          SURFACE_SAM_SAN m
          SURFACE_SAM_SSH m
          SURFACE_SAM_SSH_DEBUG_DEVICE m
          SURFACE_SAM_VHF m
          SURFACE_BOOK3_DGPU_SWITCH m
        '';

        extraMeta.branch = "6.1";
      } // (args.argsOverride or {}));
    
    custom_kernel = pkgs.callPackage linux_surface {};
  in
    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor custom_kernel);
  */
} 