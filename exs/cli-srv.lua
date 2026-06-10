local s = require "atmos.env.socket"
local socket = require "socket"

loop(function ()
    local srv = assert(s.xtcp())
    assert(srv:bind("*", 0))
    s.xlisten(srv)
    local _,p = srv:getsockname()

    par_or(function ()
        local oth = assert(s.xaccept(srv))
        while true do
            local v = s.xrecv(oth)
            print('xxx', v)
        end
    end, function ()
        local cli = assert(s.xtcp())
        assert(s.xconnect(cli, "localhost", p))
        cli:send("oi")
        await(1*_s_)
        cli:send("123\n")
        await(1*_s_)
    end)
end)
