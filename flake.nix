{
  description = "My NixOS flake for multiple hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        black = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/black/default.nix ];
        };
        # Add more hosts like this:
        # foo = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = [ ./hosts/foo/default.nix ];
        # };
      };
    };
} 