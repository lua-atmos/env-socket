# Plan: Re-release env-socket v0.2 (atmos 0.7-2)

## DONE (@ 2026-06-18) -- re-cut complete; main merged v0.2

PRIOR CUT (frozen, see bottom): env-socket v0.2 / rock
`0.2-1` was released for atmos 0.7-1. That work stands.
Since then atmos v0.7 grew BREAKING changes (shipping as
0.7-2): `every`->`loop_on`, `task()` me-accessor -> `xtask()`,
`spawn(fn)` -> `do_spawn`. This re-cuts env-socket on the new
core.

Breaking sites (scan @ 2026-06-18):
- `exs/hello.lua:6` `every(500*_ms_, ...)` -> `loop_on(...)`
- no `task()` / bare `spawn(function` -> nothing else

Rocks branch-track `v0.2` (and `dev` tracks `main`), with NO
pinned tag/commit. So pushing the fix to those branches already
serves it under the EXISTING `0.2-1` / `dev-1` -- luarocks
rebuilds from branch HEAD at install. DECISION (@ 2026-06-18):
SKIP the cosmetic `0.2-2`/`dev-2` bump + upload; no functional
gain. Just test + push `v0.2` + ff `main`.

## Steps (this re-cut)

1. [x] Migrate `exs/hello.lua`: `every(` -> `loop_on(`
2. [x] Grep clean: no `every(` / `task()` / bare `spawn(function`
3. [x] Test local (LUA_PATH): hello [x], cli-srv [x]
4. [x] Commit, push `v0.2`, ff `main`, sync
   (SKIPPED: 0.2-2/dev-2 rockspec, luarocks make/upload --
    branch-track serves the fix under existing 0.2-1/dev-1)

Outcome: `v0.2` pushed; `main` merged `v0.2` (v0.2_only=0,
main holds the `loop_on` fix via merge commits). Bump/upload
skipped by decision above.

## Downstream (no dedicated app)

env-socket has no app of its own. Its only downstream consumer
is env-iup's `exs/iup-net.lua` (depends on `atmos.env.socket`);
re-test it when migrating env-iup.

--------------------------------------------------------------

## PRIOR CUT (frozen -- atmos 0.7-1 era, for reference)

# Plan: Release env-socket v0.2 (atmos v0.7)

## STATUS (@ 2026-06-10): RELEASED (rock uploaded). Only `main`
## ff left (main is 4 behind v0.2).

Done: `init.lua` + both exs migrated to v0.7 (bare-us clock,
`_s_`/`_ms_`, `baclog`->`backlog` typo fixed); rockspecs
`0.2-1` + `-dev-1` created. Events re-keyed to string tag +
handle: `{tag='recv'|'send'|'closed', h=<sock>, v=<data>}`.
`quit`: NOT NEEDED (optional, core run.lua:372).
Pending: ff `main` to `v0.2` + push; `luarocks upload`.

`env-socket` is at `v0.1` (atmos >= 0.6).
atmos `v0.7` is released (`main`); env-sdl (`v0.2`) and
env-pico (`v0.3`) are migrated + tested and serve as reference.
This plan migrates env-socket to v0.7 and cuts a fresh `v0.2`.

VERSION: `v0.2` (first bump after `v0.1`; no v0.2 exists yet).

## Context

env-socket keys its events on the SOCKET USERDATA plus a string
selector (`'recv'`/`'send'`/`'closed'`), using MULTI-ARG
`emit`/`await`, and drives time via a manual `'clock'` emit.
v0.7 breaks all three:

- Events: `emit`/`await` are SINGLE-ARG only.
    - socket events use a STRING tag selector + handle field:
      `{tag='recv'|'send'|'closed', h=<sock>, v=<data>}`
    - `tag` stays a string (atmos idiom, readable trace);
      `h=` is the socket handle, matched by userdata equality
      via core `M.is` (run.lua:96, checked per-field at
      run.lua:621); payload rides in `v=`.
    - bonus: `await{tag='recv'}` (no `h`) wakes on ANY socket.
- Clock: emit a BARE NUMBER in microseconds (no `'clock'` tag,
  no `clock{...}`); the core `'clock'` await primitive consumes
  it. Mirror env-sdl `init.lua:97` -> `emit(dt_us)`.
    - timers in exs use constants `_us_ _ms_ _s_ _min_ _h_ _day_`.
- Env API: main body + `quit` (no `open`/`close`).
    - env-socket already has no `open`; confirm `quit` (close any
      lingering listen sockets) and keep `mode`/`step`.

## Migration map (init.lua)

| old (v0.1)                          | new (v0.7)                          |
|-------------------------------------|-------------------------------------|
| `await(srv, 'recv')`                | `await{tag='recv', h=srv}`          |
| `await(tcp, 'send')`                | `await{tag='send', h=tcp}`          |
| `local _,_,s = await(tcp, 'recv')`  | `local e = await{tag='recv', h=tcp}` then use `e.v` |
| `emit(k, 'recv')`                   | `emit{tag='recv', h=k}`             |
| `emit(k, 'recv', ok)`               | `emit{tag='recv', h=k, v=ok}`       |
| `emit(k, 'recv', s)`                | `emit{tag='recv', h=k, v=s}`        |
| `emit(k, 'closed')`                 | `emit{tag='closed', h=k}`           |
| `emit(k, 'send')`                   | `emit{tag='send', h=k}`             |
| `emit('clock', (now-old)*1000, M.now)` | `emit((now-old)*1e6)` (bare us)  |

Decisions / gotchas:

- `M.now`: keep exposing `env.now` (used by `exs/hello.lua`);
  decide unit (ms today). The bare clock emit is independent of
  `M.now`, so `now` can stay ms; just drop the 2nd/3rd emit args.
- Pre-existing bug `M.xlisten`: `tcp:listen(baclog)` typo for
  `backlog` (init.lua) -- fix while here.
- Confirm `M.xrecv`/`M.xaccept` still return the same values to
  callers after the `await` shape change.

## Migration map (examples)

| file              | old              | new          |
|-------------------|------------------|--------------|
| `exs/hello.lua`   | `clock{s=5}`     | `5 * _s_`    |
| `exs/hello.lua`   | `clock{ms=500}`  | `500 * _ms_` |
| `exs/cli-srv.lua` | `clock{s=1}`     | `1 * _s_`    |

## Steps

Two test phases (mirror env-sdl):
1. Local: `LUA_PATH` trick from README.
2. Global: `luarocks make`, then test.

1. [x] Migrate `init.lua` to v0.7 API (events table-patterns,
       bare-us clock; `quit` not needed; typo fixed)
2. [x] Migrate `exs/hello.lua`, `exs/cli-srv.lua` (`_s_`/`_ms_`)
3. [x] Update `README.md` (version block + stable `v0.2`,
       `Dependencies: atmos v0.7`, Events section re-keyed)
4. [x] Phase 1 tests (local) -- both OK after tag/h re-key
    - [x] `exs/hello.lua`
    - [x] `exs/cli-srv.lua`
5. [x] Create rockspecs: `atmos-env-socket-0.2-1.rockspec`
       (branch `v0.2`, `atmos ~> 0.7`) + `-dev-1` (branch
       `main`, unversioned `atmos`)
6. [x] Make rockspec (`luarocks make`)
7. [x] Phase 2 tests (global) -- both OK
    - [x] `exs/hello.lua`
    - [x] `exs/cli-srv.lua`
8. [x] Commit + push `v0.2` (done on branch `v0.2`)
9. [~] Version branch `v0.2` created + pushed; `main` NOT yet
       ff'd (main is 4 behind v0.2) -> `git checkout main &&
       git merge --ff-only v0.2 && git push && git checkout v0.2`
10. [x] `luarocks upload atmos-env-socket-0.2-1.rockspec`

## Reference

- atmos plan: `atmos/.claude/plans/06-08-release-v0.7.md` (§4.3)
- env-sdl (done): `env-sdl/.claude/plans/06-08-release-v0.2.md`
- env-pico (done): `env-pico/.claude/plans/done/06-08-release-v0.3.md`
- v0.7 patterns: env-sdl `init.lua` (clock `emit(dt*1000)` us;
  events `e.tag=...; emit(e)`; `M.quit`; `atmos.env(M)`)
