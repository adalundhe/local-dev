	{
	  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs";
      flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlay = (self: super: {
            python = super.python3;
            poetry = super.poetry;
            pip = super.python3Packages.pip;
            cookiecutter = super.python3Packages.cookiecutter;
          });
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        with pkgs;
        {
          devShells.default = mkShell {
            buildInputs = [
              python3
              poetry
              pyenv
              python3Packages.pip
              python3Packages.cookiecutter
            ];
          };
        }
      );
}