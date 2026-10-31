-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://github.com/erenes/wireshark-openttd-dissector (openttd.lua),
-- commit 4b5375a43d284eb5a100e913485d30bc2799aeaa du 28/11/2021.
-- Licence amont : GPL-2.0-only (fichier LICENSE, GPLv2 sans mention « or later ») — voir README.md.

local debug_level = {
    DISABLED = 0,
    LEVEL_1 = 1,
    LEVEL_2 = 2
}

local DEBUG = debug_level.LEVEL_2

local default_settings = {
    debug_level = DEBUG,
    port = 3979
}

local function makeValString(enumTable)
    local t = {}
    for name, num in pairs(enumTable) do
        t[num] = name
    end
    return t
end

local msgtype = {
    -- /* Packets sent by socket accepting code without ever constructing a client socket instance. */
    PACKET_SERVER_FULL = 0, -- < The server is full and has no place for you.
    PACKET_SERVER_BANNED = 1, -- < The server has banned you.

    -- /* Packets used by the client to join and an error message when the revision is wrong. */
    PACKET_CLIENT_JOIN = 2, -- < The client telling the server it wants to join.
    PACKET_SERVER_ERROR = 3, -- < Server sending an error message to the client.

    -- /* Unused packet types, formerly used for the pre-game lobby. */
    PACKET_CLIENT_UNUSED = 4, -- < Unused.
    PACKET_SERVER_UNUSED = 5, -- < Unused.

    -- /* Packets used to get the game info. */
    PACKET_SERVER_GAME_INFO = 6, -- < Information about the server.
    PACKET_CLIENT_GAME_INFO = 7, -- < Request information about the server.

    -- /* After the join step, the first is checking NewGRFs. */
    PACKET_SERVER_CHECK_NEWGRFS = 8, -- < Server sends NewGRF IDs and MD5 checksums for the client to check.
    PACKET_CLIENT_NEWGRFS_CHECKED = 9, -- < Client acknowledges that it has all required NewGRFs.

    -- /* Checking the game = , and then company passwords. */
    PACKET_SERVER_NEED_GAME_PASSWORD = 10, -- < Server requests the (hashed) game password.
    PACKET_CLIENT_GAME_PASSWORD = 11, -- < Clients sends the (hashed) game password.
    PACKET_SERVER_NEED_COMPANY_PASSWORD = 12, -- < Server requests the (hashed) company password.
    PACKET_CLIENT_COMPANY_PASSWORD = 13, -- < Client sends the (hashed) company password.

    -- /* The server welcomes the authenticated client and sends information of other clients. */
    PACKET_SERVER_WELCOME = 14, -- < Server welcomes you and gives you your #ClientID.
    PACKET_SERVER_CLIENT_INFO = 15, -- < Server sends you information about a client.

    -- /* Getting the savegame/map. */
    PACKET_CLIENT_GETMAP = 16, -- < Client requests the actual map.
    PACKET_SERVER_WAIT = 17, -- < Server tells the client there are some people waiting for the map as well.
    PACKET_SERVER_MAP_BEGIN = 18, -- < Server tells the client that it is beginning to send the map.
    PACKET_SERVER_MAP_SIZE = 19, -- < Server tells the client what the (compressed) size of the map is.
    PACKET_SERVER_MAP_DATA = 20, -- < Server sends bits of the map to the client.
    PACKET_SERVER_MAP_DONE = 21, -- < Server tells it has just sent the last bits of the map to the client.
    PACKET_CLIENT_MAP_OK = 22, -- < Client tells the server that it received the whole map.

    PACKET_SERVER_JOIN = 23, -- < Tells clients that a new client has joined.

    -- /* Game progress monitoring. */
    PACKET_SERVER_FRAME = 24, -- < Server tells the client what frame it is in = , and thus to where the client may progress.
    PACKET_CLIENT_ACK = 25, -- < The client tells the server which frame it has executed.
    PACKET_SERVER_SYNC = 26, -- < Server tells the client what the random state should be.

    -- /* Sending commands around. */
    PACKET_CLIENT_COMMAND = 27, -- < Client executed a command and sends it to the server.
    PACKET_SERVER_COMMAND = 28, -- < Server distributes a command to (all) the clients.

    -- /* Human communication! */
    PACKET_CLIENT_CHAT = 29, -- < Client said something that should be distributed.
    PACKET_SERVER_CHAT = 30, -- < Server distributing the message of a client (or itself).
    PACKET_SERVER_EXTERNAL_CHAT = 31, -- < Server distributing the message from external source.

    -- /* Remote console. */
    PACKET_CLIENT_RCON = 32, -- < Client asks the server to execute some command.
    PACKET_SERVER_RCON = 33, -- < Response of the executed command on the server.

    -- /* Moving a client.*/
    PACKET_CLIENT_MOVE = 34, -- < A client would like to be moved to another company.
    PACKET_SERVER_MOVE = 35, -- < Server tells everyone that someone is moved to another company.

    -- /* Configuration updates. */
    PACKET_CLIENT_SET_PASSWORD = 36, -- < A client (re)sets its company's password.
    PACKET_CLIENT_SET_NAME = 37, -- < A client changes its name.
    PACKET_SERVER_COMPANY_UPDATE = 38, -- < Information (password) of a company changed.
    PACKET_SERVER_CONFIG_UPDATE = 39, -- < Some network configuration important to the client changed.

    -- /* A server quitting this game. */
    PACKET_SERVER_NEWGAME = 40, -- < The server is preparing to start a new game.
    PACKET_SERVER_SHUTDOWN = 41, -- < The server is shutting down.

    -- /* A client quitting. */
    PACKET_CLIENT_QUIT = 42, -- < A client tells the server it is going to quit.
    PACKET_SERVER_QUIT = 43, -- < A server tells that a client has quit.
    PACKET_CLIENT_ERROR = 44, -- < A client reports an error to the server.
    PACKET_SERVER_ERROR_QUIT = 45, -- < A server tells that a client has hit an error and did quit.

    PACKET_END = 46 -- < Must ALWAYS be on the end of this list!! (period)}
}
local msgtype_valstr = makeValString(msgtype)

local playas = {
    COMPANY_0 = 0,
    COMPANY_1 = 1,
    COMPANY_2 = 2,
    COMPANY_3 = 3,
    COMPANY_4 = 4,
    COMPANY_5 = 5,
    COMPANY_6 = 6,
    COMPANY_7 = 7,
    COMPANY_8 = 8,
    COMPANY_9 = 9,
    COMPANY_10 = 10,
    COMPANY_11 = 11,
    COMPANY_12 = 12,
    COMPANY_13 = 13,
    COMPANY_14 = 14,
    COMPANY_15 = 15,
    COMPANY_NEW_COMPANY = 254,
    COMPANY_SPECTATOR = 255
}
local playas_valstr = makeValString(playas)

local commandcallback = {
    nullptr = 0,
    CcBuildPrimaryVehicle = 1,
    CcBuildAirport = 2,
    CcBuildBridge = 3,
    CcPlaySound_CONSTRUCTION_WATER = 4,
    CcBuildDocks = 5,
    CcFoundTown = 6,
    CcBuildRoadTunnel = 7,
    CcBuildRailTunnel = 8,
    CcBuildWagon = 9,
    CcRoadDepot = 10,
    CcRailDepot = 11,
    CcPlaceSign = 12,
    CcPlaySound_EXPLOSION = 13,
    CcPlaySound_CONSTRUCTION_OTHER = 14,
    CcPlaySound_CONSTRUCTION_RAIL = 15,
    CcStation = 16,
    CcTerraform = 17,
    CcAI = 18,
    CcCloneVehicle = 19,
    nullptr_20 = 20,
    CcCreateGroup = 21,
    CcFoundRandomTown = 22,
    CcRoadStop = 23,
    CcBuildIndustry = 24,
    CcStartStopVehicle = 25,
    CcGame = 26,
    CcAddVehicleNewGroup = 27
}
local commandcallback_valstr = makeValString(commandcallback);

local hdr_fields = {
    msg_len = ProtoField.uint16("ottd.length", "Length", base.DEC_HEX),
    msg_type = ProtoField.uint8("ottd.type", "Type", base.DEC, msgtype_valstr),
    client_version = ProtoField.stringz("ottd.client_version", "Client version", base.ASCII),
    newgrf_version = ProtoField.uint32("ottd.newgrf_version", "NewGRF version", base.HEX_DEC),
    client_name = ProtoField.stringz("ottd.client_name", "Client name", base.ASCII),
    client_playas = ProtoField.uint8("ottd.playas", "Playing", base.DEC, playas_valstr),
    client_id = ProtoField.uint32("ottd.network_own_clientid", "Client ID", base.DEC_HEX),
    passwd_game_seed = ProtoField.uint32("ottd.password_game_seed", "Password game seed", base.DEC_HEX),
    passwd_server_id = ProtoField.stringz("ottd.password_serverid", "Password server id", base.ASCII),
    frame_counter = ProtoField.uint32("ottd.frame_counter", "Frame counter", base.DEC_HEX),
    frame_counter_max = ProtoField.uint32("ottd.frame_counter_max", "Frame counter (max)", base.DEC_HEX),
    sync_seed_1 = ProtoField.uint32("ottd.sync_seed_1", "First sync seed", base.DEC_HEX),
    sync_seed_2 = ProtoField.uint32("ottd.sync_seed_2", "Second sync seed", base.DEC_HEX),
    server_token = ProtoField.uint8("ottd.server_token", "Token", base.DEC_HEX),
    server_max_companies = ProtoField.uint8("ottd.max_companies", "Max companies", base.DEC_HEX),
    server_name = ProtoField.stringz("ottd.server_name", "Server name", base.ASCII),
    companies_passworded = ProtoField.uint16("ottd.companies_passworded", "Passworded companies (TODO: bitfield)",
        base.DEC_HEX),
    company_0_pw = ProtoField.bool("ottd.c0pwd", "Password set (0)", 16, nil, 1),
    company_1_pw = ProtoField.bool("ottd.c1pwd", "Password set (1)", 16, nil, 2),
    company_2_pw = ProtoField.bool("ottd.c2pwd", "Password set (2)", 16, nil, 4),
    company_3_pw = ProtoField.bool("ottd.c3pwd", "Password set (3)", 16, nil, 8),
    company_4_pw = ProtoField.bool("ottd.c4pwd", "Password set (4)", 16, nil, 16),
    company_5_pw = ProtoField.bool("ottd.c5pwd", "Password set (5)", 16, nil, 32),
    company_6_pw = ProtoField.bool("ottd.c6pwd", "Password set (6)", 16, nil, 64),
    company_7_pw = ProtoField.bool("ottd.c7pwd", "Password set (7)", 16, nil, 128),
    company_8_pw = ProtoField.bool("ottd.c8pwd", "Password set (8)", 16, nil, 256),
    company_9_pw = ProtoField.bool("ottd.c9pwd", "Password set (9)", 16, nil, 512),
    company_a_pw = ProtoField.bool("ottd.capwd", "Password set (10)", 16, nil, 1024),
    company_b_pw = ProtoField.bool("ottd.cbpwd", "Password set (11)", 16, nil, 2048),
    company_c_pw = ProtoField.bool("ottd.ccpwd", "Password set (12)", 16, nil, 4096),
    company_d_pw = ProtoField.bool("ottd.cdpwd", "Password set (13)", 16, nil, 8192),
    company_e_pw = ProtoField.bool("ottd.cepwd", "Password set (14)", 16, nil, 16384),
    company_f_pw = ProtoField.bool("ottd.cfpwd", "Password set (15)", 16, nil, 32768),
    company_id = ProtoField.uint8("ottd.company_id", "Company ID", base.DEC, playas_valstr),
    command = ProtoField.uint32("ottd.command", "Command", base.HEX_DEC),
    command_server = ProtoField.bool("ottd.command.server", "SERVER", 32, nil, 1),
    command_spectator = ProtoField.bool("ottd.command.spectator", "SPECTATOR", 32, nil, 2),
    command_offline = ProtoField.bool("ottd.command.offline", "SINGLEPLAYER", 32, nil, 4),
    command_auto = ProtoField.bool("ottd.command.auto", "DC_AUTO", 32, nil, 8),
    command_all_tiles = ProtoField.bool("ottd.command.all_tiles", "ALL TILES (including void)", 32, nil, 16),
    command_no_test = ProtoField.bool("ottd.command.no_test", "No test (for town rating etc)", 32, nil, 32),
    command_no_water = ProtoField.bool("ottd.command.no_water", "DC_NO_WATER", 32, nil, 64),
    command_client_id = ProtoField.bool("ottd.command.client_id", "P2 is ClientID", 32, nil, 128),
    command_deity = ProtoField.bool("ottd.command.deity", "COMPANY_DEITY", 32, nil, 256),
    command_str_ctrl = ProtoField.bool("ottd.command.str_ctrl", "May contain control strings", 32, nil, 512),
    command_no_est = ProtoField.bool("ottd.command.no_est", "Never estimated", 32, nil, 1024),
    command_p1 = ProtoField.uint32("ottd.command_p1", "P1", base.DEC_HEX),
    command_p2 = ProtoField.uint32("ottd.command_p2", "P2", base.DEC_HEX),
    command_tile = ProtoField.uint32("ottd.command_tile", "Tile", base.DEC_HEX),
    command_text = ProtoField.stringz("ottd.command_text", "Text", base.ASCII),
    command_callback = ProtoField.uint8("ottd.command_callback", "Callback", base.HEX_DEC, commandcallback_valstr),
    my_command = ProtoField.bool("ottd.my_cmd", "My command", base.NONE),
    map_size = ProtoField.uint32("ottd.map_size", "Map size (bytes)", base.DEC_HEX),
}
-- creates a Proto object, but doesn't register it yet
local ottd_proto = Proto("ottd", "OpenTTD")
ottd_proto.fields = hdr_fields

local dprint = function(x)
end
local dprint2 = function(x)
end

local function resetDebugLevel()
    if default_settings.debug_level > debug_level.DISABLED then
        dprint = function(...)
            print(table.concat({"Lua: ", ...}, " "))
        end

        if default_settings.debug_level > debug_level.LEVEL_1 then
            dprint2 = dprint
        end
    else
        dprint = function()
        end
        dprint2 = dprint
    end
end

-- call it now
resetDebugLevel()

local dissectFunctions = {
    [msgtype.PACKET_CLIENT_JOIN] = function(tvbuf, length, offset, tree)
        dprint("offset: ", offset)
        local client_version_val = tvbuf:range(offset):stringz()
        dprint("client_version: ", client_version_val)

        tree:add(hdr_fields.client_version, client_version_val)

        offset = offset + string.len(client_version_val) + 1
        local newgrf_version_val = tvbuf:range(offset, 4):le_uint()
        dprint("newgrf_version: ", newgrf_version_val)
        tree:add(hdr_fields.newgrf_version, newgrf_version_val)

        offset = offset + 4
        local client_name_val = tvbuf:range(offset):stringz()
        dprint("client_name: ", client_name_val)
        tree:add(hdr_fields.client_name, client_name_val)

        offset = offset + string.len(client_name_val) + 1
        local playas_val = tvbuf:range(offset, 1):le_uint()
        tree:add(hdr_fields.client_playas, playas_val);
    end,
    [msgtype.PACKET_SERVER_WELCOME] = function(tvbuf, length, offset, tree)
        -- 	_network_own_client_id = (ClientID)p->Recv_uint32();
        local _network_own_client_id = tvbuf:range(offset, 4):le_uint()
        dprint("_network_own_client_id: ", _network_own_client_id)
        tree:add(hdr_fields.client_id, _network_own_client_id)
        offset = offset + 4

        -- _password_game_seed = p->Recv_uint32();
        local _password_game_seed = tvbuf:range(offset, 4):le_uint()
        dprint("_password_game_seed: ", _password_game_seed)
        tree:add(hdr_fields.passwd_game_seed, _password_game_seed)
        offset = offset + 4

        -- _password_server_id = p->Recv_string(NETWORK_SERVER_ID_LENGTH);
        local _password_server_id = tvbuf:range(offset):stringz()
        dprint("_password_server_id: ", _password_server_id)
        tree:add(hdr_fields.passwd_server_id, _password_server_id)
    end,
    [msgtype.PACKET_SERVER_CLIENT_INFO] = function(tvbuf, length, offset, tree)
        -- ClientID client_id = (ClientID)p->Recv_uint32();
        local _network_own_client_id = tvbuf:range(offset, 4):le_uint()
        dprint("_network_own_client_id: ", _network_own_client_id)
        tree:add(hdr_fields.client_id, _network_own_client_id)
        offset = offset + 4

        -- CompanyID playas = (CompanyID)p->Recv_uint8();
        local playas_val = tvbuf:range(offset, 1):le_uint()
        tree:add(hdr_fields.client_playas, playas_val);
        offset = offset + 1

        -- std::string name = p->Recv_string(NETWORK_NAME_LENGTH);
        local client_name = tvbuf:range(offset):stringz()
        dprint("client_name: ", client_name)
        tree:add(hdr_fields.client_name, client_name)

    end,
    [msgtype.PACKET_SERVER_MAP_BEGIN] = function(tvbuf, length, offset, tree)
        -- ClientID client_id = (ClientID)p->Recv_uint32();
        local _frame_counter = tvbuf:range(offset, 4):le_uint()
        dprint("_frame_counter: ", _frame_counter)
        tree:add(hdr_fields.frame_counter, _frame_counter)
    end,
    [msgtype.PACKET_SERVER_MAP_SIZE] = function(tvbuf, length, offset, tree)
        local map_size = tvbuf:range(offset, 4):le_uint()
        tree:add(hdr_fields.map_size, map_size)
    end,
    [msgtype.PACKET_SERVER_FRAME] = function(tvbuf, length, offset, tree)
        -- _frame_counter_server = p->Recv_uint32();
        local _frame_counter_server = tvbuf:range(offset, 4):le_uint()
        dprint("_frame_counter_server: ", _frame_counter_server)
        tree:add(hdr_fields.frame_counter, _frame_counter_server)
        offset = offset + 4

        -- _frame_counter_max = p->Recv_uint32();
        local _frame_counter_max = tvbuf:range(offset, 4):le_uint()
        dprint("_frame_counter_max: ", _frame_counter_max)
        tree:add(hdr_fields.frame_counter_max, _frame_counter_max)
        offset = offset + 4

        if length - offset >= 4 then
            -- sync_seed_1
            local sync_seed_1 = tvbuf:range(offset, 4):le_uint()
            dprint("sync_seed_1: ", sync_seed_1)
            tree:add(hdr_fields.sync_seed_1, sync_seed_1)
            offset = offset + 4
        end
        if length - offset >= 4 then
            -- sync_seed_2
            local sync_seed_2 = tvbuf:range(offset, 4):le_uint()
            dprint("sync_seed_1: ", sync_seed_2)
            tree:add(hdr_fields.sync_seed_2, sync_seed_2)
            offset = offset + 4
        end
        if length - offset >= 1 then
            local server_token = tvbuf:range(offset, 1):le_uint()
            dprint("server_token: ", server_token)
            tree:add(hdr_fields.server_token, server_token)
        end
    end,
    [msgtype.PACKET_CLIENT_ACK] = function(tvbuf, length, offset, tree)
        -- uint32 frame = p->Recv_uint32();
        local _frame_counter_client = tvbuf:range(offset, 4):le_uint()
        dprint("_frame_counter_client: ", _frame_counter_client)
        tree:add(hdr_fields.frame_counter, _frame_counter_client)
        offset = offset + 4

        -- 	uint8 token = p->Recv_uint8();
        local server_token = tvbuf:range(offset, 1):le_uint()
        dprint("server_token: ", server_token)
        tree:add(hdr_fields.server_token, server_token)
    end,
    [msgtype.PACKET_SERVER_SYNC] = function(tvbuf, length, offset, tree)
        -- _frame_counter_server = p->Recv_uint32();
        local _frame_counter_server = tvbuf:range(offset, 4):le_uint()
        dprint("_frame_counter_server: ", _frame_counter_server)
        tree:add(hdr_fields.frame_counter, _frame_counter_server)
        offset = offset + 4

        -- sync_seed_1
        local sync_seed_1 = tvbuf:range(offset, 4):le_uint()
        dprint("sync_seed_1: ", sync_seed_1)
        tree:add(hdr_fields.sync_seed_1, sync_seed_1)
        offset = offset + 4

        if length - offset >= 4 then
            -- sync_seed_2
            local sync_seed_2 = tvbuf:range(offset, 4):le_uint()
            dprint("sync_seed_1: ", sync_seed_2)
            tree:add(hdr_fields.sync_seed_2, sync_seed_2)
            offset = offset + 4
        end
    end,
    [msgtype.PACKET_SERVER_JOIN] = function(tvbuf, length, offset, tree)
        -- 	_network_own_client_id = (ClientID)p->Recv_uint32();
        local _network_own_client_id = tvbuf:range(offset, 4):le_uint()
        dprint("_network_own_client_id: ", _network_own_client_id)
        tree:add(hdr_fields.client_id, _network_own_client_id)
    end,
    [msgtype.PACKET_SERVER_CONFIG_UPDATE] = function(tvbuf, length, offset, tree)
        -- _password_game_seed = p->Recv_uint32();
        local server_max_companies = tvbuf:range(offset, 1):le_uint()
        dprint("server_max_companies: ", server_max_companies)
        tree:add(hdr_fields.server_max_companies, server_max_companies)
        offset = offset + 1

        -- _password_server_id = p->Recv_string(NETWORK_SERVER_ID_LENGTH);
        local server_name = tvbuf:range(offset):stringz()
        dprint("server_name: ", server_name)
        tree:add(hdr_fields.server_name, server_name)
    end,
    [msgtype.PACKET_SERVER_COMPANY_UPDATE] = function(tvbuf, length, offset, tree)
        -- _password_game_seed = p->Recv_uint32();
        local companies_passworded = tvbuf:range(offset, 2):le_uint()
        dprint("companies_passworded: ", companies_passworded)
        tree:add(hdr_fields.company_0_pw, companies_passworded)
        tree:add(hdr_fields.company_1_pw, companies_passworded)
        tree:add(hdr_fields.company_2_pw, companies_passworded)
        tree:add(hdr_fields.company_3_pw, companies_passworded)
        tree:add(hdr_fields.company_4_pw, companies_passworded)
        tree:add(hdr_fields.company_5_pw, companies_passworded)
        tree:add(hdr_fields.company_6_pw, companies_passworded)
        tree:add(hdr_fields.company_7_pw, companies_passworded)
        tree:add(hdr_fields.company_8_pw, companies_passworded)
        tree:add(hdr_fields.company_9_pw, companies_passworded)
        tree:add(hdr_fields.company_a_pw, companies_passworded)
        tree:add(hdr_fields.company_b_pw, companies_passworded)
        tree:add(hdr_fields.company_c_pw, companies_passworded)
        tree:add(hdr_fields.company_d_pw, companies_passworded)
        tree:add(hdr_fields.company_e_pw, companies_passworded)
        tree:add(hdr_fields.company_f_pw, companies_passworded)
    end,
    [msgtype.PACKET_SERVER_COMMAND] = function(tvbuf, length, offset, tree)
        local company_id = tvbuf:range(offset, 1):le_uint()
        tree:add(hdr_fields.company_id, company_id)
        offset = offset + 1

        local command = tvbuf:range(offset, 4):le_uint()
        tree:add(hdr_fields.command, command)

        tree:add(hdr_fields.command_server, command)
        tree:add(hdr_fields.command_spectator, command)
        tree:add(hdr_fields.command_offline, command)
        tree:add(hdr_fields.command_auto, command)
        tree:add(hdr_fields.command_all_tiles, command)
        tree:add(hdr_fields.command_no_test, command)
        tree:add(hdr_fields.command_no_water, command)
        tree:add(hdr_fields.command_client_id, command)
        tree:add(hdr_fields.command_deity, command)
        tree:add(hdr_fields.command_str_ctrl, command)
        tree:add(hdr_fields.command_no_est, command)
        offset = offset + 4
        
        local p1 = tvbuf:range(offset, 4):le_uint()
        tree:add(hdr_fields.command_p1, p1)
        offset = offset + 4
        
        local p2 = tvbuf:range(offset, 4):le_uint()
        tree:add(hdr_fields.command_p2, p2)
        offset = offset + 4

        local tile = tvbuf:range(offset, 4):le_uint()
        tree:add(hdr_fields.command_tile, tile)
        offset = offset + 4
        
        local text = tvbuf:range(offset):stringz()
        tree:add(hdr_fields.command_text, text)
        offset = offset + string.len(text) + 1

        local callback = tvbuf:range(offset, 1):le_uint()
        tree:add(hdr_fields.command_callback, callback)
        offset = offset + 1

        local _frame_counter_server = tvbuf:range(offset, 4):le_uint()
        tree:add(hdr_fields.frame_counter, _frame_counter_server)
        offset = offset + 4

        local my_command = tvbuf:range(offset, 1):bitfield()
        tree:add(hdr_fields.my_command, my_command)
    end
}

dprint("Wireshark version = ", get_version())
dprint("Lua version = ", _VERSION)

dprint("Debug level = ", default_settings.debug_level)

function ottd_proto.init()
end

-- this holds the plain "data" Dissector
local data = Dissector.get("data")

function ottd_proto.dissector(tvbuf, pktinfo, root)
    dprint2("ottd_proto.dissector called")
    pktinfo.cols.protocol:set("OTTD")

    local offset = 0
    local pkt_len = tvbuf:len()
    local header_len = tvbuf:range(offset, 2):le_uint()

    -- Verify the header length equals the buffer length
    if header_len ~= pkt_len then
        return
    end

    dprint2("packet length OK!")

    local tree = root:add(ottd_proto, tvbuf:range(offset, header_len))
    tree:add(hdr_fields.msg_len, header_len)

    offset = offset + 2
    local msgtype_tvbr = tvbuf:range(offset, 1)
    local msgtype_val = msgtype_tvbr:le_uint()
    tree:add(hdr_fields.msg_type, msgtype_val);

    if dissectFunctions[msgtype_val] ~= nil then
        dissectFunctions[msgtype_val](tvbuf, header_len, offset + 1, tree)
    end
end

-- enable our dissector
DissectorTable.get("tcp.port"):add(default_settings.port, ottd_proto)
