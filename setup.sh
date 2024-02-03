#!/usr/bin/env bash

USER_PASSWORD=${USER_PASSWORD:-}
NIX_CONFIG=${NIX_CONFIG:-"/etc/nix/nix.conf"}


curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Testing whether Nix is available in subsequent commands
nix --version

echo "build-users-group = nixbld
experimental-features = nix-command flakes
" | sudo tee $NIX_CONFIG > /dev/null

NIXPKGS_ALLOW_UNFREE=1 nix develop "github:scorbettUM/local-dev"