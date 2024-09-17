# ULF: Universal Lua Framework

`ULF` is a lightweight, modular library for `Lua`, `LuaJIT`, and `Neovim`,
offering useful modules for common development tasks. The goal of `ULF` is to
provide versatile modules that can be used across various environments, whether
in `Neovim` or standard `Lua`, without imposing any specific constraints or
dependencies.

`ULF` is a library for `Lua`, `LuaJIT`, and `Neovim`, providing modules common development tasks.


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
