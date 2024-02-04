#!/usr/bin/python

import sys
import os
import textwrap
import subprocess
from typing import Dict, List


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
                        
                '''
            )
        )

        exit(0)

    args = {}
    for arg in arg_options:
        if "=" in arg:
            arg_name, arg_value = arg.split("=", maxsplit=1)
            args[arg_name.strip("-")] = arg_value

    return args


def run_flake(args: Dict[str, str]):
    current_directory = os.getcwd()
    project_directory = args.get("path", "my_project")
    project_template = args.get("template", "fast-api")
    project_template_repo = args.get("template-repo", "scorbettUM/app-templates")
    project_flake_repo = args.get("flake-repo", "scorbettUM/local-dev")
    project_flake = args.get("flake", "python3")

    project_path = project_directory
    if not project_directory.startswith('/') or ':\\' not in project_directory:
        project_path = os.path.join(current_directory, project_directory)

    if os.path.exists(project_path) is False:
        os.makedirs(project_path)

    commands = [
        f"git clone --branch {project_template} git@github.com:{project_template_repo} .",
        "rm -rf .git",
        "git init",
        "git add -A",
        "touch .envrc",
        f"echo 'use flake \"github:{project_flake_repo}?dir={project_flake}\"' | tee .envrc",
        "code --install-extension ms-vscode-remote.remote-containers --force",
    ]

    for command in commands:
        result = subprocess.run(
            command.split(),
            cwd=project_path,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True,
        )

        if result.returncode > 0:
            raise Exception(f"Err. - Template creation failed: {result.stderr}")


run_flake(parse_args(sys.argv))
