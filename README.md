# atmos-env-socket

An [Atmos][atmos] environment for network communications based on
[luasocket][luasocket].

[atmos]:      https://github.com/lua-atmos/atmos/
[luasocket]:  https://lunarmodules.github.io/luasocket/

# Install

```
sudo luarocks --lua-version=5.4 install atmos-env-socket
```

# Run

```
lua5.4 <lua-path>/atmos/env/socket/exs/cli-srv.lua
```

# Functions

- `xtcp ()`
- `xlisten (tcp, backlog)`
- `xaccept (srv)`
- `xconnect (tcp, addr, port)`
- `xrecv (tcp)`

# Events

- `clock`
- `'closed'`

# Source

Assumes this directory structure:

```
.
├── atmos/
├── env-socket/
└── f-streams/
```

```bash
LUA_PATH="../f-streams/?/init.lua;../atmos/?.lua;../atmos/?/init.lua;;" lua5.4 exs/cli-srv.lua
```
