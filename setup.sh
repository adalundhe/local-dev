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

cat <<'EOF'

Nice! Check it out, you've got so much fun stuff available now.
If you want to get started developing in this repo, run the following command below:
nix develop

Or, if you have direnv installed, give this a try:
direnv allow
EOF