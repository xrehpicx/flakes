{
  description = "My NixOS flake for multiple hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        black = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/black/default.nix ];
          specialArgs = { inherit system; inputs = { inherit hyprland; }; };
        };
        # Add more hosts like this:
        # foo = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [ ./hosts/foo/default.nix ];
        # };
      };
      homeConfigurations = {
        "raj@black" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit system; inputs = { inherit hyprland; }; };
          modules = [ ./hosts/black/home.nix ];
        };
      };
    };
} 