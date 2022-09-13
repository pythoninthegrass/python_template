### Docker

* Install from the [Setup](../README.md#setup) section
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

#### Debugging
* Watch logs in real-time: `docker-compose logs -tf --tail="50" hello`
* Check exit code
    ```bash
    $ docker-compose ps
    Name                          Command               State    Ports
    ------------------------------------------------------------------------------
    docker_python      python manage.py runserver ...   Exit 0
    ```
