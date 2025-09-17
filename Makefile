# Sane defaults
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ---------------------- COMMANDS ---------------------------

build: # Build the Docker test image (minimal Debian)
	@echo "Building Docker test image.."
	docker build -t zshrc-test .

run: # Run the zshrc test container (minimal Debian)
	@echo "Starting zshrc test container.."
	docker run -it --rm -v "$(shell pwd)":/home/testuser/Projects/dotfiles zshrc-test

test: # Run automated tests in container (minimal Debian)
	@echo "Running zshrc tests.."
	docker run --rm -v "$(shell pwd)":/home/testuser/Projects/dotfiles zshrc-test /bin/zsh -c "ln -sf \$$DOTFILES_HOME/zsh/zshrc ~/.zshrc && source ~/.zshrc && source /home/testuser/Projects/dotfiles/zsh/test.zsh"

build-core: # Build the Arch Linux test image (core)
	@echo "Building Arch Linux test image.."
	docker build -f Dockerfile.core -t zshrc-test-core .

run-core: # Run the Arch Linux test container (core)
	@echo "Starting Arch Linux test container.."
	docker run -it --rm -v "$(shell pwd)":/home/testuser/Projects/dotfiles zshrc-test-core

test-core: # Run automated tests in Arch container (core)
	@echo "Running core Arch Linux tests.."
	docker run --rm -v "$(shell pwd)":/home/testuser/Projects/dotfiles zshrc-test-core /bin/zsh -c "source ~/.zshrc && source \$$DOTFILES_HOME/zsh/test-core.zsh"

test-all: # Run both minimal and core tests
	@echo "Running all tests.."
	make test
	make test-core

lint: # Run shellcheck on all shell files and ruff on Python files
	@echo "Running shellcheck on shell files.."
	find . -name "*.sh" -o -path "./river/init" | grep -v ".git" | grep -v "scratch" | grep -v ".venv" | xargs shellcheck
	@echo "Running ruff on Python files.."
	cd whisper && uv run ruff check .

format: # Format Python files with black
	@echo "Formatting Python files with black.."
	cd whisper && uv run black .

check-secret: # Check file or directory for secrets using gitleaks (Usage: make check-secret TARGET=path)
	@if [ -z "$(TARGET)" ]; then \
		echo "Usage: make check-secret TARGET=/path/to/file/or/directory"; \
		exit 1; \
	fi
	@echo "Checking $(TARGET) for secrets.."
	gitleaks dir -v --redact $(TARGET)

# -----------------------------------------------------------
# CAUTION: If you have a file with the same name as make
# command, you need to add it to .PHONY below, otherwise it
# won't work. E.g. `make run` wouldn't work if you have
# `run` file in pwd.
.PHONY: help

# -----------------------------------------------------------
# -----       (Makefile helpers and decoration)      --------
# -----------------------------------------------------------

.DEFAULT_GOAL := help
# check https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
NC = \033[0m
ERR = \033[31;1m
TAB := '%-20s' # Increase if you have long commands

# tput colors
red := $(shell tput setaf 1)
green := $(shell tput setaf 2)
yellow := $(shell tput setaf 3)
blue := $(shell tput setaf 4)
cyan := $(shell tput setaf 6)
cyan80 := $(shell tput setaf 86)
grey500 := $(shell tput setaf 244)
grey300 := $(shell tput setaf 240)
bold := $(shell tput bold)
underline := $(shell tput smul)
reset := $(shell tput sgr0)

help:
	@printf '\n'
	@printf '    $(underline)Available make commands:$(reset)\n\n'
	@# Print commands with comments
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:.+#.+$$' $(MAKEFILE_LIST) \
		| grep -v '^env-' \
		| grep -v '^arg-' \
		| sed 's/:.*#/: #/g' \
		| awk 'BEGIN {FS = "[: ]+#[ ]+"}; \
		{printf "    make $(bold)$(TAB)$(reset) # %s\n", \
			$$1, $$2}'
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:( +\w+-\w+)*$$' $(MAKEFILE_LIST) \
		| grep -v help \
		| awk 'BEGIN {FS = ":"}; \
		{printf "    make $(bold)$(TAB)$(reset)\n", \
			$$1}' || true
	@echo -e ""