-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/smash64-dev/kaillera-dissector (constants.lua),
-- commit 96e5fc77a1aa29510b24394144d0820541e85488 du 01/05/2021.
-- Licence amont : MIT (fichier LICENSE, « Copyright (c) 2021 Smash64 Development ») — voir README.md.

-- constants.lua

local ArrayField = require "lib.arrayfield"
local Field = require "lib.field"
local Message = require "lib.message"

-- kaillera constants
CONNECTION_TYPE = {[1] = "LAN", [2] = "Excellent", [3] = "Good", [4] = "Average", [5] = "Low", [6] = "Bad"}
GAME_STATUS = {[0] = "Waiting", [1] = "Playing", [2] = "Syncing"}
PLAYER_STATUS = {[1] = "Idle", [2] = "Playing"}

KAILLERA_RAW = {
    client_hello = "HELLO0.83",
    client_ping = "PING",
    server_hello = "HELLOD00D([0-9]+)",
    server_pong = "PONG",
}

KAILLERA_TYPES = {
    [0x1] = Message:new({name = "CLIENT_QUIT",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, client = 0}),
            Field:new({name = "User ID", type = ftypes.UINT8, size = 2, client = 0}),
            Field:new({name = "Quit Message", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
        },
    }),
    [0x2] = Message:new({name = "CLIENT_JOIN",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
            Field:new({name = "User ID", type = ftypes.UINT8, size = 2}),
            Field:new({name = "Ping (ms)", type = ftypes.UINT8, size = 4}),
            Field:new({name = "Connection Type", type = ftypes.UINT8, size = 1, valuestring = CONNECTION_TYPE}),
        },
    }),
    [0x3] = Message:new({name = "CLIENT_INFO",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
            Field:new({name = "Emulator Name", type = ftypes.STRINGZ}),
            Field:new({name = "Connection Type", type = ftypes.UINT8, size = 1, valuestring = CONNECTION_TYPE}),
        },
    }),
    [0x4] = Message:new({name = "SERVER_STATUS",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "Number of Players", type = ftypes.UINT8, size = 4, refName = "players"}),
            Field:new({name = "Number of Games", type = ftypes.UINT8, size = 4, refName = "games"}),
            ArrayField:new({name = "Player List", sizeOf = "players", fields = {
                Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, refName = "user", childOf = "players"}),
                Field:new({name = "Ping (ms)", type = ftypes.UINT8, size = 4, childOf = "user"}),
                -- TODO: this seems to be PLAYER_STATUS when playing
                Field:new({name = "Connection Type", type = ftypes.UINT8, size = 1, valuestring = CONNECTION_TYPE, childOf = "user"}),
                Field:new({name = "User ID", type = ftypes.UINT8, size = 2, childOf = "user"}),
                -- TODO: this seems to be CONNECTION_TYPE when playing
                Field:new({name = "Player Status", type = ftypes.UINT8, size = 1, valuestring = PLAYER_STATUS, childOf = "user"}),
            }}),
            ArrayField:new({name = "Game List", sizeOf = "games", fields = {
                Field:new({name = "Game Name", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, refName = "game", childOf = "games"}),
                Field:new({name = "Game ID", type = ftypes.UINT8, size = 4, childOf = "game"}),
                Field:new({name = "Emulator Name", type = ftypes.STRINGZ, childOf = "game"}),
                Field:new({name = "Owner", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, childOf = "game"}),
                Field:new({name = "Player Count", type = ftypes.STRINGZ, childOf = "game"}),
                Field:new({name = "Game Status", type = ftypes.UINT8, size = 1, valuestring = GAME_STATUS, childOf = "game"}),
            }}),
        },
    }),
    [0x5] = Message:new({name = "SERVER_ACK",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            ArrayField:new({name = "Unknown", size = 4, fields = {
                Field:new({name = "Unknown", type = ftypes.UINT8, size = 4}),
            }}),
        },
    }),
    [0x6] = Message:new({name = "CLIENT_ACK",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            ArrayField:new({name = "Unknown", size = 4, fields = {
                Field:new({name = "Unknown", type = ftypes.UINT8, size = 4}),
            }}),
        },
    }),
    [0x7] = Message:new({name = "CHAT_GLOBAL",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, client = 0}),
            Field:new({name = "Message", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
        },
    }),
    [0x8] = Message:new({name = "CHAT_GAME",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, client = 0}),
            Field:new({name = "Message", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
        },
    }),
    [0x9] = Message:new({name = "KEEP_ALIVE",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
        },
    }),
    [0xA] = Message:new({name = "GAME_CREATE",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, client = 0}),
            Field:new({name = "Game Name", type = ftypes.STRINGZ}),
            Field:new({name = "Emulator Name", type = ftypes.STRINGZ, client = 0}),
            Field:new({name = "Game ID", type = ftypes.UINT8, size = 4, client = 0}),
        },
    }),
    [0xB] = Message:new({name = "GAME_QUIT",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, client = 0}),
            Field:new({name = "User ID", type = ftypes.UINT8, size = 2, client = 0}),
        },
    }),
    [0xC] = Message:new({name = "GAME_JOIN",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "Game ID", type = ftypes.UINT8, size = 4}),
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, client = 0}),
            Field:new({name = "Ping (ms)", type = ftypes.UINT8, size = 4, client = 0}),
            Field:new({name = "User ID", type = ftypes.UINT8, size = 2, client = 0}),
            Field:new({name = "Connection Type", type = ftypes.UINT8, size = 1, valuestring = CONNECTION_TYPE}),
        },
    }),
    [0xD] = Message:new({name = "GAME_PLAYER",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "Number of Players", type = ftypes.UINT8, size = 4}),
        },
    }),
    [0xE] = Message:new({name = "GAME_STATUS",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "Game ID", type = ftypes.UINT8, size = 4}),
            Field:new({name = "Game Status", type = ftypes.UINT8, size = 1, valuestring = GAME_STATUS}),
            Field:new({name = "Number of Players", type = ftypes.UINT8, size = 1}),
            Field:new({name = "Maximum Players", type = ftypes.UINT8, size = 1}),
        },
    }),
    [0xF] = Message:new({name = "GAME_KICK",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "User ID", type = ftypes.UINT8, size = 2}),
        },
    }),
    [0x10] = Message:new({name = "GAME_CLOSE",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "Game ID", type = ftypes.UINT8, size = 4}),
        },
    }),
    [0x11] = Message:new({name = "GAME_START",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, client = 0, hidden = 1}),
            Field:new({name = "Frame Delay", type = ftypes.UINT8, size = 2, client = 0}),
            Field:new({name = "Player Number", type = ftypes.UINT8, size = 1, client = 0}),
            Field:new({name = "Total Players", type = ftypes.UINT8, size = 1, client = 0}),
        },
    }),
    -- TODO: parse game data for different emulators
    [0x12] = Message:new({name = "GAME_DATA",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "Length", type = ftypes.UINT8, size = 2}),
            Field:new({name = "Data", type = ftypes.BYTES, sizeOf = "message"}),
        },
    }),
    [0x13] = Message:new({name = "GAME_CACHE",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
            Field:new({name = "Index", type = ftypes.UINT8, size = 1}),
        },
    }),
    [0x14] = Message:new({name = "GAME_DROP",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, client = 0}),
            Field:new({name = "Player Number", type = ftypes.UINT8, size = 1}),
        },
    }),
    [0x15] = Message:new({name = "GAME_READY",
        fields = {
            Field:new({name = "Empty", type = ftypes.STRINGZ, hidden = 1}),
        },
    }),
    [0x16] = Message:new({name = "SERVER_REJECT",
        fields = {
            Field:new({name = "Username", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
            Field:new({name = "User ID", type = ftypes.UINT8, size = 2}),
            Field:new({name = "Message", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
        },
    }),
    [0x17] = Message:new({name = "SERVER_NOTICE",
        fields = {
            Field:new({name = "'server'", type = ftypes.STRINGZ}),
            Field:new({name = "Message", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
        },
    }),
}

-- okai constants
OKAI_TYPES = {
    [0x00] = Message:new({name = "CLIENT_REQUEST",
        fields = {
            Field:new({name = "Username", type = ftypes.STRING, size = 32}),
            Field:new({name = "Emulator Name", type = ftypes.STRING, size = 128}),
        },
    }),
    [0x10] = Message:new({name = "CLIENT_ACCEPT",
        fields = {
            Field:new({name = "Username", type = ftypes.STRING, size = 32}),
            Field:new({name = "Game Name", type = ftypes.STRING, size = 128}),
        },
    }),
    [0x20] = Message:new({name = "CLIENT_REJECT",
        fields = {
            -- this message type may never be sent directly
        },
    }),
    -- TODO: figure out the unknowns and varying length of message
    [0x01] = Message:new({name = "PING_PING",
        fields = {
            Field:new({name = "Core State", type = ftypes.NONE, refName = "core", treeOnly = 1}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 4, childOf = "core"}),
            Field:new({name = "Host", type = ftypes.BOOLEAN, size = 1, childOf = "core"}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 3, childOf = "core"}),
            Field:new({name = "Port", type = ftypes.UINT8, size = 2, base = base.DEC, childOf = "core"}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 2, childOf = "core"}),
            Field:new({name = "Peer IP", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, childOf = "core"}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 4, childOf = "core"}),
        },
    }),
    [0x11] = Message:new({name = "PING_ECHO",
        fields = {
            Field:new({name = "Core State", type = ftypes.NONE, refName = "core", treeOnly = 1}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 4, childOf = "core"}),
            Field:new({name = "Host", type = ftypes.BOOLEAN, size = 1, childOf = "core"}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 3, childOf = "core"}),
            Field:new({name = "Port", type = ftypes.UINT8, size = 2, base = base.DEC, childOf = "core"}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 2, childOf = "core"}),
            Field:new({name = "Peer IP", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1, childOf = "core"}),
            Field:new({name = "Unknown", type = ftypes.BYTES, size = 4, childOf = "core"}),
        },
    }),
    [0x02] = Message:new({name = "PLAYER_READY", fields = {}}),
    [0x12] = Message:new({name = "PLAYER_NOT_READY", fields = {}}),
    [0x03] = Message:new({name = "SYNC", fields = {
            -- this message type is never sent directly
        },
    }),
    [0x13] = Message:new({name = "SYNC_INIT",
        fields = {
            Field:new({name = "Initial Value (ms)", type = ftypes.UINT8, size = 4}),
        },
    }),
    [0x23] = Message:new({name = "SYNC_GUESS",
        fields = {
            Field:new({name = "Offset Guess (ms)", type = ftypes.UINT8, size = 4}),
        },
    }),
    [0x43] = Message:new({name = "SYNC_ADJUST",
        fields = {
            Field:new({name = "Offset Adjust (ms)", type = ftypes.INT8, size = 4}),
        },
    }),
    [0x04] = Message:new({name = "SYNC_DELAY",
        fields = {
            Field:new({name = "Frames", type = ftypes.UINT8, size = 4}),
        },
    }),
    [0x05] = Message:new({name = "GAME_LOAD", fields = {}}),
    [0x15] = Message:new({name = "GAME_LOADING", fields = {}}),
    [0x06] = Message:new({name = "GAME_START",
        fields = {
            Field:new({name = "Tick Count", type = ftypes.UINT8, size = 4}),
        },
    }),
    [0x07] = Message:new({name = "GAME_DATA",
        fields = {
            Field:new({name = "Game Data", type = ftypes.BYTES, sizeOf = "message"}),
        },
    }),
    [0x08] = Message:new({name = "GAME_DROP", fields = {}}),
    [0x09] = Message:new({name = "PLAYER_CHAT",
        fields = {
            Field:new({name = "Frame Number (+5?)", type = ftypes.UINT8, base = base.DEC, size = 4}),
            Field:new({name = "Message", type = ftypes.STRINGZ, encoding = ENC_ISO_8859_1}),
        },
    }),
    [0x0a] = Message:new({name = "CLIENT_EXIT", fields = {}}),
}
