{
  description = "Minimal Sqlite flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "sqlite-shell";
          packages = [ pkgs.sqlite ];
        };
        packages = {
          default = pkgs.sqlite;
          sqlite = pkgs.sqlite;
          container = pkgs.dockerTools.buildLayeredImage {
            name = "sqlite";
            tag = "3.50.2";
            created = "now";
            config = {
              Entrypoint = [ "${pkgs.sqlite}/bin/sqlite3" ];
              Cmd = [ ];
            };
          };
        };
      }
    );
}