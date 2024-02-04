{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
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
              bashInteractive
              create-project
              devcontainers
              direnv
              docker
              docker-compose
              gum
              just
              nixpkgs-fmt
              nodejs_20
              nodejs_20.pkgs.pnpm
              python3
              ripgrep
              xcode-install
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

                [[ -f justfile  ]] && command -v just >/dev/null 2>&1 && just --list --unsorted
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
        create-project = prev.writers.writePython3Bin "create-project"
          {
            libraries = [ ];

            # There is an annoying list of linting args we have to disable
            # so Nix will let us build our script in peace.
            flakeIgnore = [ "E501" "F401" "W292" "W291" "E265" "W293" ];
          }
          (builtins.readFile(
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/scorbettUM/local-dev/main/create_project.py"; 
              sha256 = "0cz2k3vi76pi22cxjqf370m7rqxq719ridaf8vvw2sir1qm7i8n6";   
            })
          );
      };
    };
}