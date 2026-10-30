-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/gcarlos64/lua-lockbox (lockbox/padding/isoiec7816.lua),
-- commit 26287732d3f3fc1f2d1c701f762d2391ecb0cba0 du 05/10/2025 (sous-module lib/lua-lockbox de l'amont).
-- Licence amont : MIT (lib/lua-lockbox/LICENSE) — voir README.md.

local ISOIEC7816Padding = function(blockSize, byteCount)

    local paddingCount = blockSize - (byteCount % blockSize);
    local bytesLeft = paddingCount;

    local stream = function()
        if bytesLeft == paddingCount then
            bytesLeft = bytesLeft - 1;
            return 0x80;
        elseif bytesLeft > 0 then
            bytesLeft = bytesLeft - 1;
            return 0x00;
        else
            return nil;
        end
    end

    return stream;

end

return ISOIEC7816Padding;
