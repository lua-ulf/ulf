SHELL := /bin/bash
ROCKS_PACKAGE_VERSION := $(shell ./.rocks-version ver)
ROCKS_PACKAGE_REVISION := $(shell ./.rocks-version rev)
APPNAME := ulf
BUSTED_VERSION := 2.2.0-1
DEPS_DIR := deps
ROCKSPECS := $(wildcard $(DEPS_DIR)/*/*scm-1.rockspec)
# ULF_DEPS := $(wildcard $(DEPS_DIR)/*)
ULF_DEPS := ulf.async ulf.core ulf.doc ulf.lib ulf.log ulf.sys ulf.test ulf.util
ULF_DEPS_NEOVIM := ulf.vim


.PHONY: build test local lint
.EXPORT_ALL_VARIABLES:

help: ## Display this help screen
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


luarocks-test-prepare: $(ROCKSPECS) ## installs all dependencies for testing
	@for rockspec in $^; do \
		echo "Testing $$rockspec"; \
		luarocks test --prepare $$rockspec; \
	done
	
luarocks-make-local: $(ROCKSPECS) ## installs all dependencies for the package
	@for rockspec in $^; do \
		echo "Testing $$rockspec"; \
		luarocks make --no-install --local $$rockspec; \
	done

	
luarocks-init: ## initializes local project
	luarocks init
	luarocks install --lua-version 5.1 busted $(BUSTED_VERSION)
	luarocks install --lua-version 5.1 busted-htest
	luarocks config --scope project lua_version 5.1


test-nvim: ## executes all test using Neovim as Lua interpreter
	@for dir in $(ULF_DEPS_NEOVIM); do \
		echo "Testing $$dir"; \
		ULF_TEST_INTERPRETER=nvim ./scripts/run-tests.sh $(DEPS_DIR)/$$dir/spec/tests; \
	done


test-lua: ## executes all test using Neovim as Lua interpreter
	echo $(ULF_DEPS) 
	@for dir in $(ULF_DEPS); do \
		echo "Testing $$dir"; \
		ULF_TEST_INTERPRETER=luarocks ./scripts/run-tests.sh --directory=$(DEPS_DIR)/$$dir; \
		ULF_TEST_INTERPRETER=nvim ./scripts/run-tests.sh $(DEPS_DIR)/$$dir/spec/tests; \
	done

test: test-nvim ## test ULF
	@echo "Testing all packages"

# nlua:
# 	@echo "installing nlua"
# 	# LUAROCKS_CONFIG=./.luarocks/config-nlua.lua luarocks install --local nlua 
#
# show-config-nlua: ## shows the luarocks nlua configuration
# 	@echo "luarocks nlua configuration"
# 	# LUAROCKS_CONFIG=./.luarocks/config-nlua.lua luarocks 
#
# test-deps: ## install test dependencies
# 	@echo "installing test dependencies"
# 	# LUAROCKS_CONFIG=./.luarocks/config-5.1.lua luarocks test --prepare $(APPNAME)-$(ROCKS_PACKAGE_VERSION)-$(ROCKS_PACKAGE_REVISION).rockspec
#
# build: ## build ULF
# 	@echo "installing rockspec dependencies"
# 	# LUAROCKS_CONFIG=./.luarocks/config-5.1.lua luarocks make --no-install --local $(APPNAME)-$(ROCKS_PACKAGE_VERSION)-$(ROCKS_PACKAGE_REVISION).rockspec

# local: build ## make local
# 	# luarocks --lua-version=5.1 make --local lua-openai-dev-1.rockspec

# lint: ## perform code linting
# 	@echo "todo"
# # test-nvim: test-deps-nvim ## run tests using nlua
# 		# ULF_TEST_INTERPRETER=nvim ./scripts/run-tests.sh deps/ulf.vim/spec/tests/ulf/vim/spawn_spec.lua 
# # 	@echo "installing tests using nlua"
# # 	# LUAROCKS_CONFIG=./.luarocks/config-nlua.lua luarocks test -- --directory=deps/ulf.lib --tags=ulf.lib
# # 	# LUAROCKS_CONFIG=./.luarocks/config-nlua.lua luarocks --lua-dir=$(HOME)/.luarocks-ulf/bin  test -- --directory=deps/ulf.vim --tags=ulf.vim
# # 	# LUAROCKS_CONFIG=./.luarocks/config-nlua.lua ./scripts/luarocks-nlua  test -- --directory=deps/ulf.vim --tags=ulf.vim
# # 	# ./scripts/luarocks-nlua  test -- --directory=deps/ulf.vim --tags=ulf.vim
# #
#
