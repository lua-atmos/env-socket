# atmos-env-socket

An [Atmos][atmos] environment for network communications based on
[luasocket][luasocket].

[atmos]:      https://github.com/lua-atmos/atmos/
[luasocket]:  https://lunarmodules.github.io/luasocket/

[
    [`v0.2`](https://github.com/lua-atmos/env-socket/tree/v0.2)  |
    [`v0.1`](https://github.com/lua-atmos/env-socket/tree/v0.1)
]

Stable branch is [`v0.2`](https://github.com/lua-atmos/env-socket/tree/v0.2).

# Install

```
sudo luarocks --lua-version=5.4 install atmos-env-socket
```

Dependencies: `luasocket`, `atmos v0.7`

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

- clock: bare-number microseconds (core `'clock'` primitive)
- socket events: `{ tag='recv'|'send'|'closed', h=<sock>, v=<data> }`
    - `await{ tag='recv', h=sock }` -- this socket
    - `await{ tag='recv' }` -- any socket

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
