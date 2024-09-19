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
APPNAME := ulf
BUSTED_VERSION := 2.2.0-1
DEPS_DIR := deps
ROCKSPECS := $(wildcard $(DEPS_DIR)/*/*scm-1.rockspec)
TMP_DIR := .tmp

LUAROCKS_INIT ?= $(TMP_DIR)/luarocks-init
LUAROCKS_DEPS ?= $(TMP_DIR)/luarocks-deps
LUAROCKS_TEST_PREPARE ?= $(TMP_DIR)/luarocks-test-prepare
LUAROCKS_MAKE_LOCAL ?= $(TMP_DIR)/luarocks-make-local
TEST_DEPS ?= $(TMP_DIR)/test-deps
BUSTED_TAG ?= default

# Target packages
#
# TODO:
# - Each package should have its own test setup, including
#   Makefile and test scripts
# - Iterate over packages and call local test
# - ULF_DEPS_TODO is just a reminder variable
#
ULF_DEPS_TODO := ulf.async ulf.core ulf.doc ulf.lib ulf.log ulf.sys ulf.test ulf.util
# Packages tested with LuaJIT and Neovim
ULF_DEPS := ulf.lib ulf.core ulf.doc
# Packages tested with Neovim only
ULF_DEPS_NEOVIM := ulf.vim


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
$(LUAROCKS_TEST_PREPARE): $(ROCKSPECS) | $(LUAROCKS_INIT) ## Installs all dependencies for testing (runs once)
	@for rockspec in $^; do \
		echo "Preparing test for $$rockspec"; \
		luarocks test --prepare $$rockspec; \
	done
	@touch $(TMP_DIR)/luarocks-test-prepare

$(LUAROCKS_MAKE_LOCAL): $(ROCKSPECS) | $(LUAROCKS_INIT)  ## Installs all dependencies for the package (runs once)
	@for rockspec in $^; do \
		echo "Installing locally for $$rockspec"; \
		luarocks make --no-install --local $$rockspec; \
	done
	@touch $(TMP_DIR)/luarocks-make-local

$(LUAROCKS_DEPS): | $(LUAROCKS_TEST_PREPARE) $(LUAROCKS_MAKE_LOCAL)
	@touch $(TMP_DIR)/luarocks-deps

$(TEST_DEPS): | $(LUAROCKS_DEPS)
	@touch $(TMP_DIR)/test-deps

test-nvim: | $(TEST_DEPS) ## Executes all tests using Neovim as Lua interpreter
	@for dir in $(ULF_DEPS_NEOVIM); do \
		echo "Testing Neovim-specific package: $$dir"; \
		ULF_TEST_INTERPRETER=nvim ./scripts/run-tests.sh $(DEPS_DIR)/$$dir/spec/tests; \
	done

test-ulf: | $(TEST_DEPS) ## Executes all API tests
	ULF_TEST_INTERPRETER=luarocks ./scripts/run-tests.sh --run=$(BUSTED_TAG) spec/tests


test-lua: | $(TEST_DEPS) ## Executes all tests using LuaJIT and Neovim as Lua interpreter
	@for dir in $(ULF_DEPS); do \
		echo "Testing LuaJIT/Neovim package: $$dir"; \
		ULF_TEST_INTERPRETER=luarocks ./scripts/run-tests.sh --directory=$(DEPS_DIR)/$$dir; \
		ULF_TEST_INTERPRETER=nvim ./scripts/run-tests.sh $(DEPS_DIR)/$$dir/spec/tests; \
	done

test: test-nvim test-lua ## Test all ULF packages
	@echo "Testing all packages"

clean: ## Clean up all rocks and reset the environment
	@echo "Cleaning up rocks and local installations..."
	rm -f $(TMP_DIR)/*
	rmdir $(TMP_DIR)
	# luarocks remove --force $(APPNAME) || true
	# rm -rf $(DEPS_DIR)/*/luarocks || true

$(TMP_DIR):
	@mkdir -p $(TMP_DIR)

