# TODO: debug why it immediately crashes current terminal on macOS

.DEFAULT_GOAL	:= help
SHELL 			:= $(shell which bash)
UNAME 			:= $(shell uname -s)

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all

all: check help homebrew just install xcode

check:  ## verify running on macOS
	@echo "Verifying macOS..."
	$(shell [[ "${UNAME}" != "Darwin" ]] && echo "Not running on macOS"; exit 1)
	@echo "Success!"

xcode:  check ## install xcode command line tools
	@echo "Installing Xcode command line tools..."
	$(shell xcode-select --install)

homebrew:  check ## install homebrew
	@echo "Installing Homebrew..."
	$(shell /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

just:  check ## install justfile
	@echo "Installing Justfile..."
	$(shell brew install just)

install: xcode homebrew just  ## install all dependencies

help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '    ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
