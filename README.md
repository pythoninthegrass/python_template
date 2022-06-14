# python_template

!["It's dangerous to go alone! Take this."](img/zelda.jpg)
<!-- <img src="https://user-images.githubusercontent.com/4097471/144654508-823c6e31-5e10-404c-9f9f-0d6b9d6ce617.jpg" width="300"> -->

## Summary
Oftentimes the initial setup of a Python repo can take a few minutes to a couple hours.
By laying the foundation to rapidly implement an idea, can focus on the good bits instead of
devops drudgery.

### Caveat Emptor
Very little of this gets tested on Windows hosts. Windows Subsystem for Linux (WSL) is used where necessary with the default Ubuntu LTS install.

Be the change et al if Windows is your main and you wanna raise a PR with broad instructions on getting tooling working under Windows (e.g., docker, poetry, playwright.)

**Table of Contents**
* [python_template](#python_template)
  * [Summary](#summary)
    * [Caveat Emptor](#caveat-emptor)
  * [Setup](#setup)
  * [Usage](#usage)
    * [Mac and Linux users](#mac-and-linux-users)
    * [Windows Subsytem for Linux (wsl)](#windows-subsytem-for-linux-wsl)
    * [asdf](#asdf)
    * [pip](#pip)
    * [Poetry](#poetry)
    * [Docker](#docker)
    * [Playwright](#playwright)
    * [Django](#django)
    * [Flask](#flask)
    * [FastAPI](#fastapi)
    * [Kubernetes (k8s)](#kubernetes-k8s)
    * [Terraform](#terraform)
  * [GitHub Actions](#github-actions)
    * [Update submodules recursively](#update-submodules-recursively)
  * [Debugging](#debugging)
    * [asdf](#asdf-1)
    * [Docker](#docker-1)
    * [PATH](#path)
    * [Terraform](#terraform-1)
  * [TODO](#todo)
  * [Further Reading](#further-reading)

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
Development environments and tooling are first-class citizens on macOS and *nix. For Windows faithfuls, please setup WSL below.

### Windows Subsytem for Linux (wsl)
WSL allows Windows users to run Linux (Unix) [locally at a system-level](https://docs.microsoft.com/en-us/windows/wsl/compare-versions). All of the standard tooling is used and community guides can be followed without standard Windows caveats (e.g., escaping file paths, GNU utilities missing, etc.) 
* Install from the [Setup](#setup) section
* Enable
  * Start Menu > search for "Turn Windows Features On" > open > toggle "Windows Subsystem for Linux"
  * Restart
* M1 Macs only (Intel Macs and native Windows boxes need not apply)
  * Revert WSL 2 to WSL 1 due to nested virtualization not being available at a hardware level
    ```bash
    wsl --set-default-version 1
    ```
  * Docker won't run without paravirtualization enabled, but the rest of the development environment will work as expected
* Install Ubuntu
  ```bash
  # enable default distribution (Ubuntu)
  wsl --install ubuntu
  ```
* Start Linux and prep for environment setup
    ```bash
    # launch Ubuntu
    ubuntu

    # upgrade packages (as root: `sudo -s`)
    apt update && apt upgrade -y

    # create standard user
    adduser <username>
    visudo

    # search for 'Allow root to run any commands anywhere', then append identical line with new user
    root            ALL=(ALL)       ALL
    <username>      ALL=(ALL)       ALL

    # Allow members of group sudo to execute any command
    %sudo  ALL=(ALL) NOPASSWD: ALL
    ```
* Additional configuration options
  * Configuration locations
    * WSL 1: `/etc/wsl.conf`
    * WSL 2: `~/.wslconfig`
      ```bash
        # set default user
        [user]
        default=<username>

        # mounts host drive at /mnt/c/
        [automount]
        enabled = true
        options = "uid=1000,gid=1000"

        # WSL2-specific options
        [wsl2]
        memory = 8GB   # Limits VM memory in WSL 2
        processors = 6 # Makes the WSL 2 VM use two virtual processors
        ```
  * After making changes to the configuration file, WSL needs to be shutdown for [8 seconds](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule)
    * `wsl --shutdown`
  * **OPTIONAL**: Change home directory to host Windows' home
    ```bash
    # copy dotfiles to host home directory
    cp $HOME/.* /mnt/c/Users/<username>

    # edit /etc/passwd
    <username>:x:1000:1000:,,,:/mnt/c/Users/<username>:/bin/bash
    ```

### asdf
* Install from the [Setup](#setup) section
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

### pip
If a basic virtual environment (`venv`) and `requirements.txt` are all that's needed, can use built-in tools.
```bash
# create a virtual environment via python
## built-in
python3 -m venv .venv

## faster
python3 -m pip install virtualenv # _or_ pipx install virtualenv
virtualenv .venv

# activate virtual environment
source .venv/bin/activate

# install dependencies
python3 -m pip install requests inquirer

# generate requirements.txt
python3 -m pip freeze > requirements.txt

# exit virtual environment
deactivate
```

### Poetry
* **NOTE**: it's possible to use the built-in `.venv` virtual environment (e.g., troubleshooting `SolverProblemError` dependency hell)
    ```bash
    poetry env use .venv/bin/python
    ```
* Install from the [Setup](#setup) section
* Normal usage
    ```bash
    # Install (modifies $PATH)
    curl -sSL https://install.python-poetry.org | $(which python3) - # append `--no-modify-path` to EOL if you know what you're doing 

    # Change config
    poetry config virtualenvs.in-project true           # .venv in `pwd`
    poetry config experimental.new-installer false      # fixes JSONDecodeError on Python3.10

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

    # Uninstall Poetry (e.g., troubleshooting)
    POETRY_UNINSTALL=1 bash -c 'curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py' | $(which python3) -
    ```

### Docker
* Install from the [Setup](#setup) section
* Usage
    ```bash
    # clean build (remove `--no-cache` for speed)
    docker-compose build --no-cache --parallel

    # start container
    docker-compose up --remove-orphans -d

    # exec into container
    docker attach hello

    # run command inside container
    python hello.py

    # stop container
    docker-compose stop

    # destroy container and network
    docker-compose down
    ```

### Playwright
* Install from the [Setup](#setup) section
* Usage
    ```bash
    # install
    pip install --upgrade pip
    pip install playwright
    playwright install

    # download new browsers (chromedriver, gecko)
    npx playwright install

    # generate code via macro
    playwright codegen wikipedia.org
    ```

### Django
* Follow the official [Django Docker Compose article](https://docs.docker.com/samples/django/)
    * `cd django`
    * Generate the server boilerplate code
        ```bash
        docker-compose run web django-admin startproject composeexample .
        ```
    * Fix upstream import bug and whitelist all hosts/localhost
        ```bash
        $ vim composeexample/settings.py
        import os
        ...
        ALLOWED_HOSTS = ["*"]
        ```
    * Profit
        ```bash
        docker-compose up
        ```
    * **Optional**: Comment out Django exclusions for future commits
        * Assumed if extracting Django boilerplate from template and creating a new repo
        ```bash
        # .gitignore
        # ETC
        # django/composeexample/
        # django/data/
        # django/manage.py
        ```

### Flask

### FastAPI

### Kubernetes (k8s)
* Easiest way to set up a local single node cluster is via one of the following:
    * [Rancher Desktop](https://docs.rancherdesktop.io/getting-started/installation)
    * [minikube](https://minikube.sigs.k8s.io/docs/start/)
      * Incidentally, `minikube` ships with the Kubernetes Dashboard
        ```bash
        minikube dashboard
        ```
      * The boilerplate [Terraform plan](#terraform) below hasn't been tested against `minikube`
    * [multipass](https://multipass.run/) with [microk8s](https://ubuntu.com/tutorials/getting-started-with-kubernetes-ha#1-overview)
* Add aliases to `~/.bashrc` or `~/.zshrc`
    ```bash
    # k8s
    alias k="kubectl"
    alias kc="kubectl config use-context"
    alias kns='kubectl config set-context --current --namespace'
    alias kgns="kubectl config view --minify --output 'jsonpath={..namespace}' | xargs printf '%s\n'"
    KUBECONFIG="$HOME/.kube/config:$HOME/.kube/kubeconfig:$HOME/.kube/k3s.yaml"
    ```
* CLI/TUI (terminal user interface) management of k8s
  * [k9s](https://github.com/derailed/k9s#installation)
    * Built-in help: type `?`
    * Main Screen: `:pod`
    ![Main screen](img/k9s_main.png)
    * Describe a pod: `d`
    ![Describe a pod](img/k9s_describe.png)
    * Delete a pod: 
      * `ctrl-d`
      * Replicas rebuild
    ![Delete a pod](img/k9s_delete_pod.png)
    * Remove resource (permanent)
      * `:deploy`
      * `ctrl-d`
    ![Remove resource](img/k9s_remove_res.png)
* [POC](https://itnext.io/simplest-minimal-k8s-app-tutorial-with-rancher-desktop-in-5-min-5481edb9a4a5)
  ```bash
  git clone https://github.com/jwsy/simplest-k8s.git
  k config get-contexts                    # should have `rancher-desktop` selected
  kc rancher-desktop                       # switch to rancher context if not
  k create namespace simplest-k8s
  k apply -n simplest-k8s -f simplest-k8s
  k delete -n simplest-k8s -f simplest-k8s
  k delete namespace simplest-k8s
  ```
  * Navigate to https://jade-shooter.rancher.localhost/ in Chrome
  * Allow self-signed cert
  * Profit 💸 

### Terraform
* **NOTES**: 
  * This section depends on Kubernetes and a `~/.kubeconfig` from [above](#kubernetes-k8s)
  * `NodePort` was used instead of `LoadBalancer` for `service.type`
    * [MetalLB is a stretch goal](https://stackoverflow.com/a/71047314) for future deployments
* Install `terraform` via `asdf
    ```bash
    # terraform
    asdf plugin-add terraform
    asdf install terraform latest
    ```
* Add aliases to `~/.bashrc` or `~/.zshrc`
    ```bash
    # ~/.bashrc
    alias tf='terraform'
    alias tfi='terraform init -backend-config=./state.conf'
    alias tfa='terraform apply'
    alias tfp='terraform plan'
    alias tfpn='terraform plan -refresh=false'
    ```
* Navigate to `./terraform/` and [initialize](https://www.terraform.io/cli/commands/init) the `terraform` working directory
    ```bash
    cd terraform/
    tfi
    ```
* Create an [execution plan](https://www.terraform.io/cli/commands/plan)
    ```bash
    tfp
    ```
* [Apply/execute the actions](https://www.terraform.io/cli/commands/apply) from Terraform plan
    ```bash
    tfa
    ```
* Navigate to `http://localhost:<port>`
  * Port can be found via `kubectl`
    ```bash
    k get svc   # 80:31942/TCP
    ```
* [Tear down deployment](https://www.terraform.io/cli/commands/destroy)
    ```bash
    tf destroy
    ```
  * Real-time view of pod removal
    ![Real-time view of pod removal](img/k9s_termination.png)

## GitHub Actions
### Update submodules recursively
* Add the submodule to the downstream repo
    ```bash
    git submodule add https://github.com/pythoninthegrass/automate_boring_stuff.git
    git commit -m "automate_boring_stuff submodule"
    git push
    ```
* Create a personal access token called `PRIVATE_TOKEN_GITHUB` with `repo` permissions on the downstream repo
    * `repo:status`
    * `repo_deployment`
    * `public_repo`
* Add that key to the original repo
    * Settings > Security > Secrets > Actions
    * New repository secret
* Setup a new Action workflow
    * Actions > New Workflow
    * Choose a workflow > set up a workflow yourself
    ```bash
    # main.yml
    # SOURCE: https://stackoverflow.com/a/68213855
    name: Send submodule updates to parent repo

    on:
    push:
        branches: 
        - main
        - master

    jobs:
    update:
        runs-on: ubuntu-latest

        steps:
        - uses: actions/checkout@v2
            with: 
            repository: username/repo_name
            token: ${{ secrets.PRIVATE_TOKEN_GITHUB }}

        - name: Pull & update submodules recursively
            run: |
            git submodule update --init --recursive
            git submodule update --recursive --remote
        - name: Commit
            run: |
            git config user.email "actions@github.com"
            git config user.name "GitHub Actions - update submodules"
            git add --all
            git commit -m "Update submodules" || echo "No changes to commit"
            git push
    ```

## Debugging
### asdf
**No version set for command python**
* Make sure `python` or `python3` isn't aliased in `~/.bashrc` or `~/.zshrc`

[bash - Is it possible to check where an alias was defined? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/322459/is-it-possible-to-check-where-an-alias-was-defined/544970#544970)

### Docker
* Watch logs in real-time: `docker-compose logs -tf --tail="50" hello`
* Check exit code
    ```bash
    $ docker-compose ps
    Name                          Command               State    Ports
    ------------------------------------------------------------------------------
    docker_python      python manage.py runserver ...   Exit 0
    ```

### PATH
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
### Terraform
* [Verbose logging](https://www.terraform.io/cli/config/environment-variables) and redirection to a file
    ```bash
    export TF_LOG="trace"                       # unset via "off"
    export TF_LOG_PATH="$HOME/Downloads/tf.log" # `~` doesn't expand
    ```
    * [Log levels](https://www.terraform.io/internals/debugging)
      * TRACE
      * DEBUG
      * INFO
      * WARN
      * ERROR
* `Error: cannot re-use a name that is still in use`
    > I think I resolved the issue. This is what I did: 1) mv the terraform.tfstate to another name, 2) mv the terraform.tfstate.backup to terraform.tfstate, and 3) run 'terraform refresh' command to confirm the state is synchronized, and 4) run 'terraform apply' to delete/create the resource. I will mark your reply as the answer, as it gives me the clue for solving the issue. Thanks! – ozmhsh Dec 9, 2021 at 4:57

    [nginx - Stuck in the partial helm release on Terraform to Kubernetes - Stack Overflow](https://stackoverflow.com/questions/70281363/stuck-in-the-partial-helm-release-on-terraform-to-kubernetes#comment124244564_70281451)

## TODO
* pipx
 ```bash
 # Install
 python3 -m pip install --user pipx
 python3 -m pipx ensurepath

 # Usage
 ...
 ```
* Django
    * Merge with [docker_python](https://github.com/pythoninthegrass/docker_python) and put the latter on an ice float
* Flask
    * Bonus points for [Svelte](https://svelte.dev/blog/the-easiest-way-to-get-started) front-end ❤️
* FastAPI
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

## Further Reading
[Basic writing and formatting syntax - GitHub Docs](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

[venv — Creation of virtual environments — Python 3.7.2 documentation](https://docs.python.org/3/library/venv.html)

[pip freeze - pip documentation v22.0.3](https://pip.pypa.io/en/stable/cli/pip_freeze/)

[Introduction | Documentation | Poetry - Python dependency management and packaging made easy](https://python-poetry.org/docs/)

[Commands | Documentation | Poetry - Python dependency management and packaging made easy](https://python-poetry.org/docs/cli#export)

[Overview of Docker Compose | Docker Documentation](https://docs.docker.com/compose/)

[Compose file version 3 reference | Docker Documentation](https://docs.docker.com/compose/compose-file/compose-file-v3/)

[Commands](https://k9scli.io/topics/commands/)

[Speed up administration of Kubernetes clusters with k9s | Opensource.com](https://opensource.com/article/20/5/kubernetes-administration)

[Getting started | Playwright Python | codegen macro](https://playwright.dev/python/docs/intro)

[Install WSL | Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/install)

[Set up a WSL development environment | Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)

[Advanced settings configuration in WSL | Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)

[Understanding The Python Path Environment Variable in Python](https://www.simplilearn.com/tutorials/python-tutorial/python-path)
