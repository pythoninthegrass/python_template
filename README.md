# python_template

!["It's dangerous to go alone! Take this."](zelda.jpg)
<!-- <img src="https://user-images.githubusercontent.com/4097471/144654508-823c6e31-5e10-404c-9f9f-0d6b9d6ce617.jpg" width="300"> -->

## Summary
Oftentimes the initial setup of a Python repo can take a few minutes to a couple hours.
By laying the foundation to rapidly implement an idea, can focus on the good bits instead of
devops drudgery.

### Caveat Emptor
Very little of this gets tested on Windows hosts. Windows Subsystem for Linux (WSL) is used where necessary with the default Ubuntu LTS install.

Be the change et al if Windows is your main and you wanna raise a PR with broad instructions on getting tooling working under Windows (e.g., docker, poetry, playwright.)

## Setup
* Install 
    * [editorconfig](https://editorconfig.org/)
    * [asdf](https://asdf-vm.com/manage/core.html#installation-setup)
    * [poetry](https://python-poetry.org/docs/)
    * [docker-compose](https://docs.docker.com/compose/install/)
    * [playwright](https://playwright.dev/python/docs/intro#installation)

## Usage
### asdf
```bash
# add python plugin
asdf plugin-add python

# install stable python
asdf install python latest

# refresh symlinks for installed python runtimes
asdf reshim python

# set stable to system python
asdf global python latest

# optional: local python (e.g., python 3.9.10)
cd $work_dir
asdf list-all python 3.9
asdf install python 3.9.10
asdf local python 3.9.10

# check installed python
asdf list python
```

### Python pip
If a basic virtual environment (`venv`) and `requirements.txt` are all that's needed, can use built-in tools.
```bash
# create a virtual environment via python
python3 -m venv .venv

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
```

### Docker
```bash
# clean build (remove `--no-cache` for speed)
docker-compose build --no-cache --parallel

# start container
docker-compose up --remove-orphans -d

# exec into container
docker attach hello

# run command inside container
python hello.py

# destroy container
docker-compose down
```

#### Docker Troubleshooting
* Watch logs in real-time: `docker-compose logs -tf --tail="50" hello`
* Check exit code
    ```bash
    $ docker-compose ps
    Name                          Command               State    Ports
    ------------------------------------------------------------------------------
    docker_python      python manage.py runserver ...   Exit 0
    ```

### Playwright
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

## TODO
* ~~Add boilerplate to hello.py~~
* ~~Poetry~~
* ~~Dockerfile~~
* ~~Playwright~~
* ~~Django~~
    * Merge with [docker_python](https://github.com/pythoninthegrass/docker_python) and put the latter on an ice float
    * ~~Break out into separate folder~~
* Flask
    * Bonus points for [Svelte](https://svelte.dev/blog/the-easiest-way-to-get-started) front-end ❤️
    * Break out into separate folder
* ~~asdf~~
* terraform
* k8s
* wsl
    * enable
    * `.wslconfig` options
    * install `ppa:deadsnakes/ppa`
    * VSCode
        * Remote WSL install and usage
            * Or at least further reading nods
* Debugging
   * `$PATH`
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

[Getting started | Playwright Python | codegen macro](https://playwright.dev/python/docs/intro)

[Set up a WSL development environment | Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)

[Advanced settings configuration in WSL | Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)

[Understanding The Python Path Environment Variable in Python](https://www.simplilearn.com/tutorials/python-tutorial/python-path)
