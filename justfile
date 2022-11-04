# https://just.systems/man/en

# load .env
set dotenv-load

# set env var
export APP      := "compose_image_name"
export CPU      := "2"
export IMAGE    := `echo ${REGISTRY_URL}/it
export MEM      := "2048"
export NS       := "default"
export PROF     := "minikube"
export SHELL    := "/bin/bash"
VERSION 		:= `cat VERSION`

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

# [docker] build locally
build:
	#!/usr/bin/env bash
	# set -euxo pipefail

	echo "building ${APP_NAME}:${TAG}"

	if [[ {{arch}} == "arm64" ]]; then
		docker build -f Dockerfile -t it/${APP_NAME}:${TAG} --build-arg CHIPSET_ARCH=aarch64-linux-gnu .
	else
		docker build -f Dockerfile -t it/${APP_NAME}:${TAG} --build-arg CHIPSET_ARCH=x86_64-linux-gnu .
	fi

	echo "created tag it/${APP_NAME}:${TAG} {{IMAGE}}/${APP_NAME}:${TAG}"

# TODO: QA
# [docker] intel build
buildx:
	docker buildx build -f Dockerfile --progress=plain -t ${TAG} --build-arg CHIPSET_ARCH=x86_64-linux-gnu --load .

# [docker] build w/docker-compose defaults
build-nc:
	#!/usr/bin/env bash
	# set -euxo pipefail

	if [[ {{arch}} == "arm64" ]]; then
		docker-compose build --pull --no-cache --build-arg CHIPSET_ARCH=aarch64-linux-gnu
	else
		docker-compose build --pull --no-cache --build-arg CHIPSET_ARCH=x86_64-linux-gnu
	fi

# [docker] pull latest image
pull:
	docker pull {{IMAGE}}/${APP_NAME}:${TAG}

# [docker] run local image
run: pull
	docker run -it --rm -v $(pwd):/app {{IMAGE}}/${APP_NAME}:${TAG} {{SHELL}}

# [docker] push latest image to ecr
release:
	#!/usr/bin/env bash
	# set -euxo pipefail

	AWS_DEFAULT_PROFILE=bastion.use1 aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker push {{IMAGE}}/${APP_NAME}:${TAG}

# [docker] start docker-compose container
start:
    docker-compose up -d

# [docker] ssh into container
exec:
    docker-compose exec {{APP}} {{SHELL}}

# [docker] stop docker-compose container
stop:
    docker-compose stop

# [docker] remove docker-compose container(s) and networks
down: stop
	docker-compose down --remove-orphans

# [docker] tag image as latest
tag-latest:
	@echo "create tag it/${APP_NAME}:${TAG} {{IMAGE}}/${APP_NAME}:${TAG}"
	docker tag it/${APP_NAME}:${TAG} {{IMAGE}}/${APP_NAME}:${TAG}

# TODO: QA
# [docker] tag image from VERSION file
tag-version:
	@echo "create tag it/${APP_NAME}:{{VERSION}} {{IMAGE}}/${APP_NAME}:${TAG}"
	docker tag it/${APP_NAME}:{{VERSION}} {{IMAGE}}/${APP_NAME}:${TAG}
