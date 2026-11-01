-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/gcarlos64/lua-lockbox (lockbox/padding/pkcs7.lua),
-- commit 26287732d3f3fc1f2d1c701f762d2391ecb0cba0 du 05/10/2025 (sous-module lib/lua-lockbox de l'amont).
-- Licence amont : MIT (lib/lua-lockbox/LICENSE) — voir README.md.

local PKCS7Padding = function(blockSize, byteCount)
    local paddingCount = blockSize - (((byteCount - 1) % blockSize) + 1);
    local bytesLeft = paddingCount;

    local stream = function()
        if bytesLeft > 0 then
            bytesLeft = bytesLeft - 1;
            return paddingCount;
        else
            return nil;
        end
    end

    return stream;
end

return PKCS7Padding;
