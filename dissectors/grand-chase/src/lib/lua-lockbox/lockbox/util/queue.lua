-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/gcarlos64/lua-lockbox (lockbox/util/queue.lua),
-- commit 26287732d3f3fc1f2d1c701f762d2391ecb0cba0 du 05/10/2025 (sous-module lib/lua-lockbox de l'amont).
-- Licence amont : MIT (lib/lua-lockbox/LICENSE) — voir README.md.

local Queue = function()
    local queue = {};
    local tail = 0;
    local head = 0;

    local public = {};

    public.push = function(obj)
        queue[head] = obj;
        head = head + 1;
        return;
    end

    public.pop = function()
        if tail < head
        then
            local obj = queue[tail];
            queue[tail] = nil;
            tail = tail + 1;
            return obj;
        else
            return nil;
        end
    end

    public.size = function()
        return head - tail;
    end

    public.getHead = function()
        return head;
    end

    public.getTail = function()
        return tail;
    end

    public.reset = function()
        queue = {};
        head = 0;
        tail = 0;
    end

    return public;
end

return Queue;
