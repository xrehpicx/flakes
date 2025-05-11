{
  description = "My NixOS flake for multiple hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        black = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/black/default.nix ];
          specialArgs = { inherit system; inputs = self.inputs; };
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
          extraSpecialArgs = { inherit system; inputs = self.inputs; };
          modules = [ ./hosts/black/home.nix ];
        };
      };
    };
} 