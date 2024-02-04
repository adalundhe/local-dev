#!/usr/bin/env bash

set -euo pipefail

cat <<'EOF'
Welcome to the setup of your awesome local dev environment!
This script will:
1. Install nix if necessary
2. Print out the commands required to get started
3. Send you on your merry way!
EOF

[[ ! -d /nix/store ]] && {
  printf '\n\n%s\n\n' "Installing Nix!"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
}

if ! command -v nix >/dev/null && [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  printf '\n\n%s\n\n' "Adding nix into the script's environment"
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

printf '\n\n%s: ... %s\n' "Testing whether Nix is available in subsequent commands" "$(nix --version)"

nix develop "github:scorbettUM/local-dev"

cat <<'EOF'

Nice! Check it out, you've got so much fun stuff available now, including:

- just
- direnv
- docker
- docker-compose
- Python 3
- NodeJS LTS
- Ripgrep
- Devcontainers CLI

EOF