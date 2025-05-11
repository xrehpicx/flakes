# NixOS Flake Configuration

This repository contains my NixOS system configurations managed through flakes.

## Repository Structure

```
.
├── flake.nix               # Main flake entry point
├── hosts/                  # Host-specific configurations
│   └── black/              # Configuration for host 'black'
│       ├── default.nix     # System configuration
│       ├── home.nix        # Home Manager configuration
│       └── hardware-configuration.nix
└── modules/                # Shared configuration modules
    ├── basic-packages.nix  # Common packages
    └── linux-secureboot.nix # Secure Boot configuration
```

## Features

- Multi-host NixOS configuration using flakes
- Home Manager integration for user configuration
- Modular architecture with shared modules
- Secure Boot support with automatic key management
- KDE Plasma 6 and Hyprland desktop environments

## Usage

### Initial Setup

1. Clone this repository
2. Customize the host configurations in `hosts/`
3. Ensure your hardware configuration is correct

### Building and Activating

```bash
# Build and switch to the configuration
sudo nixos-rebuild switch --flake .#black

# Build and switch to the home configuration
home-manager switch --flake .#raj@black
```

### Adding a New Host

1. Create a new directory under `hosts/`
2. Add the proper hardware-configuration.nix (use `nixos-generate-config`)
3. Create a default.nix and home.nix for the new host
4. Add the host to the flake.nix outputs

## Requirements

- NixOS 24.11 or newer
- Nix with flakes enabled

## License

MIT
