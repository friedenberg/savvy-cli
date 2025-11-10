{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/dcfec31546cb7676a5f18e80008e5c56af471925";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/e9b7f2ff62b35f711568b1f0866243c7c302028d";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";

    devenv-go = {
      url = "github:friedenberg/eng?dir=pkgs/alfa/devenv-go";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv-nix = {
      url = "github:friedenberg/eng?dir=pkgs/alfa/devenv-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      utils,
      devenv-go,
      devenv-nix,
    }:
    (utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            devenv-go.overlays.default
          ];
        };

        savvy = pkgs.buildGoApplication {
          pname = "savvy";
          version = "0.0.1";
          src = ./.;
          modules = ./gomod2nix.toml;
        };
      in
      {

        packages.chrest = savvy;
        packages.default = savvy;

        devShells.default = pkgs.mkShell {
          packages = (
            with pkgs;
            [
              bats
              fish
              gnumake
              just
            ]
          );

          inputsFrom = [
            devenv-go.devShells.${system}.default
            devenv-nix.devShells.${system}.default
          ];
        };
      }
    ));
}
