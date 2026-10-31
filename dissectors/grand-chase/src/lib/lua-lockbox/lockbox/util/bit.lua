-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/gcarlos64/lua-lockbox (lockbox/util/bit.lua),
-- commit 26287732d3f3fc1f2d1c701f762d2391ecb0cba0 du 05/10/2025 (sous-module lib/lua-lockbox de l'amont).
-- Licence amont : MIT (lib/lua-lockbox/LICENSE) — voir README.md.

local ok, e
ok = nil
if not ok then
    ok, e = pcall(require, "bit") -- the LuaJIT one ?
end
if not ok then
    ok, e = pcall(require, "bit32") -- Lua 5.2
end
if not ok then
    ok, e = pcall(require, "bit.numberlua") -- for Lua 5.1, https://github.com/tst2005/lua-bit-numberlua/
end
if not ok then
    e = {}
    e.bnot   = function (a) return ~a end
    e.band   = function (a, b) return a & b end
    e.bor    = function (a, b) return a | b end
    e.bxor   = function (a, b) return a ~ b end
    e.lshift = function (a, b) return a << b end
    e.rshift = function (a, b) return a >> b end

    ok = true
end
if not ok then
    error("no bitwise support found", 2)
end
assert(type(e) == "table", "invalid bit module")

-- Workaround to support Lua 5.2 bit32 API with the LuaJIT bit one
if e.rol and not e.lrotate then
    e.lrotate = e.rol
end
if e.ror and not e.rrotate then
    e.rrotate = e.ror
end

-- Workaround to support incomplete bit operations set
if not e.ror and not e.rrotate then
    local ror = function(b, n)
        return e.bor(e.rshift(b, n), e.lshift(b, 64 - n))
    end

    e.ror = ror
    e.rrotate = ror
end

if not e.rol and not e.lrotate then
    local rol = function(b, n)
        return e.bor(e.lshift(b, n), e.rshift(b, 64 - n))
    end

    e.rol = rol
    e.lrotate = rol
end

return e
