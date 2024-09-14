# ULF Development

## Packages

### ulf.test

In my Neovim configuration, I have a module to detect various setups for running
Busted tests with `Neotest`. The module was also intended to include useful
utilities like a debug printer.

This works only when using `nlua` as the Lua interpreter or by adding the
Neovim module to the Lua search path.

Solution:
Package everything in the ulf.test module as a rock, and you're good to go.

Example:

This could be `spec/init.lua`

```lua

local TestEnvironment = require("ulf.test.environment")
TestEnvironment.init()
```

## Useful Projects

- [tabular](https://github.com/hishamhm/tabular)
  Tabular representation of Lua data (pretty print for tables)
- [lume](https://github.com/rxi/lume): Lua functions geared towards game development
- [Jumper](https://github.com/Yonaba/Jumper): Graph algorithms
- [luafun](https://github.com/luafun/luafun): FPP
- [lua-log](https://github.com/moteus/lua-log): logging
- [lua-path](https://github.com/moteus/lua-path): path manipulations
- [ludash](https://github.com/luvitrocks/luadash): FPP
- [lua-stdlib](https://github.com/lua-stdlib/lua-stdlib): Lua stdlib
- [RxLua](https://github.com/bjornbytes/RxLua): Reactive Extensions for lua
- [Microlight](https://github.com/stevedonovan/Microlight):
  A little library of useful Lua functions, intended as the 'light' version of Penlight
