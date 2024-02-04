requirements_path := "requirements.txt"

create-project *ARGS:
    create-project "{{ARGS}}"

setup-venv venv_path requirements_path=requirements_path:
    python -m venv {{venv_path}} && \
    source {{venv_path}}/bin/activate && \
    pip install {{requirements_path}}
