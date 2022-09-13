### asdf

* Install from the [Setup](../README.md#setup) section
* WSL/Ubuntu Linux dependencies
    ```bash
    sudo apt update && sudo apt install \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget \
    curl llvm libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    ```
* Fedora dependencies
    ```bash
    sudo dnf install -y bzip2-devel libsqlite3x-devel
    ```
* All operating systems
    ```bash
    # add python plugin
    asdf plugin-add python

    # install stable python
    asdf install python latest

    # uninstall version
    asdf uninstall python 3.9.6

    # refresh symlinks for installed python runtimes
    asdf reshim python

    # set stable to system python
    asdf global python latest

    # optional: local python (e.g., python 3.9.10)
    cd $work_dir
    asdf list-all python 3.9
    asdf install python 3.9.10
    asdf local python 3.9.10

    # verify python shim in use
    asdf current

    # check installed python
    asdf list python
    ```

#### Debugging
**No version set for command python**
* Make sure `python` or `python3` isn't aliased in `~/.bashrc` or `~/.zshrc`

[bash - Is it possible to check where an alias was defined? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/322459/is-it-possible-to-check-where-an-alias-was-defined/544970#544970)

##### PATH
* `asdf`, `poetry`, and `python` all need to be sourced in your shell `$PATH` in a specific order
  * `asdf` stores its Python shims in `~/.asdf/shims`
  * `poetry` lives in `~/.local/bin`
    ```bash
    export ASDF_DIR="$HOME/.asdf"
    export PATH="$ASDF_DIR/shims:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    ```
* Furthermore, any aliases or alias files need to be sourced as well
    ```bash
    . "$ASDF_DIR/asdf.sh"
    . "$ASDF_DIR/completions/asdf.bash"
    . /usr/local/etc/profile.d/poetry.bash-completion
    ```
