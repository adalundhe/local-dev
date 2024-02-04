	{
	  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs";
      flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        with pkgs;
        {
          devShells.default = mkShell {
            buildInputs = [
              just
              xcode-install
              direnv
              ripgrep
              python3
              nodejs_20
              docker
              docker-compose
              nodejs_20.pkgs.pnpm
            ];
            shellHook = ''
            if [[ ! -e local-dev ]]; then
              git clone git@github.com:scorbettUM/local-dev.git
              echo 'eval "$(direnv hook zsh)"' | sudo tee -a $HOME/.zshrc > /dev/null

              touch $HOME/.envrc
              echo 'use flake "github.com:scorbettUM/local-dev"' | sudo tee $HOME/.envrc > /dev/null
              cp local-dev/justfile $HOME/justfile
              rm -rf local-dev
            fi

            sudo npm install -g @devcontainers/cli
            '';
          };
        }
      );
}