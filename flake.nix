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
              python3
              awscli2
              ripgrep
              xcode-install
              python3Packages.cookiecutter
              gitAndTools.gh
              werkflow
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

                cp justfile $HOME
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
            ];

            # There is an annoying list of linting args we have to disable
            # so Nix will let us build our script in peace.
            flakeIgnore = [ "E501" "F401" "W292" "W291" "E265" "W293" "E252" "E303" ];
          }
          (builtins.readFile(
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/scorbettUM/local-dev/main/scripts/blueprint.py"; 
              sha256 = "1gj7hkn3lpxq0cp7cmhdpjc0z53vssdhp3xva9bpslr0r5bpyrhv";   
            })
          );
        aws-login = prev.writers.writeBashBin "aws-login"
          (builtins.readFile(
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/scorbettUM/local-dev/main/scripts/aws_login.sh"; 
              sha256 = "0hi0529jsdx7z7qlsvdg98fddxbv7grd68fkm8f6vllkzi57r1rj";   
            })
          );
        werkflow = prev.pkgs.python3Packages.buildPythonPackage rec {
          pname = "werkflow";
          version = "0.1.4";
          format = "wheel";
          src = prev.pkgs.python3Packages.fetchPypi {
            inherit pname version;
            sha256 = "sha256-KGcyxDfhsWNAKQcD45giu/o9B7ZNSMtKatRGgZr5V/0="; # TODO
          };
        };
      };
    };
}