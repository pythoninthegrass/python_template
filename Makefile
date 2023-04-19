.DEFAULT_GOAL	:= help
# TODO: test oneshell target (https://www.gnu.org/software/make/manual/html_node/One-Shell.html)
.ONESHELL:
export SHELL 	:= $(shell which sh)
# .SHELLFLAGS 	:= -eu -o pipefail -c
# MAKEFLAGS 		+= --warn-undefined-variables

# ENV VARS
export UNAME 	:= $(shell uname -s)

ifeq ($(UNAME), Darwin)
	export XCODE := $(shell xcode-select --install >/dev/null 2>&1; echo $$?)
endif

ifeq ($(UNAME), Darwin)
	export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK := 1
endif

ifeq ($(shell command -v brew >/dev/null 2>&1; echo $$?), 0)
	export BREW := $(shell which brew)
endif

ifeq ($(shell command -v python >/dev/null 2>&1; echo $$?), 0)
	export PYTHON := $(shell which python3)
endif

ifeq ($(shell command -v pip >/dev/null 2>&1; echo $$?), 0)
	export PIP := $(shell which pip3)
endif

ifeq ($(shell command -v ansible >/dev/null 2>&1; echo $$?), 0)
	export ANSIBLE := $(shell which ansible)
endif

ifeq ($(shell command -v ansible-lint >/dev/null 2>&1; echo $$?), 0)
	export ANSIBLE_LINT := $(shell which ansible-lint)
endif

ifneq (,$(wildcard /etc/os-release))
	include /etc/os-release
endif

# colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

# targets
.PHONY: all
all: ansible ansible-galaxy sanity-check git help homebrew just install mpr update xcode

# * cf. `distrobox create --name i-use-arch-btw --image archlinux:latest && distrobox enter i-use-arch-btw`
# * || `distrobox create --name debby --image debian:stable && distrobox enter debby`

sanity-check:  ## output environment variables
	@echo "Checking environment..."
	@echo "UNAME: ${UNAME}"
	@echo "SHELL: ${SHELL}"
	@echo "ID: ${ID}"
	@echo "XCODE: ${XCODE}"
	@echo "BREW: ${BREW}"
	@echo "HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK: ${HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK}"
	@echo "PYTHON: ${PYTHON}"
	@echo "PIP: ${PIP}"

xcode: ## install xcode command line tools
	if [ "${UNAME}" = "Darwin" ]; then \
		echo "Installing Xcode command line tools..."; \
		[ "${XCODE}" -ne 1 ] && xcode-select --install; \
	fi

homebrew: ## install homebrew
	if [ "${UNAME}" = "Darwin" ] && [ -z "${BREW}" ]; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

update: ## update package manager
	@echo "Updating package manager..."
	if [ "${UNAME}" = "Darwin" ] && [ "$(command -v brew >/dev/null 2>&1; echo $?)" -eq 0 ]; then \
		brew update; \
	elif [ "${ID}" = "ubuntu" ]; then \
		sudo apt update; \
	elif [ "${ID}" = "fedora" ]; then \
		sudo dnf update; \
	elif [ "${ID}" = "arch" ]; then \
		yes | sudo pacman -Syu; \
	fi

git: ## install git
	@echo "Installing Git..."
	if [ "${UNAME}" = "Darwin" ] && [ "$(command -v brew >/dev/null 2>&1; echo $?)" -eq 0 ]; then \
		brew install git; \
	elif [ "${ID}" = "ubuntu" ]; then \
		sudo apt install -y git; \
	elif [ "${ID}" = "fedora" ]; then \
		sudo dnf install -y git; \
	elif [ "${ID}" = "arch" ]; then \
		yes | sudo pacman -S git; \
	fi

python: ## install python
	@echo "Installing Python..."
	if [ "${UNAME}" = "Darwin" ] && [ -z "${PYTHON}" ]; then \
		brew install python; \
	elif [ "${ID}" = "ubuntu" ]; then \
		sudo apt install -y python3; \
	elif [ "${ID}" = "fedora" ]; then \
		sudo dnf install -y python3; \
	elif [ "${ID}" = "arch" ]; then \
		yes | sudo pacman -S python; \
	fi

pip: python ## install pip
	@echo "Installing Pip..."
	if [ "${UNAME}" = "Darwin" ] && [ -z "${PYTHON})" ]; then \
		brew install python; \
	elif [ "${ID}" = "ubuntu" ] && [ -z "${PIP}" ]; then \
		sudo apt install -y python3-pip; \
	elif [ "${ID}" = "fedora" ] && [ -z "${PIP}" ]; then \
		sudo dnf install -y python3-pip; \
	elif [ "${ID}" = "arch" ] && [ -z "${PIP}" ]; then \
		yes | sudo pacman -S python-pip; \
	fi \

ansible: pip ## install ansible
	@echo "Installing Ansible..."
	if [ "${UNAME}" = "Darwin" ]; then \
		brew install ansible ansible-lint; \
	else \
		python3 -m pip install ansible ansible-lint; \
		sudo touch /var/log/ansible.log; \
		sudo chmod 666 /var/log/ansible.log; \
	fi

ansible-galaxy: ansible git ## install ansible galaxy roles
	@echo "Installing Ansible Galaxy roles..."
	curl https://raw.githubusercontent.com/pythoninthegrass/framework/master/requirements.yml -o /tmp/requirements.yml; \
	if [ "${UNAME}" = "Darwin" ]; then \
		ansible-galaxy install -r /tmp/requirements.yml; \
	elif [ "${UNAME}" = "Linux" ]; then \
		~/.local/bin/ansible-galaxy install -r /tmp/requirements.yml; \
	fi

# TODO: "/usr/bin/sh: 3: [: =: unexpected operator" `ne` and `!=` operators don't work (╯°□°）╯︵ ┻━┻
mpr: ## install the makedeb package repo (mpr) for prebuilt packages
	@echo "Installing the makedeb package repo (mpr)..."
	if [ "${ID}" = "ubuntu" ]; then \
		[ $(command -v wget >/dev/null 2>&1; echo $?) = 0 ] || sudo apt install -y wget; \
		wget -qO - 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | sudo tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null; \
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/prebuilt-mpr.list; \
	fi; \

just: mpr update## install justfile
	@echo "Installing Justfile..."
	if [ "${UNAME}" = "Darwin" ]; then \
		brew install just; \
	elif [ "${ID}" = "ubuntu" ]; then \
		sudo apt install -y just; \
	elif [ "${ID}" = "fedora" ]; then \
		sudo dnf install -y just; \
	elif [ "${ID}" = "arch" ]; then \
		yes | sudo pacman -S just; \
	fi

install: sanity-check update xcode homebrew git python pip ansible ansible-galaxy mpr just  ## install all dependencies

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
