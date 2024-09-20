#!/bin/bash

# Base directory
BASE="$HOME/dev/projects/ulf"

# dirs=("async" "core" "doc" "lib" "log" "sys" "test" "vim")

# Initialize the LUA_PATH variable
LUA_PATH=""

# Add Lua paths for each directory
# for dir in "${dirs[@]}"; do
#   LUA_PATH="$LUA_PATH;$BASE/deps/ulf.$dir/lua/?.lua;$BASE/deps/ulf.$dir/lua/?/init.lua"
# done

LUA_PATH="$LUA_PATH;/Users/al/dev/projects/?/init.lua;"
LUA_PATH="$LUA_PATH;$BASE/lua/?.lua;$BASE/lua/?/init.lua;"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.async/lua/?.lua;$BASE/deps/ulf.async/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.core/lua/?.lua;$BASE/deps/ulf.core/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.doc/lua/?.lua;$BASE/deps/ulf.doc/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.lib/lua/?.lua;$BASE/deps/ulf.lib/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.log/lua/?.lua;$BASE/deps/ulf.log/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.luvit/lua/?.lua;$BASE/deps/ulf.luvit/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.sys/lua/?.lua;$BASE/deps/ulf.sys/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.test/lua/?.lua;$BASE/deps/ulf.test/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.util/lua/?.lua;$BASE/deps/ulf.util/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/deps/ulf.vim/lua/?.lua;$BASE/deps/ulf.vim/lua/?/init.lua"
LUA_PATH="$LUA_PATH;$BASE/../?/init.lua"
# Export LUA_PATH in Luarocks-style
echo "export LUA_PATH='$LUA_PATH'"
