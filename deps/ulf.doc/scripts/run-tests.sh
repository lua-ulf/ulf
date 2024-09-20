#!/usr/bin/env zsh

#
# This script runs a Lua test based on the value of the environment variable ULF_TEST_INTERPRETER.
# If ULF_TEST_INTERPRETER is not set, it defaults to using 'nvim'.
# If BUSTED_VERSION is not set, it defaults to '2.2.0-1'.
#
# ULF_TEST_INTERPRETER can have the following values:
# - nvim: runs tests using Neovim (exec_nvim)
# - luarocks: runs tests using LuaRocks (exec_luarocks)
# - busted: runs tests using Busted (exec_busted)
#

# Default environment variables
: "${ULF_TEST_INTERPRETER:=nvim}"
: "${BUSTED_VERSION:=2.2.0-1}"

function exec_nvim {
  nvim -u NONE \
    -c "lua package.path='lua_modules/share/lua/5.1/?.lua;lua_modules/share/lua/5.1/?/init.lua;'..package.path;package.cpath='lua_modules/lib/lua/5.1/?.so;'..package.cpath;local k,l,_=pcall(require,'luarocks.loader') _=k and l.add_context('busted','$BUSTED_VERSION')" \
    -l "lua_modules/lib/luarocks/rocks-5.1/busted/$BUSTED_VERSION/bin/busted" "$@"
}

# Runs tests using LuaRocks.
# Example usage: luarocks test -- --directory=deps/ulf.lib --tags=ulf.lib
function exec_luarocks {
  luarocks test -- "$@"
}

# Runs tests using Busted.
function exec_busted {
  busted "$@"
}

# Main function that dispatches to the correct interpreter based on ULF_TEST_INTERPRETER
function main {
  case "$ULF_TEST_INTERPRETER" in
  nvim)
    exec_nvim "$@"
    ;;
  luarocks)
    exec_luarocks "$@"
    ;;
  busted)
    exec_busted "$@"
    ;;
  *)
    echo "Error: ULF_TEST_INTERPRETER has an invalid value. Please set it to 'nvim', 'luarocks', or 'busted'."
    exit 1
    ;;
  esac
}

# Execute the main function
main "$@"
