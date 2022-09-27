# See https://just.systems/man/en

dotenv-load := "true"
host := `uname -a`

default:
    just --list

build-clean:
    docker-compose build --pull --no-cache

build:
    docker-compose build --pull

start:
    docker-compose up -d

exec:
    docker-compose exec app bash

stop:
    docker-compose stop

down:
    docker-compose stop && docker-compose down --remove-orphans
