# NixOS Flake Configuration

This repository contains my NixOS system configurations managed through flakes.

## Repository Structure

```
.
├── flake.nix               # Main flake entry point
├── hosts/                  # Host-specific configurations
│   └── black/              # Configuration for host 'black'
│       ├── default.nix     # System configuration
│       └── hardware-configuration.nix
└── modules/                # Shared configuration modules
    ├── basic-packages.nix  # Common packages
    └── linux-secureboot.nix # Secure Boot configuration
```

## Features

- Multi-host NixOS configuration using flakes
- Modular architecture with shared modules
- Secure Boot support with automatic key management
- KDE Plasma 6 and Hyprland desktop environments

## Surface Laptop Setup

This flake includes specific configuration for Microsoft Surface devices, using the common Surface modules from nixos-hardware with the following features:

- Surface-patched kernel from nixos-unstable binary cache (when available)
- Fallback to latest mainline kernel if Surface kernel is not available
- Surface utilities like `surfacectl` (if available) and `iptsd` for touchscreen/pen support
- Power management optimizations with TLP
- Camera support with libcamera

### Camera Usage in Firefox

To use the camera with proper support in Firefox, you can run:

```bash
libcamerify firefox
```

### Using Surface Utilities

If available, the `surfacectl` utility is installed for command-line management of Surface device features. The `raj` user has been added to the `input` group for access to required devices.

You can use surfacectl (if installed) to manage various Surface features:

```bash
# Show device information
surfacectl status

# Control performance profiles
surfacectl performance

# Manage battery limits
surfacectl battery
```

## Usage

### Building and Activating

```bash
# Build and switch to the configuration
sudo nixos-rebuild switch --flake .#black
```

### Adding a New Host

1. Create a new directory under `hosts/`
2. Add the proper `hardware-configuration.nix` (use `nixos-generate-config`)
3. Create `default.nix` for the new host
4. Add the host to the `nixosConfigurations` section in `flake.nix`

## Requirements

- NixOS 24.11 or newer
- Nix with flakes enabled

## License

MIT
