.DEFAULT_GOAL	:= help
.ONESHELL:
export SHELL 	:= $(shell which sh)

# colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

# targets
.PHONY: all
all: build pull run up stop down psql help

build: ## build postgres image
	docker build -f Dockerfile.postgres -t some-postgres:latest .

build-py: ## build python image
	docker build -f Dockerfile -t some-python:latest .

pull: ## pull postgres image
	docker pull postgres:latest

run: ## run postgres container
	docker run --rm --name some-postgres \
		-p 5432:5432 \
		-e POSTGRES_PASSWORD=mysecretpassword \
		-d postgres:latest

up: ## docker-compose
	docker-compose up -d

exec: ## docker-compose
	docker-compose exec -it some-python bash

stop: ## docker-compose
	docker-compose stop

down: ## docker-compose
	docker-compose down

psql: ## run psql
	docker exec -it some-postgres psql -U postgres

help: ## show this help
	@echo ''
	@echo 'Usage:'
	@echo '    ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
