{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs
            {
              inherit system;
              overlays = builtins.attrValues self.overlays;
              config = {
                allowUnfree = true;
                allowUnsupportedSystem = true;
                allowBroken = true;
              };
            };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              (python3.withPackages (ps: with ps; [ pip cookiecutter ]))
              awscli2
              bashInteractive
              blueprint
              aws-login
              devcontainers
              direnv
              docker
              docker-compose
              gum
              just
              nixpkgs-fmt
              nodejs_20
              nodejs_20.pkgs.pnpm
              ripgrep
              xcode-install
              python3Packages.pip
              python3Packages.cookiecutter
              nodePackages.typescript
              nodePackages.ts-node
              gitAndTools.gh
              kubernetes
              kubernetes-helm
              kubectx
              minikube
              rustc
              cargo
              go_1_21
              k9s
              terraform
              dcon
              wget
              pyenv
            ];
            shellHook =
              let
                sourceEnv = f: ''
                  if [[ -f ${f} ]]; then
                    echo 1>&2 'sourcing env variables from ${f}'
                    set -a
                    . ${f}
                    set +a
                  fi
                '';
              in

              ''
                gum style --border double \
                  --align center \
                  --width 50 \
                  --margin "1 2" \
                  --padding "2 4" \
                  'Welcome to local dev!' \
                  'I hope you enjoy your stay! If you need help, just holler'
                ${sourceEnv ".env"}
                ${sourceEnv ".env.local"}

                wget -q -O justfile "https://raw.githubusercontent.com/scorbettUM/local-dev/main/justfile" -P $HOME
                [[ -f justfile  ]] && command -v just >/dev/null 2>&1 && just --list --unsorted
                

                grep -qxF 'source "$HOME/.devenv/bin/activate"' $HOME/.zshrc \
                || echo 'source "$HOME/.devenv/bin/activate"' \
                | tee -a ~/.zshrc > /dev/null

                grep -qxF 'if [[ "$PWD" == "$HOME" ]]; then
    nix develop "github:scorbettum/local-dev"
fi' $HOME/.zshrc \
                || echo 'if [[ "$PWD" == "$HOME" ]]; then
    nix develop "github:scorbettum/local-dev"
fi' \
                | tee -a ~/.zshrc > /dev/null

                grep -qxF 'eval "$(direnv hook zsh)"' $HOME/.zshrc \
                || echo 'eval "$(direnv hook zsh)"' \
                | tee -a ~/.zshrc > /dev/null


                grep -qxF 'source "$HOME/.devenv/bin/activate"' $HOME/.bashrc \
                || echo 'source "$HOME/.devenv/bin/activate"' \
                | tee -a ~/.bashrc > /dev/null

                grep -qxF 'if [[ "$PWD" == "$HOME" ]]; then
    nix develop "github:scorbettum/local-dev"
fi' $HOME/.bashrc \
                || echo 'if [[ "$PWD" == "$HOME" ]]; then
    nix develop "github:scorbettum/local-dev"
fi' \
                | tee -a ~/.bashrc > /dev/null

                grep -qxF 'eval "$(direnv hook zsh)"' $HOME/.bashrc \
                || echo 'eval "$(direnv hook zsh)"' \
                | tee -a ~/.bashrc > /dev/null
                
              '';
          };
        }) // {
      overlays.default = final: prev: {
        devcontainers = prev.mkYarnPackage {
          name = "devcontainer";
          src = prev.fetchFromGitHub {
            owner = "devcontainers";
            repo = "cli";
            rev = "v0.56.1";
            hash = "sha256-Q9AYPUJPcPQzSYCQyU0PTz4Cgn16E541IMxT5ofrmHE=";
          };
          buildPhase = ''
            export HOME=$(mktemp -d)
            yarn --offline compile
          '';
          dontStrip = true;
        };
        blueprint = prev.writers.writePython3Bin "blueprint"
          {
            libraries = with prev.python3Packages; [
              click
              semver
              requests
            ];

            # There is an annoying list of linting args we have to disable
            # so Nix will let us build our script in peace.
            flakeIgnore = [ "E501" "F401" "W292" "W291" "E265" "W293" "E252" "E303" ];
          }
          (builtins.readFile(
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/scorbettUM/local-dev/main/scripts/blueprint.py"; 
              sha256 = "0na8d2bv3ljrwhf1k7x33k663a0bvfxsp6qj8dq7i1q0sx3kzwh3";   
            })
          );
        dcon = prev.writers.writePython3Bin "dcon"
          {
            libraries = with prev.python3Packages; [
              click
            ];

            # There is an annoying list of linting args we have to disable
            # so Nix will let us build our script in peace.
            flakeIgnore = [ "E501" "F401" "W292" "W291" "E265" "W293" "E252" "E303" ];
          }
          (builtins.readFile(
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/scorbettUM/local-dev/main/scripts/devcontainers.py"; 
              sha256 = "0b0acsa4gfcqcxqzildb1vagmcqjllsh95l2qxx823qagalzpbnq";   
            })
          );
        aws-login = prev.writers.writeBashBin "aws-login"
          (builtins.readFile(
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/scorbettUM/local-dev/main/scripts/aws_login.sh"; 
              sha256 = "0hi0529jsdx7z7qlsvdg98fddxbv7grd68fkm8f6vllkzi57r1rj";   
            })
          );
        # Unfortunately something installs a newer version of urllib3 that
        # completely breaks awscli. Joy.
        python3 = prev.python3.override {
          packageOverrides = python-self: python-super: {
            urllib3 = python-super.urllib3.overridePythonAttrs (attrs: {
              pyproject = true;
              version = "1.26.18";
              nativeBuildInputs = with prev.python3Packages; [
                setuptools
              ];
              src = attrs.src.override {
                version = "1.26.18";
                hash = "sha256-+OzBu6VmdBNFfFKauVW/jGe0XbeZ0VkGYmFxnjKFgKA=";
              };
            });
          };
        };
      };
    };
}
