# local-dev
This is a repo for WIP/greenfield Nix work develop efficient localized development environment "starter packs" via Just + Nix + Direnv.

<br/>

# Setup

You can copy and use the bash script below to install nix and pull the flake containing primary developer dependencies:

```bash
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
```

This script also enables the `nix-command` and `flakes` experimental features. You may need to update the `NIX_CONFIG` path to reflect where Nix puts its default config file. The default above works for ARM versions of MacOS.

Once the above Flake is run and dependencies are installed, we recommend re-starting your shell (or running `source ~/<PATH_TO_BASH_OR_ZSH_RC_FILE>`).

<br/>

# Using Starter Pack Flakes

To setup a project using any of the above "starter pack" flakes, simply create a new directory:

```bash
mkdir my_app && \
cd my_app
```

then add a `.envrc` file containing the Flake URL you'd like to use:

```bash
use flake "github:scorbettUM/local-dev?dir=<STARTER_PACK_FOLDER>"
```

For example, to use the Python starter, you would create the `.envrc` file below:

```bash
use flake "github:scorbettUM/local-dev?dir=python"
```

If Direnv returns an error regarding a lack of permissions to run the `.envrc`, ignore said error. Next run:

```
direnv allow
```

The Nix should install starter pack flake of choice to that directory, including package managers, linting libraries, etc.

To "unload" or switch projects, simple change out of the current project folder - `direnv` will unload all envars and references to installed packages/libraries/tooling, ensuring anything installed by the flake is isolated to the given directory:

```bash
# Direnv will automatically unload any references to anything installed by the flake, reloading them when you change into the directory again.

cd ..
```

<br/>

# Errata and Notes

- <b>Why Nix + Direnv + Just?</b> <br/> Nix is a tool focused almost exclusively on declarative, reproducible development environments. Direnv focuses on environment isolation. When paired together, Nix and Direnv allow for developers to create and develop within isolated, reproducible environments. 
<br/>
<br/> 
When compaired to alternatives like Chef or Ansible, Nix and Direnv are notably less intrusive, faster, and significantly less error-prone. Notably, Ansible has no internal notion of state, making debugging install failures difficult. Both Ansible and Chef require Python and Ruby respectively, which compounds potential difficulties in installing and maintaining developer tooling using them. The focused nature of Direnv and Nix upon developer environments makes them ideal as part of a composable stack of developer tools.
<br/>
<br/>
Like Nix and Direnv, Just is a focused, minimally intrusive tool - specifically a command runner. Just facilitates recipes like Ansible's Playbooks or Chef's Cookbooks, but only requires Bash to run. Unlike Ansible or Chef, Just Recipes are compatible with most all popular programming languages, meaning developers can easily create or add to existing Recipes while capitalizing on their knowledge of their programming language(s) of choice.
