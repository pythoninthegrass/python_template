# python_template

!["It's dangerous to go alone! Take this."](zelda.jpg)
<!-- <img src="https://user-images.githubusercontent.com/4097471/144654508-823c6e31-5e10-404c-9f9f-0d6b9d6ce617.jpg" width="300"> -->

## Summary
Oftentimes the initial setup of a Python repo can take a few minutes to a couple hours.
By laying the foundation to rapidly implement an idea, can focus on the good bits instead of
devops drudgery.

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

# optional: local python (e.g., python 3.11)
cd $work_dir
asdf local python latest

# check installed python
asdf list python
```

### Poetry
```bash
# Install
curl -sSL https://install.python-poetry.org | $(which python3) -

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
    * Django dependencies
        ```bash
        # edit requirements.txt
        Django>=3.0,<4.0
        psycopg2>=2.8
        ```
    * Replace the `compose.yml` and `Dockerfile`
        ```bash
        # compose.yml
        version: "3.9"
   
        services:
        db:
            image: postgres
            volumes:
            - ./data/db:/var/lib/postgresql/data
            environment:
            - POSTGRES_NAME=postgres
            - POSTGRES_USER=postgres
            - POSTGRES_PASSWORD=postgres
        web:
            build: .
            command: python manage.py runserver 0.0.0.0:8000
            volumes:
            - .:/code
            ports:
            - "8000:8000"
            environment:
            - POSTGRES_NAME=postgres
            - POSTGRES_USER=postgres
            - POSTGRES_PASSWORD=postgres
            depends_on:
            - db

        # Dockerfile
        # syntax=docker/dockerfile:1
        FROM python:3
        ENV PYTHONDONTWRITEBYTECODE=1
        ENV PYTHONUNBUFFERED=1
        WORKDIR /code
        COPY requirements.txt /code/
        RUN pip install -r requirements.txt
        COPY . /code/
        ```
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

## TODO
* ~~Add boilerplate to hello.py~~
* ~~Poetry~~
* ~~Dockerfile~~
* ~~Playwright~~
* ~~Django~~
   * Merge with [docker_python](https://github.com/pythoninthegrass/docker_python) and put the latter on an ice float
* ~~asdf~~
* wsl
  * enable
  * `.wslconfig` options
* debug path / dependencies

## Further Reading
[Basic writing and formatting syntax - GitHub Docs](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

[Introduction | Documentation | Poetry - Python dependency management and packaging made easy](https://python-poetry.org/docs/)

[Commands | Documentation | Poetry - Python dependency management and packaging made easy](https://python-poetry.org/docs/cli#export)

[Overview of Docker Compose | Docker Documentation](https://docs.docker.com/compose/)

[Compose file version 3 reference | Docker Documentation](https://docs.docker.com/compose/compose-file/compose-file-v3/)

[Getting started | Playwright Python | codegen macro](https://playwright.dev/python/docs/intro)

[Set up a WSL development environment | Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/setup/environment)

[Advanced settings configuration in WSL | Microsoft Docs](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)

[Understanding The Python Path Environment Variable in Python](https://www.simplilearn.com/tutorials/python-tutorial/python-path)
