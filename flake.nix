{
  description = "My NixOS flake for multiple hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    
    # Add nixos-unstable for Surface kernel packages
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };


  outputs = { self, nixpkgs, nixos-unstable, hyprland, zen-browser, nixos-hardware, ... }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = lib.genAttrs systems;
      
      # Function to create system-specific pkgs with optional overlays
      pkgsForSystem = system: overlays: import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        black = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { 
            inherit inputs; 
            zen-browser = inputs.zen-browser;
            nixos-unstable = nixos-unstable;
          };
          modules = [ 
            ./hosts/black/default.nix
            nixos-hardware.nixosModules.microsoft-surface-common
          ];
        };
        # Add more hosts like this:
        # foo = lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = { inherit inputs; };
        #   modules = [ ./hosts/foo/default.nix ];
        # };
      };
    };
} 