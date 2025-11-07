{
  description = "Golem provider fleet on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.yagna = pkgs.stdenv.mkDerivation {
          pname = "yagna";
          version = "0.14.0";

          src = pkgs.fetchurl {
            url = "https://github.com/golemfactory/yagna/releases/download/v0.14.0/yagna-linux-amd64.tar.gz";
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # replace later
          };

          installPhase = ''
            mkdir -p $out/bin
            cp yagna $out/bin/
          '';
        };
      }) // {
        nixosConfigurations = {
          laptop1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/common.nix
              ./hosts/laptop1.nix
            ];
          };

          laptop2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/common.nix
              ./hosts/laptop2.nix
            ];
          };
        };
      };
}

