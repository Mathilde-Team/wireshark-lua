-- SPDX-License-Identifier: GPL-2.0-or-later
-- Importé de https://github.com/DasSkelett/LmpWiresharkDissector (decoder_Handshake.lua),
-- commit 78c8093752eb1b0c1ee79f43db091307a7aa5395 du 17/04/2022.
-- Licence amont : GPL-2.0-or-later (en-tête de LmpWiresharkDissector.lua, fichier principal du dissecteur ; pas d'en-tête propre) — voir README.md.

function decodeHandshakeRequest(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"Handshake Request")
    
    -- HandshakeRequestMsgData / Handshake Request
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Player Name Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Player Name: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Unique Identifier Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Unique Identifier: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
end

function decodeHandshakeReply(buffer, cursor, proto, lmp_base_subtree)
    local subtree = lmp_base_subtree:add(proto,buffer(cursor),"Handshake Reply")
    
    -- HandshakeReplyMsgData / Handshake Reply
    
    local response_status = {
        [0] = "HandshookSuccessfully",
        [1] = "PlayerBanned",
        [2] = "ServerFull",
        [3] = "InvalidPlayername"
    }
    
    subtree:add(buffer(cursor,4),"Response (Status): " .. response_status[buffer(cursor,4):le_uint()])
    cursor = cursor + 4
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Reason Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Reason: " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
    
    subtree:add(buffer(cursor,1),"ModControl: " .. buffer(cursor,1):bitfield(7, 1))
    
    -- Padding Bits
    cursor = cursor + 1
    
    subtree:add(buffer(cursor,8),"Server Start Time: " .. buffer(cursor,8):le_uint64())
    cursor = cursor + 8
    
    nextlen = buffer(cursor,1):le_uint()
    subtree:add(buffer(cursor,1),"Mod File Data Length: " .. nextlen)
    cursor = cursor + 1
    subtree:add(buffer(cursor,nextlen),"Mod File Data : " .. buffer(cursor,nextlen):string())
    cursor = cursor + nextlen
end
