# ----------------
# This is the Makefile. It exposes all the project's affordances.
#
# If something is automated, you will find it here.
# If something should be automated, put it here.
#
# The convention for Make target names generally is "<noun>(-<verb>)"-ish,
# e.g. packaging, cluster-create or git-ensure-clean.
#
# Learn more about Makefiles:
#  * Quick reference: https://www.gnu.org/software/make/manual/html_node/Quick-Reference.html#Quick-Reference
#  * The Makefile tutorial: https://makefiletutorial.com/
#  * Make documentation: https://www.gnu.org/software/make/manual/html_node/index.html#Top
#  * Functions, variables and directives: https://www.gnu.org/software/make/manual/html_node/Name-Index.html
#
# Happy making!
# ----------------

.DEFAULT_GOAL := help

# Use Bash as the shell.
# See https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html
SHELL := bash

# Run each Make recipe as one single shell session.
# See https://www.gnu.org/software/make/manual/html_node/One-Shell.html#One-Shell
.ONESHELL:

# Run safe shell commands.
# See https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html
.SHELLFLAGS := -eu -o pipefail -c

# Remove targets if their recipes fail. This avoids corrupted or improperly built targets.
# See https://www.gnu.org/software/make/manual/html_node/Errors.html#Errors
.DELETE_ON_ERROR:
# Caveat: this only works for regular files and not for directories.
# See http://savannah.gnu.org/bugs/?func=detailitem&item_id=16372

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

VERSION ?= 0.0.0-mamachanko

.PHONY: help
help: ## Describe all make targets (default)
	@./Makefile_help.awk $(MAKEFILE_LIST)

.PHONY: release
release:
	kctrl package release \
	  --version $(VERSION) \
	  --tag $(shell echo $(VERSION) | sed s/+/_/g) \
	  --repo-output build/repository \
	  --copy-to build \
	  --yes

.PHONY: cluster-create
cluster-create:
	kind create cluster

.PHONY: kapp-controller-install
kapp-controller-install:
	kapp deploy \
	  --app kapp-controller \
		--yes \
		--diff-changes \
		--file https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml 

.PHONY: install
install: kapp-controller-install
	kapp deploy \
	  --app nginx-sample \
	  --yes \
	  --diff-changes \
	  --file build/packages \
	  --file install.yml

.PHONY: uninstall
uninstall:
	kapp delete \
	  --app nginx-sample \
	  --yes \
	  --diff-changes
