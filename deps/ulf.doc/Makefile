# Test Makefile for ULF
#
# TODO:
# - targets luarocks-make-local and luarocks-test-prepare should only be
#   run once
# - add a clean target to remove all rocks and start cleanly
#

SHELL := /bin/bash
ROCKS_PACKAGE_VERSION := $(shell ./.rocks-version ver)
ROCKS_PACKAGE_REVISION := $(shell ./.rocks-version rev)
APPNAME := ulf.doc
BUSTED_VERSION := 2.2.0-1
TMP_DIR := .tmp

LUAROCKS_INIT ?= $(TMP_DIR)/luarocks-init
LUAROCKS_DEPS ?= $(TMP_DIR)/luarocks-deps
LUAROCKS_TEST_PREPARE ?= $(TMP_DIR)/luarocks-test-prepare
LUAROCKS_MAKE_LOCAL ?= $(TMP_DIR)/luarocks-make-local
TEST_DEPS ?= $(TMP_DIR)/test-deps
BUSTED_TAG ?= default

.PHONY: build test local lint luarocks-make-local luarocks-test-prepare luarocks-init test-deps clean
.EXPORT_ALL_VARIABLES:

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: deps

deps: | $(TEST_DEPS)

$(LUAROCKS_INIT): | $(TMP_DIR) ## Initializes local project
	luarocks init
	luarocks install --lua-version 5.1 busted $(BUSTED_VERSION)
	luarocks install --lua-version 5.1 busted-htest
	luarocks config --scope project lua_version 5.1
	@touch $(TMP_DIR)/luarocks-init

# Ensure luarocks-test-prepare is only run once
$(LUAROCKS_TEST_PREPARE): | $(LUAROCKS_INIT) ## Installs all dependencies for testing (runs once)
	LUAROCKS_CONFIG=./.luarocks/config-5.1.lua luarocks test --prepare $(APPNAME)-$(ROCKS_PACKAGE_VERSION)-$(ROCKS_PACKAGE_REVISION).rockspec && \
	touch $(TMP_DIR)/luarocks-test-prepare

$(LUAROCKS_MAKE_LOCAL): | $(LUAROCKS_INIT)  ## Installs all dependencies for the package (runs once)
	LUAROCKS_CONFIG=./.luarocks/config-5.1.lua luarocks make --no-install --local $(APPNAME)-$(ROCKS_PACKAGE_VERSION)-$(ROCKS_PACKAGE_REVISION).rockspec && \
	touch $(TMP_DIR)/luarocks-make-local

$(LUAROCKS_DEPS): | $(LUAROCKS_TEST_PREPARE) $(LUAROCKS_MAKE_LOCAL)
	@touch $(TMP_DIR)/luarocks-deps

$(TEST_DEPS): | $(LUAROCKS_DEPS)
	@touch $(TMP_DIR)/test-deps

test-nvim: | $(TEST_DEPS) ## Executes all tests using Neovim as Lua interpreter
	LUAROCKS_CONFIG=./.luarocks/config-5.1.lua ULF_TEST_INTERPRETER=nvim ./scripts/run-tests.sh spec/tests

test-lua: | $(TEST_DEPS) ## Executes all tests using LuaJIT and Neovim as Lua interpreter
	LUAROCKS_CONFIG=./.luarocks/config-5.1.lua ./scripts/run-tests.sh spec/tests

test: test-nvim test-lua ## Test all ULF packages
	@echo "Testing all modules"

clean: ## Clean up all rocks and reset the environment
	@echo "Cleaning up rocks and local installations..."
	rm -f $(TMP_DIR)/*
	rmdir $(TMP_DIR)
	LUAROCKS_CONFIG=./.luarocks/config-5.1.lua luarocks purge

$(TMP_DIR):
	@mkdir -p $(TMP_DIR)

