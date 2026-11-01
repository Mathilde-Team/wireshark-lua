-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/gcarlos64/lua-lockbox (lockbox/mac/hmac.lua),
-- commit 26287732d3f3fc1f2d1c701f762d2391ecb0cba0 du 05/10/2025 (sous-module lib/lua-lockbox de l'amont).
-- Licence amont : MIT (lib/lua-lockbox/LICENSE) — voir README.md.

local Bit = require("lockbox.util.bit");
local Stream = require("lockbox.util.stream");
local Array = require("lockbox.util.array");

local XOR = Bit.bxor;

local HMAC = function()

    local public = {};
    local blockSize = 64;
    local Digest = nil;
    local outerPadding = {};
    local innerPadding = {}
    local digest;

    public.setBlockSize = function(bytes)
        blockSize = bytes;
        return public;
    end

    public.setDigest = function(digestModule)
        Digest = digestModule;
        digest = Digest();
        return public;
    end

    public.setKey = function(key)
        local keyStream;

        if(Array.size(key) > blockSize) then
            keyStream = Stream.fromArray(Digest()
                        .update(Stream.fromArray(key))
                        .finish()
                        .asBytes());
        else
            keyStream = Stream.fromArray(key);
        end

        outerPadding = {};
        innerPadding = {};

        for i = 1, blockSize do
            local byte = keyStream();
            if byte == nil then byte = 0x00; end
            outerPadding[i] = XOR(0x5C, byte);
            innerPadding[i] = XOR(0x36, byte);
        end

        return public;
    end

    public.init = function()
        digest.init()
              .update(Stream.fromArray(innerPadding));
        return public;
    end

    public.update = function(messageStream)
        digest.update(messageStream);
        return public;
    end

    public.finish = function()
        local inner = digest.finish().asBytes();
        digest.init()
              .update(Stream.fromArray(outerPadding))
              .update(Stream.fromArray(inner))
              .finish();

        return public;
    end

    public.asBytes = function()
        return digest.asBytes();
    end

    public.asHex = function()
        return digest.asHex();
    end

    public.asString = function()
        return digest.asString();
    end

    return public;

end

return HMAC;
