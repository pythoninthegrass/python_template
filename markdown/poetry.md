### Poetry

* **NOTE**: it's possible to use the built-in `.venv` virtual environment (e.g., troubleshooting `SolverProblemError` dependency hell)
    ```bash
    poetry env use .venv/bin/python
    ```
* Install from the [Setup](../README.md#setup) section
* Normal usage
    ```bash
    # Install
    curl -sSL https://install.python-poetry.org | $(which python3) -

    # Uninstall
    export POETRY_UNINSTALL=1
    curl -sSL https://install.python-poetry.org | $(which python3) -

    # Change config
    poetry config virtualenvs.in-project true           # .venv in `pwd`

    # Activate virtual environment (venv)
    poetry shell

    # Deactivate venv
    exit  # ctrl-d

    # Install multiple libraries
    poetry add google-auth google-api-python-client

    # Initialize existing project
    poetry init

    # Run script and exit environment
    poetry run python your_script.py

    # Install from requirements.txt
    poetry add `cat requirements.txt`

    # Update dependencies
    poetry update

    # Remove library
    poetry remove google-auth

    # Generate requirements.txt
    poetry export -f requirements.txt --output requirements.txt --without-hashes
    ```
* Poetry with `asdf`
    ```bash
     # Add poetry asdf plugin
    asdf plugin-add poetry https://github.com/asdf-community/asdf-poetry.git

    # Install latest version via asdf
    asdf install poetry latest

    # Set latest version as default
    asdf global poetry latest

    # Install via asdf w/version
    ASDF_POETRY_INSTALL_URL=https://install.python-poetry.org asdf install poetry 1.2.2
    asdf local poetry 1.2.2
    ```
