### Pipx

* Install
    ```bash
    # macOS
    brew install pipx
    pipx ensurepath

    # Linux
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath

    # ~/.bashrc
    eval "$(register-python-argcomplete pipx)"
    export PIPX_DEFAULT_PYTHON="$ASDF_DIR/shims/python"
    ```

* Usage
    ```bash
    # install package
    pipx install pycowsay

    # list packages
    pipx list

    # run without install (i.e., npx)
    pipx run pycowsay moooo!

    # install a package then add a dependency
    pipx install nox
    pipx inject nox nox-poetry
    ```

[pipx](https://pypa.github.io/pipx/)
