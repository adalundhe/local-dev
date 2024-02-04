import os
import json
import subprocess
from pathlib import Path
from typing import Dict, List


def parse_args(command_args: str):
    args = {}
    for arg in command_args.split():
        if '=' in arg:
            arg_name, arg_value = arg.split('=', maxsplit=1)
            args[arg_name.strip('-')] = arg_value

    return args

def run_flake(args: Dict[str, str]):
    current_directory = os.getcwd()
    project_directory = args.get('path', 'my_project')
    project_template_type = args.get('template', 'python-app')
    project_source = args.get('source', 'scorbettUM/app-templates')
    project_flake_repo = args.get('flake-repo', 'scorbettUM/local-dev')
    project_flake = args.get('flake', 'python3')
    project_docker_path = args.get(
        'docker-path',
        os.path.join(
            Path.home(),
            ".docker",
            'config.json'
        )
    )


    project_path = os.path.join(
        current_directory,
        project_directory
    )
    
    if os.path.exists(project_path) is False:
        os.makedirs(project_path)

    commands = [
        f'git clone --branch {project_template_type} git@github.com:{project_source} .',
        'rm -rf .git',
        'git init',
        'git add -A',
        'touch .envrc',
        f'echo \'use flake "github:{project_flake_repo}?dir={project_flake}"\' | tee .envrc',
        'code --install-extension ms-vscode-remote.remote-containers --force'
    ]

    for command in commands:
        result = subprocess.run(
            command.split(),
            cwd=project_path,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True
        )

        if result.returncode > 0:
            raise Exception(f'Err. - Template creation failed: {result.stderr}')

    docker_json: Dict[str, Dict[str, str]] = {}
    if os.path.exists(project_docker_path):
        with open(project_docker_path) as docker_config:
            docker_json = json.load(docker_config)

    if docker_json.get('credsStore') != "osxkeychain":
        docker_json['credsStore'] = "osxkeychain"

    if docker_json.get('currentContext') != 'colima':
        docker_json['currentContext'] = 'colima'
    
    with open(project_docker_path, 'w') as docker_config:
        json.dump(
            docker_json,
            docker_config
        )
    

run_flake(
    parse_args("{{ARGS}}")
)