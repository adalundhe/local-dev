#!/usr/bin/python

import os
import subprocess
from typing import Optional

import click
import requests
import semver
from requests import Response


def execute_in_shell(
    command: str,
    path: str,
    interactive_input: Optional[str]=None,
    skip_error: bool=False
):
    if interactive_input:
        result = subprocess.Popen(
            command.split(),
            cwd=path,
            stdin=subprocess.PIPE,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
        )

        result.communicate(interactive_input)

    else:
        result = subprocess.run(
            command.split(),
            cwd=path,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
        )
        
    if result.returncode > 0 and skip_error is False:
        raise Exception(f"Err. - Template creation failed:\n{result.stderr}\n{result.stdout}")
    
    return result


def get_latest_version():
    result: Response = requests.get(
        "https://endoflife.date/api/python.json"
    )
    parsed_result = result.json()
    version_string = parsed_result[0]["latest"]

    version_data = semver.Version.parse(version_string)
    return f'{version_data.major}.{version_data.minor}'


@click.group()
def project():
    pass


@project.command(
    'create',
    help='Create a new project from a conformant template repo.'
)
@click.option(
    '--name',
    required=True,
    help='The name of the project.'
)
@click.option(
    '--remote',
    help='Set the git remote for the new project.'
)
@click.option(
    '--path',
    default=os.getcwd(),
    help='The path to create the project at.'
)
@click.option(
    '--template',
    default='python-app',
    help='The to use for creating the project.'
)
@click.option(
    '--language',
    default='python',
    help='The language to use for the template.'
)
@click.option(
    '--version',
    help='The version of the language to use for the template.'
)
def create(
    name: str,
    remote: Optional[str],
    path: str,
    template: str,
    language: str,
    version: Optional[str]
):
    if version is None:
        version = get_latest_version()
        
    project_template_repo = "scorbettUM/app-templates"
    project_flake_repo = "scorbettUM/local-dev"

    project_creation_path = name
    if not name.startswith('/') or ':\\' not in name:
        project_creation_path = os.path.join(path, name)

    execute_in_shell(
        f'cookiecutter git@github.com:{project_template_repo} --checkout {template}',
        path,
        interactive_input='\n'.join([
            'y',
            name,
            version
        ]),
        skip_error=True
    )

    commands = [
        "rm -rf .git",
        "git init",
        "touch .envrc",
        "code --install-extension ms-vscode-remote.remote-containers --force"
    ]

    for command in commands:
        execute_in_shell(
            command,
            project_creation_path
        )

    envrc_path = os.path.join(
        project_creation_path,
        '.envrc'
    )

    with open(envrc_path, 'w') as envrc:
        envrc.write(
            f'''use flake \"github:{project_flake_repo}?dir=projects/{language}/{version}\"'''
        )

    execute_in_shell(
        "git add -A",
        project_creation_path
    ) 

    if remote:
        execute_in_shell(
            f'git remote add origin {remote}',
            project_creation_path
        ) 


project()