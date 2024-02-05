requirements_path := "requirements.txt"
profile := "prod"
region := "us-east-1"
base_path := invocation_directory()

create-project *ARGS:
    create-project "--base-path={{base_path}}"  "{{ARGS}}"

setup-venv venv_path requirements_path=requirements_path:
    python -m venv {{venv_path}} && \
    source {{venv_path}}/bin/activate && \
    pip install {{requirements_path}}

aws-login profile=profile region=region:
    aws-login {{profile}} {{region}}
