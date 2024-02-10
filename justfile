requirements_path := "requirements.txt"
profile := "prod"
region := "us-east-1"
base_path := invocation_directory()


blueprint *ARGS:
    blueprint {{ARGS}} --path {{base_path}}


setup-venv venv_path requirements_path=requirements_path:
    #! /usr/bin/env bash
    python -m venv {{venv_path}}

    if [[ -e {{requirements_path}} ]]; then
        source {{venv_path}}/bin/activate && \
        pip install {{requirements_path}}
    fi

create-werkflow name *ARGS:
    #! /usr/bin/env bash
    just setup-venv ".{{name}}" && \
    source .{{name}}/bin/activate && \
    pip install poetry && \
    poetry init -q --name={{name}}

    blueprint --path {{base_path}} --name {{name}} --template=werkflow {{ARGS}}
    poetry lock && poetry update


aws-login profile=profile region=region:
    aws-login {{profile}} {{region}}


container:
    dcon
