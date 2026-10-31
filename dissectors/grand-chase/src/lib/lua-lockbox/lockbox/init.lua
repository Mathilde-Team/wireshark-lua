-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/gcarlos64/lua-lockbox (lockbox/init.lua),
-- commit 26287732d3f3fc1f2d1c701f762d2391ecb0cba0 du 05/10/2025 (sous-module lib/lua-lockbox de l'amont).
-- Licence amont : MIT (lib/lua-lockbox/LICENSE) — voir README.md.

local Lockbox = {};

--[[
package.path =  "./?.lua;"
                .. "./cipher/?.lua;"
                .. "./digest/?.lua;"
                .. "./kdf/?.lua;"
                .. "./mac/?.lua;"
                .. "./padding/?.lua;"
                .. "./test/?.lua;"
                .. "./util/?.lua;"
                .. package.path;
--]]
Lockbox.ALLOW_INSECURE = false;

Lockbox.insecure = function()
    assert(Lockbox.ALLOW_INSECURE,
            "This module is insecure!  It should not be used in production." ..
            "If you really want to use it, set Lockbox.ALLOW_INSECURE to true before importing it");
end

return Lockbox;
