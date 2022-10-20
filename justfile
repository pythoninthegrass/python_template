# See https://just.systems/man/en

# positional args
# * NOTE: unable to reuse recipe name (e.g., start/stop); prefix recipes with `@`
# set positional-arguments := true

# load .env
set dotenv-load := true

# set env var
export APP   := "compose_image_name"
export CPU   := "2"
export MEM   := "2048"
export NS    := "default"
export PROF  := "minikube"
export SHELL := "/bin/bash"
export TAG   := "latest"

# x86_64/arm64
arch := `uname -m`

# hostname
host := `uname -n`

# [halp] list available commands
default:
    just --list

# [devspace] start minikube + devspace
start-devspace:
    #!/usr/bin/env bash
    set -euxo pipefail

    if [[ $(minikube status -f \{\{\.Host\}\}) = 'Stopped' ]]; then
        minikube start --memory={{MEM}} --cpus={{CPU}} -p {{PROF}}
    fi

    devspace use namespace {{NS}}
    devspace dev

# [devspace] stop minikube
stop-devspace:
    minikube stop -p {{PROF}}

# [docker] build locally or on intel box
build:
    #!/usr/bin/env bash
    set -euxo pipefail

    if [[ {{arch}} == "arm64" ]]; then
        docker build -f Dockerfile -t {{APP}}:{{TAG}} --build-arg CHIPSET_ARCH=aarch64-linux-gnu .
    else
        docker buildx build -f Dockerfile --progress=plain -t {{APP}}:{{TAG}} --build-arg CHIPSET_ARCH=x86_64-linux-gnu --load .
    fi

# [docker] intel build
buildx:
    docker buildx build -f Dockerfile --progress=plain -t $TAG --build-arg CHIPSET_ARCH=x86_64-linux-gnu --load .

# [docker] build w/docker-compose defaults
build-clean:
    #!/usr/bin/env bash
    set -euxo pipefail

    if [[ {{arch}} == "arm64" ]]; then
        docker-compose build --pull --no-cache --build-arg CHIPSET_ARCH=aarch64-linux-gnu
    else
        docker-compose build --pull --no-cache --build-arg CHIPSET_ARCH=x86_64-linux-gnu
    fi

# [docker] pull latest image
pull:
    docker pull python:3.10-slim-buster

# [docker] start docker-compose container
up:
    docker-compose up -d

# [docker] ssh into container
exec:
    docker-compose exec {{APP}} {{SHELL}}

# [docker] stop docker-compose container
stop:
    docker-compose stop

# [docker] remove docker-compose container(s) and networks
down:
    docker-compose stop && docker-compose down --remove-orphans
