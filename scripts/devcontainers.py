import os
import subprocess

import click


@click.group()
def devcontainers():
    pass


@devcontainers.command()
@click.option(
    '--path',
    default=os.getcwd(),
    help='Shell into the Devcontainer at the given path.'
)
def shell(
    path: str
):
    subprocess.run(
        [
            'devcontainer',
            'exec',
            '--workspace-folder',
            path,
            'bash'
        ]
    )


@devcontainers.command()
@click.option(
    '--path',
    default=os.getcwd(),
    help='Shell into the Devcontainer at the given path.'
)
def up(
    path: SystemError
):
    subprocess.run(
        [
            'devcontainer',
            'build',
            '--workspace-folder',
            path
        ]
    )

    subprocess.run(
        [
            'devcontainer',
            'up',
            '--workspace-folder',
            path
        ]
    )


devcontainers()