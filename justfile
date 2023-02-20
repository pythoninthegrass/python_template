# See https://just.systems/man/en

# positional args
# * NOTE: unable to reuse recipe name (e.g., start/stop); prefix recipes with `@`
# set positional-arguments := true

# load .env
set dotenv-load

# set env var
export APP      := `echo ${APP}`
export CPU      := `echo ${CPU}`
export IMAGE    := `echo ${IMAGE}`
export MEM      := `echo ${MEM}`
export NS       := `echo ${NS}`
export PROF     := `echo ${PROF}`
export SCRIPT   := "harden"
export SHELL    := `echo ${SHELL}`
export TAG      := `echo ${TAG}`
export VERSION  := "latest"

# x86_64/arm64
arch := `uname -m`

# hostname
host := `uname -n`

# docker-compose / docker compose
# * https://docs.docker.com/compose/install/linux/#install-using-the-repository
docker-compose := if `command -v docker-compose; echo $?` == "0" {
	"docker-compose"
} else {
	"docker compose"
}

# [halp]     list available commands
default:
    just --list

# [git]      update git submodules
sub:
    git submodule update --init --recursive && git pull --recurse-submodules

# [minikube] start minikube + tilt
start-minikube:
    #!/usr/bin/env bash
    set -euxo pipefail
    if [[ $(minikube status -f \{\{\.Host\}\}) = 'Stopped' ]]; then
        minikube start --memory={{MEM}} --cpus={{CPU}} -p {{PROF}}
    fi

# [tilt]     deploy docker image to local k8s cluster
tilt-up: start-minikube
    tilt up

# [minikube] stop minikube
stop-minikube:
    minikube stop -p {{PROF}}

# [check]    lint sh script
checkbash:
	#!/usr/bin/env bash
	checkbashisms {{SCRIPT}}
	if [[ $? -eq 1 ]]; then
		echo "bashisms found. Exiting..."
		exit 1
	else
		echo "No bashisms found"
	fi

# [docker]   build locally
build: checkbash
	#!/usr/bin/env bash
	set -euxo pipefail
	if [[ {{arch}} == "arm64" ]]; then
		docker build -f Dockerfile -t {{APP}} --build-arg CHIPSET_ARCH=aarch64-linux-gnu .
	else
		docker build -f Dockerfile --progress=plain -t {{APP}} .
	fi

# [docker] intel build
buildx: checkbash
	docker buildx build -f Dockerfile --progress=plain -t ${TAG} --build-arg CHIPSET_ARCH=x86_64-linux-gnu --load .

# [docker]   arm build w/docker-compose defaults
build-clean: checkbash
	#!/usr/bin/env bash
	set -euxo pipefail
	if [[ {{arch}} == "arm64" ]]; then
		{{docker-compose}} build --pull --no-cache --build-arg CHIPSET_ARCH=aarch64-linux-gnu --parallel
	else
		{{docker-compose}} build --pull --no-cache --parallel
	fi

# [docker]   login to registry (exit code 127 == 0)
login:
	#!/usr/bin/env bash
	# set -euxo pipefail
	echo "Log into ${REGISTRY_URL} as ${USER_NAME}. Please enter your password: "
	cmd=$(docker login --username ${USER_NAME} ${REGISTRY_URL})
	if [[ $("$cmd" >/dev/null 2>&1; echo $?) -ne 127 ]]; then
		echo 'Not logged into Docker. Exiting...'
		exit 1
	fi

# [docker]   tag image as latest
tag-latest:
	docker tag {{APP}}:latest {{IMAGE}}/{{APP}}:latest

# [docker]   tag latest image from VERSION file
tag-version:
	@echo "create tag {{APP}}:{{VERSION}} {{IMAGE}}/{{APP}}:{{VERSION}}"
	docker tag {{APP}} {{IMAGE}}/{{APP}}:{{VERSION}}

# [docker]   push latest image
push: login
	docker push {{IMAGE}}/{{APP}}:{{TAG}}

# [docker]   pull latest image
pull: login
	docker pull {{IMAGE}}/{{APP}}

# [docker]   run container
run: build
	#!/usr/bin/env bash
	# set -euxo pipefail
	docker run --rm -it \
		--name {{APP}} \
		--env-file .env \
		--entrypoint={{SHELL}} \
		-h ${HOST:-localhost} \
		-v $(pwd)/app:/app \
		{{APP}}

# [docker]   start docker-compose container
up: build
	{{docker-compose}} up -d

# [docker]   get running container logs
logs:
	{{docker-compose}} logs -tf --tail="50" {{APP}}

# [docker]   ssh into container
exec:
	docker exec -it {{APP}} {{SHELL}}

# [docker]   stop docker-compose container
stop:
	{{docker-compose}} stop

# [docker]   remove docker-compose container(s) and networks
down: stop
	{{docker-compose}} down --remove-orphans
