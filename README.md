# python_template

!["It's dangerous to go alone! Take this."](img/zelda.jpg)
<!-- <img src="https://user-images.githubusercontent.com/4097471/144654508-823c6e31-5e10-404c-9f9f-0d6b9d6ce617.jpg" width="300"> -->

## Summary
Oftentimes the initial setup of a Python repo can take a few minutes to a couple hours.
By laying the foundation to rapidly implement an idea, can focus on the good bits instead of
devops drudgery.

### Caveat Emptor
Very little of this gets tested on Windows hosts. Windows Subsystem for Linux (WSL) is used where necessary with the default Ubuntu LTS install. Moved bulk of document to the [markdown](markdown/) directory to opt-in vs. opt-out of documentation.

Be the change et al if Windows is your main and you wanna raise a PR with broad instructions on getting tooling working under Windows (e.g., docker, poetry, playwright.)

**Table of Contents**
* [python_template](#python_template)
  * [Summary](#summary)
    * [Caveat Emptor](#caveat-emptor)
  * [Setup](../README.md#setup)
  * [Usage](#usage)
    * [Mac and Linux users](#mac-and-linux-users)
    * [git pre-commit hooks](#git-pre-commit-hooks)
  * [TODO](#todo)

## Setup
* Install
    * [editorconfig](https://editorconfig.org/)
    * [wsl](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)
    * [asdf](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf)
    * [poetry](https://python-poetry.org/docs/)
    * [docker-compose](https://docs.docker.com/compose/install/)
    * [playwright](https://playwright.dev/python/docs/intro#installation)
    * [Kubernetes (k8s)](#kubernetes-k8s)

## Usage
### Mac and Linux users
Development environments and tooling are first-class citizens on macOS and *nix. For Windows faithfuls, please setup [WSL](markdown/wsl.md).

### git pre-commit hooks
* Install
    ```bash
    # pip
    python -m pip install pre-commit

    # brew
    brew install pre-commit

    # install .pre-commit-config.yaml
    pre-commit install                  # install/uninstall
    ```
* Usage
    ```bash
    # skip pre-commit by ID
    SKIP=flake8 git commit -m "foo"

    # skip all pre-commit hooks (e.g., bypass false positives like comment preceding docstring)
    λ git commit -m "Formatting (WIP)" -m "Debugging  formatters" --no-verify
    [master d260d56] Formatting (WIP)
    1 file changed, 108 insertions(+), 34 deletions(-)

    # black dry-run
    black --check --diff file_name.py

    # skip code block
    # fmt: off

    import argparse
    # from icecream import ic
    from pathlib import Path

    # fmt: on

    # skip individual line (buggy)
    # from icecream import ic # fmt: skip

    # manually run commit hook against one file
    pre-commit run black --files email_it/email_it.py --verbose

    # manually run against repo (vs. during commit)
    λ pre-commit run --all-files
    [INFO] Initializing environment for https://github.com/zricethezav/gitleaks.
    <SNIP>
    Detect hardcoded secrets.................................................Passed

    # update hooks
    pre-commit autoupdate
    ```

## TODO
* Django
    * Merge with [docker_python](https://github.com/pythoninthegrass/docker_python) and put the latter on an ice float
* Flask
    * Bonus points for [Svelte](https://svelte.dev/blog/the-easiest-way-to-get-started) front-end ❤️
* FastAPI
* MongoDB
  * Switch to `docker-compose`
  * Fix unique index deleting too many keys
* k8s
  * `~/.kubeconfig`
* ansible
* wsl
  * VSCode
      * Remote WSL install and usage
        * Or at least further reading nods
* Debugging
   * Dependencies
   * script itself via [icecream](https://github.com/gruns/icecream)
