# ULF: Universal Lua Framework

`ULF` is a modular, asynchronous framework for Lua designed to provide
developers with a flexible, powerful, and intuitive API for
development in `Neovim` and `LuaJIT`. The framework sits on top `luv`
and provides the async/ await pattern by default.

## Repository Management

### Adding a Project

```sh
# 1 add remote
git remote add -f ulf-log-upstream git@github.com:lua-ulf/ulf.log.git

# 2 setup subtree
git subtree add --prefix deps/ulf.log ulf-log-upstream main --squash

# 3 push
git subtree push --prefix=deps/ulf.log ulf-log-upstream main
```
