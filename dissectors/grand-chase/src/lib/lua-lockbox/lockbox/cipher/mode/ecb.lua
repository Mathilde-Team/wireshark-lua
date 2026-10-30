-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/gcarlos64/lua-lockbox (lockbox/cipher/mode/ecb.lua),
-- commit 26287732d3f3fc1f2d1c701f762d2391ecb0cba0 du 05/10/2025 (sous-module lib/lua-lockbox de l'amont).
-- Licence amont : MIT (lib/lua-lockbox/LICENSE) — voir README.md.

require("lockbox").insecure();

local Array = require("lockbox.util.array");
local Stream = require("lockbox.util.stream");
local Queue = require("lockbox.util.queue");

local ECB = {};

ECB.Cipher = function()

    local public = {};

    local key;
    local blockCipher;
    local padding;
    local inputQueue;
    local outputQueue;

    public.setKey = function(keyBytes)
        key = keyBytes;
        return public;
    end

    public.setBlockCipher = function(cipher)
        blockCipher = cipher;
        return public;
    end

    public.setPadding = function(paddingMode)
        padding = paddingMode;
        return public;
    end

    public.init = function()
        inputQueue = Queue();
        outputQueue = Queue();
        return public;
    end

    public.update = function(messageStream)
        local byte = messageStream();
        while (byte ~= nil) do
            inputQueue.push(byte);
            if(inputQueue.size() >= blockCipher.blockSize) then
                local block = Array.readFromQueue(inputQueue, blockCipher.blockSize);

                block = blockCipher.encrypt(key, block);

                Array.writeToQueue(outputQueue, block);
            end
            byte = messageStream();
        end
        return public;
    end

    public.finish = function()
        local paddingStream = padding(blockCipher.blockSize, inputQueue.getHead());
        public.update(paddingStream);

        return public;
    end

    public.getOutputQueue = function()
        return outputQueue;
    end

    public.asHex = function()
        return Stream.toHex(outputQueue.pop);
    end

    public.asBytes = function()
        return Stream.toArray(outputQueue.pop);
    end

    public.asString = function()
        return Stream.toString(outputQueue.pop);
    end

    return public;

end

ECB.Decipher = function()

    local public = {};

    local key;
    local blockCipher;
    local padding;
    local inputQueue;
    local outputQueue;

    public.setKey = function(keyBytes)
        key = keyBytes;
        return public;
    end

    public.setBlockCipher = function(cipher)
        blockCipher = cipher;
        return public;
    end

    public.setPadding = function(paddingMode)
        padding = paddingMode;
        return public;
    end

    public.init = function()
        inputQueue = Queue();
        outputQueue = Queue();
        return public;
    end

    public.update = function(messageStream)
        local byte = messageStream();
        while (byte ~= nil) do
            inputQueue.push(byte);
            if(inputQueue.size() >= blockCipher.blockSize) then
                local block = Array.readFromQueue(inputQueue, blockCipher.blockSize);

                block = blockCipher.decrypt(key, block);

                Array.writeToQueue(outputQueue, block);
            end
            byte = messageStream();
        end
        return public;
    end

    public.finish = function()
        local paddingStream = padding(blockCipher.blockSize, inputQueue.getHead());
        public.update(paddingStream);

        return public;
    end

    public.getOutputQueue = function()
        return outputQueue;
    end

    public.asHex = function()
        return Stream.toHex(outputQueue.pop);
    end

    public.asBytes = function()
        return Stream.toArray(outputQueue.pop);
    end

    public.asString = function()
        return Stream.toString(outputQueue.pop);
    end

    return public;

end


return ECB;
