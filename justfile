requirements_path := "requirements.txt"
profile := "prod"
region := "us-east-1"
base_path := invocation_directory()


blueprint *ARGS:
    blueprint "--path={{base_path}}"  "{{ARGS}}"


setup-venv venv_path requirements_path=requirements_path:
    #! /usr/bin/env bash
    python -m venv {{venv_path}}

    if [[ -e {{requirements_path}} ]]; then
        source {{venv_path}}/bin/activate && \
        pip install {{requirements_path}}
    fi


werkflow name:
    #! /usr/bin/env bash
    just setup-venv ".{{name}}" && \
    source .{{name}}/bin/activate && \
    pip install werkflow

    blueprint --path="$PWD" --name={{name}} --template=werkflow


aws-login profile=profile region=region:
    aws-login {{profile}} {{region}}


dev:
    devcontainer build
    devcontainer up
    devcontainer open
