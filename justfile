requirements_path := "requirements.txt"
profile := "prod"
region := "us-east-1"

create-project *ARGS:
    create-project "{{ARGS}}"

setup-venv venv_path requirements_path=requirements_path:
    python -m venv {{venv_path}} && \
    source {{venv_path}}/bin/activate && \
    pip install {{requirements_path}}

aws-login profile=profile:
    #!/usr/bin/env sh
    aws sso login --profile {{profile}}
    aws codeartifact login --tool pip --region {{region}} --domain datavant --domain-owner "$AWS_PROFILE_ID" --repository eng --profile {{profile}}
    aws codeartifact login --tool npm --region {{region}} --domain datavant --domain-owner "$AWS_PROFILE_ID" --repository eng --profile {{profile}}
    aws ecr get-login-password --region {{region}} --profile {{profile}} | docker login --username AWS --password-stdin "$AWS_PROFILE_ID".dkr.ecr.{{region}}.amazonaws.com
