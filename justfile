type := "python3"
project := "my_project"
app_base := "scorbettUM/app-templates"
app := "fast-api"
flake_base := "scorbettUM/local-dev"
path := join(
    invocation_directory(),
    project
)


create-project type=type project=project app=app app_base=app_base flake_base=flake_base path=path:
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

    