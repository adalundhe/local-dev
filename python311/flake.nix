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
            python = super.python311;
            poetry = super.poetry;
            pip = super.python311Packages.pip;
          });
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        with pkgs;
        {
          devShells.default = mkShell {
            buildInputs = [
              python311
              poetry
              pyenv
              python311Packages.pip
              python311Packages.cookiecutter
            ];
            shellHook = ''
              IS_GIT_DIR=$(git rev-parse --is-inside-work-tree)

              if [[ "$IS_GIT_DIR" != "true"  ]]; then
                  git init
              fi

              if [[ ! -e .gitignore ]]; then
                  touch .gitignore && \
                  echo ".direnv" | tee -a .gitignore > /dev/null
              fi

              if [[ ! -e .envrc ]]; then
                  touch .envrc && \
                  echo 'use flake "github:scorbettUM/local-dev?dir=python"' | tee -a .envrc > /dev/null
              fi

              if [[ ! -e pyproject.toml ]]; then
                  touch ruff.toml
                  poetry init --name myapp -q && \
                  poetry add -G dev ruff
                  poetry install --no-root -q
              fi
            '';
          };
        }
      );
}