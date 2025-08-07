{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          inputsFrom = [
            (import ./shell.nix { inherit pkgs; })
          ];
        };
        
        # simply package the contents of the root directory
        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "quickshell";
            src = ./.;
          };
        };
      }
    );
}
