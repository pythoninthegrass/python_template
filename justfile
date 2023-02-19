# https://just.systems/man/en

# load .env
set dotenv-load

# set env var
export APP      := `echo ${APP_NAME}`
export CPU      := "2"
export IMAGE	:= `echo ${IMAGE}`
export MEM      := "2048"
export NS       := "default"
export PROF     := "minikube"
export SHELL    := "/bin/bash"
export SCRIPT   := "harden"
export SHELL	:= "/bin/bash"
export TAG		:= `echo ${TAG}`
VERSION 		:= `cat VERSION`

# x86_64/arm64
arch := `uname -m`

# hostname
host := `uname -n`

# [halp] list available commands
default:
    just --list

# TODO: setup tilt
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

# docker-compose / docker compose
# * https://docs.docker.com/compose/install/linux/#install-using-the-repository
docker-compose := if `command -v docker-compose; echo $?` == "0" {
	"docker-compose"
} else {
	"docker compose"
}

# [halp]   list available commands
default:
	just --list

# [check]  lint sh script
checkbash:
	#!/usr/bin/env bash
	checkbashisms {{SCRIPT}}
	if [[ $? -eq 1 ]]; then
		echo "bashisms found. Exiting..."
		exit 1
	else
		echo "No bashisms found"
	fi

# [docker] build locally or on intel box
build: checkbash
	#!/usr/bin/env bash
	set -euxo pipefail
	if [[ {{arch}} == "arm64" ]]; then
		docker build -f Dockerfile -t {{APP}} --build-arg CHIPSET_ARCH=aarch64-linux-gnu .
	else
		docker build -f Dockerfile --progress=plain -t {{APP}} .
	fi

# [docker] arm build w/docker-compose defaults
build-clean: checkbash
	#!/usr/bin/env bash
	set -euxo pipefail
	if [[ {{arch}} == "arm64" ]]; then
		{{docker-compose}} build --pull --no-cache --build-arg CHIPSET_ARCH=aarch64-linux-gnu --parallel
	else
		{{docker-compose}} build --pull --no-cache --parallel
	fi

# [docker] login to registry (exit code 127 == 0)
login:
	#!/usr/bin/env bash
	# set -euxo pipefail
	echo "Log into ${REGISTRY_URL} as ${USER_NAME}. Please enter your password: "
	cmd=$(docker login --username ${USER_NAME} ${REGISTRY_URL})
	if [[ $("$cmd" >/dev/null 2>&1; echo $?) -ne 127 ]]; then
		echo 'Not logged into Docker. Exiting...'
		exit 1
	fi

# [docker] tag image as latest
tag-latest:
	docker tag {{APP}}:latest {{IMAGE}}/{{APP}}:latest

# [docker] tag latest image from VERSION file
tag-version:
	@echo "create tag {{APP}}:{{VERSION}} {{IMAGE}}/{{APP}}:{{VERSION}}"
	docker tag {{APP}} {{IMAGE}}/{{APP}}:{{VERSION}}

# [docker] push latest image
push: login
	docker push {{IMAGE}}/{{APP}}:{{TAG}}

# [docker] pull latest image
pull: login
	docker pull {{IMAGE}}/{{APP}}

# [docker] run container
run: build
	#!/usr/bin/env bash
	# set -euxo pipefail
	docker run --rm -it \
		--name {{APP}} \
		--env-file .env \
		--entrypoint={{SHELL}} \
		-h ${HOST:-localhost} \
		-v $(pwd)/conf:/etc/duoauthproxy \
		-p ${PORT:-1812}:${PORT:-1812/udp} \
		-p ${PORT2:-18120}:${PORT2:-18120/udp} \
		--cap-drop=all \
		--cap-add=setgid \
		--cap-add=setuid \
		{{APP}}

# [docker] start docker-compose container
up: build
	{{docker-compose}} up -d

# [docker] get running container logs
logs:
	{{docker-compose}} logs -tf --tail="50" {{APP}}

# [docker] ssh into container
exec:
	docker exec -it {{APP}} {{SHELL}}

# [docker] stop docker-compose container
stop:
	{{docker-compose}} stop

# [docker] remove docker-compose container(s) and networks
down: stop
	{{docker-compose}} down --remove-orphans
