{
  description = "My NixOS flake for multiple hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
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
          specialArgs = { inherit inputs; };  # Pass all inputs, more flexible
          modules = [ ./hosts/black/default.nix ];
        };
        # Add more hosts like this:
        # foo = lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = { inherit inputs; };
        #   modules = [ ./hosts/foo/default.nix ];
        # };
      };
      
      homeConfigurations = {
        "raj@black" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsForSystem "x86_64-linux" [];
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/black/home.nix ];
        };
      };
    };
} 