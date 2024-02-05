#!/usr/bin/python

import os
import subprocess
import sys
import textwrap
from typing import Dict, List, Optional


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


def parse_args(args_set: List[str]):

    show_help = [
        arg for arg in args_set if '--help' in arg
    ]

    arg_options = [
        arg for arg in args_set if arg.startswith('--')
    ]   

    if show_help or len(arg_options) < 1:
        print(
            textwrap.dedent(
                '''
                create-project:

                    Description: Create a local project from a given template repo.

                    Args:
                        --path (str): Path where the project should be created.

                        --name (str): Name of the project to create.

                        --template (str): The name of the project template to use. 
                                          Should match a branch name in the template 
                                          repository.

                        --template-repo (str): The repo to use for project templates. 
                                               Should be a Github repo and follow the 
                                               formant <USERNAME_OR_ORG/REPO>.

                        --flake (str): The Nix Flake to use for installing dependencies.
                                       Should be a directiry in the Flake repository.

                        --flake-repo (str): The repo to use for Nix Flakes. Should be a 
                                            Github repo and follow the formant 
                                            <USERNAME_OR_ORG/REPO>.

                        --remote (str): The git remote to use for newly created project
                                        repo.
                        
                '''
            )
        )

        return {}

    args = {}
    for arg in arg_options:
        if "=" in arg:
            arg_name, arg_value = arg.split("=", maxsplit=1)
            args[arg_name.strip("-")] = arg_value

    return args


def execute_command(
    args: Dict[str, str]
):
    project_path = args.get('path', os.getcwd())
    project_name = args.get("name", "myapp")
    project_template = args.get("template", "fast-api")
    project_template_repo = args.get("template-repo", "scorbettUM/app-templates")
    project_flake_repo = args.get("flake-repo", "scorbettUM/local-dev")
    project_flake = args.get("flake", "python3")
    project_remote = args.get("remote")

    project_creation_path = project_name
    if not project_name.startswith('/') or ':\\' not in project_name:
        project_creation_path = os.path.join(project_path, project_name)

    execute_in_shell(
        f'cookiecutter git@github.com:{project_template_repo} --checkout {project_template}',
        project_path,
        interactive_input=f'y\n{project_name}',
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
            f'use flake \"github:{project_flake_repo}?dir=projects/{project_flake}\"'
        )

    execute_in_shell(
        "git add -A",
        project_creation_path
    ) 

    if project_remote:
        execute_in_shell(
            f'git remote add origin {project_remote}',
            project_creation_path
        ) 


def run():
    args = parse_args(sys.argv)

    if len(args) < 1:
        return
    
    execute_command(args)


run()
