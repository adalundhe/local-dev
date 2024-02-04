	{
	  inputs = {
      # Moderately annoying that we have to do this as Python 3.12 is broken on main
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
        
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
              allowBroken = true;
            };
          };
        in
        with pkgs;
        {
          devShells.default = mkShell {
            buildInputs = [
              python312
              poetry
              python312Packages.pip
            ];
          };
        }
      );
}