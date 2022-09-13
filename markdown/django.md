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
