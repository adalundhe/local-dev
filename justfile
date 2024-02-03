project := "my_project"
app_base := "scorbettUM/app-templates"
app := "fast-api"
flake_base := "scorbettUM/local-dev"
type := "python312"
path := join(
    invocation_directory(),
    project
)


create-project:
    #!/usr/bin/env bash
    set -euxo pipefail

    mkdir -p {{path}} && cd {{path}}

    git clone --branch {{app}} "git@github.com:{{app_base}}" {{path}}
    rm -rf .git
    git init
    git add -A

    touch ".envrc"
    echo 'use flake "github:{{flake_base}}?dir={{type}}"' | tee ".envrc" > /dev/null
    direnv allow

    