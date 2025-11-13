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
          version = "0.17.6";

          src = pkgs.fetchurl {
            url = "https://github.com/golemfactory/yagna/releases/download/v0.17.6/golem-provider-linux-v0.17.6.tar.gz";
            sha256 = "0s3xf5qmkacrjyabbcs2k8k3ljsm54r4mqlsp01sfz7v88xy5vrs"; # replace later
          };

          installPhase = ''
            mkdir -p $out/bin
            cp yagna $out/bin/
          '';
        };
      }) // {
        nixosConfigurations = {
          golem-01 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/common.nix
              ./hosts/golem-01.nix
            ];
          };
        };
      };
}

