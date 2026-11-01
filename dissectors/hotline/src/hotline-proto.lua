-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/jhalter/hotline-wireshark-dissector (hotline-proto.lua),
-- commit ad8ea6b6c8078e69d4a7136aefec52d0cea8eb7f du 21/08/2026.
-- Licence amont : MIT (LICENSE) — voir README.md.

-- Hotline protocol family dissectors for Wireshark.
-- Supports command, file transfer, tracker, and HTTP tunnel traffic.

local PLUGIN_VERSION = "1.0.0"
local MAX_PORT = 65535
local DEFAULT_MAX_PDU = 16 * 1024 * 1024
local MAC_EPOCH_DELTA = 2082844800

if set_plugin_info then
    set_plugin_info({
        version = PLUGIN_VERSION,
        description = "Hotline command, file transfer, tracker, and HTTP tunnel dissectors",
        author = "Jeff Halter and contributors",
        repository = "https://github.com/jhalter/hotline-wireshark-dissector",
    })
end

local hotline = Proto("HOTL", "Hotline Protocol")
local htxf = Proto("HTXF", "Hotline File Transfer")
local htrk = Proto("HTRK", "Hotline Tracker Protocol")
local hlhttp = Proto("HLHTTP", "Hotline HTTP Tunnel")

local TRANSACTION_NAMES = {
    [0] = "Reply", [100] = "Error", [101] = "Get Messages", [102] = "New Message",
    [103] = "Old Post News", [104] = "Server Message", [105] = "Send Chat",
    [106] = "Chat Message", [107] = "Login", [108] = "Send Instant Message",
    [109] = "Show Agreement", [110] = "Disconnect User", [111] = "Disconnect Message",
    [112] = "Invite To A New Chat", [113] = "Invite To Chat", [114] = "Reject Chat Invite",
    [115] = "Join Chat", [116] = "Leave Chat", [117] = "Notify Chat Of A User Change",
    [118] = "Notify Chat Of A Delete User", [119] = "Notify Of A Chat Subject", [120] = "Set Chat Subject",
    [121] = "Agreed", [122] = "Server Banner", [200] = "Get File Name List",
    [202] = "Download File", [203] = "Upload File", [204] = "Delete File",
    [205] = "New Folder", [206] = "Get File Info", [207] = "Set File Info",
    [208] = "Move File", [209] = "Make File Alias", [210] = "Download Folder",
    [211] = "Download Info", [212] = "Download Banner", [213] = "Upload Folder",
    [300] = "Get User Name List", [301] = "Notify Of A User Change", [302] = "Notify Of A Delete User",
    [303] = "Get Client Info Text", [304] = "Set Client User Info", [348] = "Get Accounts",
    -- 294-296 are unverified extensions named by a maintained client enum,
    -- but are absent from the official 1.9 protocol and have no known schema.
    [294] = "Get News File (extension)", [295] = "Post News (extension)",
    [296] = "Receive News File (extension)",
    [349] = "Update User Account", [350] = "New User Account", [351] = "Delete User Account",
    [352] = "Get User Account", [353] = "Set User Account", [354] = "User Access",
    [355] = "User Broadcast", [370] = "Get News Category Name List", [371] = "Get News Article Name List",
    [380] = "Delete News Item", [381] = "New News Folder", [382] = "New News Category",
    [400] = "Get News Article Data", [410] = "Post News Article", [411] = "Delete News Article",
    [500] = "Connection Keep Alive",
}

local FIELD_NAMES = {
    [100] = "Error Text", [101] = "Data", [102] = "User Name", [103] = "User ID",
    [104] = "User Icon ID", [105] = "User Login", [106] = "User Password",
    [107] = "Reference Number", [108] = "Transfer Size", [109] = "Chat Options",
    [110] = "User Access", [111] = "User Alias", [112] = "User Flags", [113] = "Options",
    [114] = "Chat ID", [115] = "Chat Subject", [116] = "Waiting Count",
    [150] = "Server Agreement", [151] = "Server Banner", [152] = "Server Banner Type",
    [153] = "Server Banner URL", [154] = "No Server Agreement", [160] = "Version",
    [161] = "Community Banner ID", [162] = "Server Name", [200] = "File Name With Info",
    [201] = "File Name", [202] = "File Path", [203] = "File Resume Data",
    [204] = "File Transfer Options", [205] = "File Type String", [206] = "File Creator String",
    [207] = "File Size", [208] = "File Create Date", [209] = "File Modify Date",
    [210] = "File Comment", [211] = "File New Name", [212] = "File New Path",
    [213] = "File Type", [214] = "Quoting Message", [215] = "Automatic Response",
    [220] = "Folder Item Count", [300] = "User Name With Info", [319] = "News Category GUID",
    [320] = "News Category List Data (legacy format)", [321] = "News Article List Data",
    [322] = "News Category Name", [323] = "News Category List Data 1.5", [325] = "News Path",
    [326] = "News Article ID", [327] = "News Article Data Flavor", [328] = "News Article Title",
    [329] = "News Article Poster", [330] = "News Article Date", [331] = "News Article - Previous Article",
    [332] = "News Article - Next Article", [333] = "News Article Data", [334] = "News Article Flags",
    [335] = "News Article - Parent Article", [336] = "News Article - First Child Article",
    [337] = "News Article - Recursive Delete",
}

local ACCESS_NAMES = {
    [0] = { "delete_file", "Delete files" }, [1] = { "upload_file", "Upload files" },
    [2] = { "download_file", "Download files" }, [3] = { "rename_file", "Rename files" },
    [4] = { "move_file", "Move files" }, [5] = { "create_folder", "Create folders" },
    [6] = { "delete_folder", "Delete folders" }, [7] = { "rename_folder", "Rename folders" },
    [8] = { "move_folder", "Move folders" }, [9] = { "read_chat", "Read chat" },
    [10] = { "send_chat", "Send chat" }, [11] = { "open_chat", "Open private chat" },
    [12] = { "close_chat", "Close private chat" }, [13] = { "show_in_list", "Show in user list" },
    [14] = { "create_user", "Create user accounts" }, [15] = { "delete_user", "Delete user accounts" },
    [16] = { "open_user", "Read user accounts" }, [17] = { "modify_user", "Modify user accounts" },
    [18] = { "change_own_password", "Change own password" }, [20] = { "read_news", "Read news articles" },
    [21] = { "post_news", "Post news articles" }, [22] = { "disconnect_user", "Disconnect users" },
    [23] = { "cannot_be_disconnected", "Cannot be disconnected" },
    [24] = { "get_client_info", "Get client information" },
    [25] = { "upload_anywhere", "Upload anywhere" }, [26] = { "use_any_name", "Use any name" },
    [27] = { "skip_agreement", "Skip server agreement" },
    [28] = { "set_file_comment", "Set file comments" },
    [29] = { "set_folder_comment", "Set folder comments" },
    [30] = { "view_drop_boxes", "View drop boxes" }, [31] = { "make_alias", "Make aliases" },
    [32] = { "broadcast", "Broadcast messages" }, [33] = { "delete_news", "Delete news articles" },
    [34] = { "create_news_category", "Create news categories" },
    [35] = { "delete_news_category", "Delete news categories" },
    [36] = { "create_news_folder", "Create news folders" },
    [37] = { "delete_news_folder", "Delete news folders" },
    [38] = { "upload_folder", "Upload folders" }, [39] = { "download_folder", "Download folders" },
    [40] = { "send_private_message", "Send private messages" },
}

-- Existing field abbreviations are retained for display-filter compatibility.
local pf_flag = ProtoField.uint8("hotline.flag", "Flags", base.HEX)
local pf_is_reply = ProtoField.bool("hotline.is_reply", "Is Reply")
local pf_req_type = ProtoField.uint16("hotline.req_type", "Transaction Type", base.DEC, TRANSACTION_NAMES)
local pf_tran_id = ProtoField.uint32("hotline.tran_id", "Transaction ID", base.DEC)
local pf_error_code = ProtoField.uint32("hotline.error_code", "Error Code", base.DEC)
local pf_total_size = ProtoField.uint32("hotline.total_size", "Total Data Size", base.DEC)
local pf_data_size = ProtoField.uint32("hotline.data_size", "Part Data Size", base.DEC)
local pf_param_count = ProtoField.uint16("hotline.param_count", "Field Count", base.DEC)
local pf_field_type = ProtoField.uint16("hotline.field_type", "Field Type", base.DEC, FIELD_NAMES)
local pf_field_size = ProtoField.uint16("hotline.field_size", "Field Size", base.DEC)
local pf_field_data = ProtoField.bytes("hotline.field_data", "Field Data")
local pf_handshake_magic = ProtoField.string("hotline.handshake.magic", "Handshake Magic")
local pf_handshake_protocol = ProtoField.string("hotline.handshake.protocol", "Protocol")
local pf_handshake_subprotocol = ProtoField.string("hotline.handshake.subprotocol", "Sub-protocol")
local pf_handshake_version = ProtoField.uint16("hotline.handshake.version", "Version", base.DEC)
local pf_handshake_subversion = ProtoField.uint16("hotline.handshake.subversion", "Sub-version", base.DEC)
local pf_handshake_error = ProtoField.uint32("hotline.handshake.error", "Handshake Error", base.DEC)
local pf_type_name = ProtoField.string("hotline.transaction.name", "Transaction Name")
local pf_request_in = ProtoField.framenum("hotline.request_in", "Request In Frame")
local pf_response_in = ProtoField.framenum("hotline.response_in", "Response In Frame")
local pf_response_time = ProtoField.double("hotline.response_time", "Response Time")
local pf_fragment = ProtoField.bool("hotline.fragment", "Application Fragment")
local pf_fragment_count = ProtoField.uint32("hotline.fragment.count", "Fragment Count", base.DEC)
local pf_fragment_reassembled = ProtoField.bool("hotline.fragment.reassembled", "Reassembled")
local pf_trailing = ProtoField.bytes("hotline.trailing_data", "Trailing Data")
local pf_value_string = ProtoField.string("hotline.value.string", "String Value")
local pf_value_uint = ProtoField.uint32("hotline.value.uint", "Integer Value", base.DEC)
local pf_value_uint64 = ProtoField.uint64("hotline.value.uint64", "64-bit Integer Value", base.DEC)
local pf_decoded_credential = ProtoField.string("hotline.value.decoded_credential", "Decoded Credential")
local pf_username = ProtoField.string("hotline.user.name", "User Name")
local pf_user_login = ProtoField.string("hotline.user.login", "User Login")
local pf_user_id = ProtoField.uint32("hotline.user.id", "User ID", base.DEC)
local pf_user_icon = ProtoField.uint32("hotline.user.icon_id", "User Icon ID", base.DEC)
local pf_user_flags = ProtoField.uint16("hotline.user.flags", "User Flags", base.HEX)
local pf_user_away = ProtoField.bool("hotline.user.away", "Away")
local pf_user_admin = ProtoField.bool("hotline.user.admin", "Administrator")
local pf_user_refuse_pm = ProtoField.bool("hotline.user.refuse_pm", "Refuses Private Messages")
local pf_user_refuse_chat = ProtoField.bool("hotline.user.refuse_private_chat", "Refuses Private Chat")
local pf_option_refuse_pm = ProtoField.bool("hotline.user.option.refuse_pm", "Request Refuse Private Messages")
local pf_option_refuse_chat = ProtoField.bool("hotline.user.option.refuse_private_chat", "Request Refuse Private Chat")
local pf_option_auto_response = ProtoField.bool("hotline.user.option.auto_response", "Automatic Response Enabled")
local pf_chat_emote = ProtoField.bool("hotline.chat.emote", "Emote Chat Message")
local pf_reference = ProtoField.uint32("hotline.transfer.reference", "Transfer Reference", base.DEC)
local pf_transfer_size = ProtoField.uint32("hotline.transfer.size", "Transfer Size", base.DEC)
local pf_chat_id = ProtoField.uint32("hotline.chat.id", "Chat ID", base.DEC)
local pf_chat_subject = ProtoField.string("hotline.chat.subject", "Chat Subject")
local pf_server_name = ProtoField.string("hotline.server.name", "Server Name")
local pf_banner_type = ProtoField.string("hotline.server.banner_type", "Server Banner Type")
local pf_file_name = ProtoField.string("hotline.file.name", "File Name")
local pf_file_path = ProtoField.string("hotline.file.path", "File Path")
local pf_path_count = ProtoField.uint16("hotline.path.count", "Path Component Count", base.DEC)
local pf_path_item = ProtoField.string("hotline.path.item", "Path Component")
local pf_file_type = ProtoField.string("hotline.file.type", "File Type")
local pf_file_creator = ProtoField.string("hotline.file.creator", "File Creator")
local pf_file_size = ProtoField.uint32("hotline.file.size", "File Size", base.DEC)
local pf_file_comment = ProtoField.string("hotline.file.comment", "File Comment")
local pf_time_year = ProtoField.uint16("hotline.time.year", "Year", base.DEC)
local pf_time_millis = ProtoField.uint16("hotline.time.milliseconds", "Milliseconds", base.DEC)
local pf_time_mac = ProtoField.uint32("hotline.time.mac_seconds", "Seconds Since 1904-01-01", base.DEC)
local pf_time_iso = ProtoField.string("hotline.time.iso8601", "Time")
local pf_access_raw = ProtoField.bytes("hotline.access.raw", "Access Bitmap")
local pf_resume_format = ProtoField.string("hotline.resume.format", "Resume Format")
local pf_resume_version = ProtoField.uint16("hotline.resume.version", "Resume Version", base.DEC)
local pf_resume_fork_count = ProtoField.uint16("hotline.resume.fork_count", "Resume Fork Count", base.DEC)
local pf_resume_fork_type = ProtoField.string("hotline.resume.fork.type", "Fork Type")
local pf_resume_offset = ProtoField.uint32("hotline.resume.fork.offset", "Resume Offset", base.DEC)
local pf_news_path = ProtoField.string("hotline.news.path", "News Path")
local pf_news_id = ProtoField.uint32("hotline.news.article.id", "News Article ID", base.DEC)
local pf_news_parent_id = ProtoField.uint32("hotline.news.article.parent_id", "Parent Article ID", base.DEC)
local pf_news_flags = ProtoField.uint32("hotline.news.article.flags", "News Article Flags", base.HEX)
local pf_news_title = ProtoField.string("hotline.news.article.title", "News Article Title")
local pf_news_poster = ProtoField.string("hotline.news.article.poster", "News Article Poster")
local pf_news_flavor = ProtoField.string("hotline.news.article.flavor", "News Article Flavor")
local pf_news_data = ProtoField.string("hotline.news.article.data", "News Article Data")
local pf_news_category_type = ProtoField.uint16("hotline.news.category.type", "News Category Type", base.DEC)
local pf_news_legacy_category_type = ProtoField.uint8(
    "hotline.news.category.legacy_type", "Legacy News Category Type", base.DEC,
    { [1] = "Category Folder", [10] = "Category", [255] = "Other" }
)
local pf_news_category_count = ProtoField.uint16("hotline.news.category.count", "News Category Item Count", base.DEC)
local pf_news_category_name = ProtoField.string("hotline.news.category.name", "News Category Name")
local pf_news_category_guid = ProtoField.bytes("hotline.news.category.guid", "News Category GUID")
local pf_news_category_add_sn = ProtoField.uint32("hotline.news.category.add_sn", "News Category Add Serial", base.DEC)
local pf_news_category_delete_sn = ProtoField.uint32("hotline.news.category.delete_sn", "News Category Delete Serial", base.DEC)
local pf_news_list_id = ProtoField.uint32("hotline.news.list.id", "News Article List ID", base.DEC)
local pf_news_article_count = ProtoField.uint32("hotline.news.list.article_count", "News Article Count", base.DEC)
local pf_news_list_name = ProtoField.string("hotline.news.list.name", "News Article List Name")
local pf_news_list_description = ProtoField.string("hotline.news.list.description", "News Article List Description")
local pf_news_article_size = ProtoField.uint16("hotline.news.article.size", "News Article Size", base.DEC)

local hotline_fields = {
    pf_flag, pf_is_reply, pf_req_type, pf_tran_id, pf_error_code, pf_total_size, pf_data_size,
    pf_param_count, pf_field_type, pf_field_size, pf_field_data, pf_handshake_magic, pf_handshake_protocol,
    pf_handshake_subprotocol, pf_handshake_version, pf_handshake_subversion, pf_handshake_error,
    pf_type_name, pf_request_in, pf_response_in, pf_response_time, pf_fragment, pf_fragment_count,
    pf_fragment_reassembled, pf_trailing, pf_value_string, pf_value_uint, pf_value_uint64,
    pf_decoded_credential,
    pf_username, pf_user_login, pf_user_id, pf_user_icon, pf_user_flags, pf_user_away, pf_user_admin,
    pf_user_refuse_pm, pf_user_refuse_chat, pf_option_refuse_pm, pf_option_refuse_chat,
    pf_option_auto_response, pf_chat_emote, pf_reference, pf_transfer_size, pf_chat_id,
    pf_chat_subject, pf_server_name, pf_banner_type, pf_file_name, pf_file_path, pf_path_count, pf_path_item,
    pf_file_type, pf_file_creator, pf_file_size, pf_file_comment, pf_time_year, pf_time_millis,
    pf_time_mac, pf_time_iso, pf_access_raw, pf_resume_format, pf_resume_version,
    pf_resume_fork_count, pf_resume_fork_type, pf_resume_offset, pf_news_path, pf_news_id,
    pf_news_parent_id, pf_news_flags, pf_news_title, pf_news_poster, pf_news_flavor,
    pf_news_data, pf_news_category_type, pf_news_legacy_category_type, pf_news_category_count,
    pf_news_category_name,
    pf_news_category_guid, pf_news_category_add_sn, pf_news_category_delete_sn, pf_news_list_id,
    pf_news_article_count, pf_news_list_name, pf_news_list_description, pf_news_article_size,
}

local access_fields = {}
for bit_index, definition in pairs(ACCESS_NAMES) do
    local access_field = ProtoField.bool("hotline.access." .. definition[1], definition[2])
    access_fields[bit_index] = access_field
    hotline_fields[#hotline_fields + 1] = access_field
end
hotline.fields = hotline_fields

local ex_malformed = ProtoExpert.new(
    "hotline.expert.malformed", "Malformed Hotline data", expert.group.MALFORMED, expert.severity.ERROR
)
local ex_truncated = ProtoExpert.new(
    "hotline.expert.truncated", "Truncated Hotline data", expert.group.REASSEMBLE, expert.severity.WARN
)
local ex_unknown = ProtoExpert.new(
    "hotline.expert.unknown", "Unknown Hotline value", expert.group.UNDECODED, expert.severity.NOTE
)
local ex_credentials = ProtoExpert.new(
    "hotline.expert.credentials", "Obfuscated login credentials are present",
    expert.group.SECURITY, expert.severity.WARN
)
hotline.experts = { ex_malformed, ex_truncated, ex_unknown, ex_credentials }

hotline.prefs.tcp_ports = Pref.range("Command TCP ports", "5500", "TCP ports used for Hotline commands", MAX_PORT)
hotline.prefs.desegment = Pref.bool("Reassemble TCP streams", true, "Request TCP desegmentation for incomplete Hotline PDUs")
hotline.prefs.max_pdu_size = Pref.uint("Maximum PDU size", DEFAULT_MAX_PDU, "Reject larger declared PDUs")
hotline.prefs.decode_obfuscated_credentials = Pref.bool(
    "Decode obfuscated credentials", false, "Display the reversible Hotline login/password obfuscation"
)

local tcp_stream_field = Field.new("tcp.stream")
local stream_state = {}

local function add_generated(tree, field, value)
    local item = tree:add(field, value)
    item.generated = true
    return item
end

local function add_expert(item, expert_field, text)
    if item.add_proto_expert_info then
        item:add_proto_expert_info(expert_field, text)
    else
        item:add_expert_info(PI_MALFORMED, PI_WARN, text)
    end
end

local function range_text(range)
    if range:len() == 0 then return "" end
    return range:string()
end

local function stream_key(pinfo)
    local stream_info = tcp_stream_field()
    if stream_info then return "tcp:" .. tostring(stream_info) end

    local first = tostring(pinfo.src) .. ":" .. tostring(pinfo.src_port)
    local second = tostring(pinfo.dst) .. ":" .. tostring(pinfo.dst_port)
    if first < second then return first .. "-" .. second end
    return second .. "-" .. first
end

local function direction_key(pinfo)
    return tostring(pinfo.src) .. ":" .. tostring(pinfo.src_port) .. ">" ..
        tostring(pinfo.dst) .. ":" .. tostring(pinfo.dst_port)
end

local function frame_number(pinfo)
    return tonumber(tostring(pinfo.number)) or 0
end

local function frame_time(pinfo)
    local timestamp = pinfo.abs_ts
    if type(timestamp) == "number" then return timestamp end
    local ok, value = pcall(function() return timestamp and timestamp:tonumber() end)
    if ok and value then return value end
    return 0
end

local function transaction_key(pinfo, offset)
    return tostring(frame_number(pinfo)) .. ":" .. tostring(offset)
end

local function current_stream_state(pinfo)
    local key = stream_key(pinfo)
    local state = stream_state[key]
    if not state then
        state = { pending = {}, links = {}, fragments = {}, reply_types = {} }
        stream_state[key] = state
    end
    return state
end

local function integer_value(range)
    local length = range:len()
    if length >= 1 and length <= 4 then return range:uint() end
    return nil
end

local function bit_is_set(value, bit_index)
    return math.floor(value / (2 ^ bit_index)) % 2 == 1
end

local function decode_obfuscated(range)
    local raw = range:bytes():raw()
    local decoded = {}
    for index = 1, #raw do decoded[index] = string.char(255 - string.byte(raw, index)) end
    return table.concat(decoded)
end

local function add_time(tree, range)
    if range:len() ~= 8 then return false end
    tree:add(pf_time_year, range(0, 2))
    tree:add(pf_time_millis, range(2, 2))
    tree:add(pf_time_mac, range(4, 4))
    local unix_seconds = range(4, 4):uint() - MAC_EPOCH_DELTA
    local ok, formatted = pcall(os.date, "!%Y-%m-%dT%H:%M:%SZ", unix_seconds)
    if ok and formatted then add_generated(tree, pf_time_iso, formatted) end
    return true
end

-- File and news paths both use a uint16 count followed by entries containing
-- two reserved bytes, a one-byte length, and the path component.
local function decode_path(tree, range, output_field)
    if range:len() == 0 then
        add_generated(tree, output_field, "/")
        return true
    end
    if range:len() < 2 then return false end

    local count = range(0, 2):uint()
    tree:add(pf_path_count, range(0, 2))
    local cursor = 2
    local items = {}
    for _ = 1, count do
        if cursor + 3 > range:len() then return false end
        local item_length = range(cursor + 2, 1):uint()
        if cursor + 3 + item_length > range:len() then return false end
        local item_range = range(cursor + 3, item_length)
        local item_text = range_text(item_range)
        tree:add(pf_path_item, item_range)
        items[#items + 1] = item_text
        cursor = cursor + 3 + item_length
    end
    add_generated(tree, output_field, "/" .. table.concat(items, "/"))
    return cursor == range:len()
end

local function decode_user_records(tree, range)
    local cursor = 0
    local decoded = false
    while cursor < range:len() do
        if cursor + 8 > range:len() then return false end
        local name_length = range(cursor + 6, 2):uint()
        local record_length = 8 + name_length
        if cursor + record_length > range:len() then return false end

        local record = tree:add(hotline, range(cursor, record_length), "User")
        record:add(pf_user_id, range(cursor, 2))
        record:add(pf_user_icon, range(cursor + 2, 2))
        local flags_range = range(cursor + 4, 2)
        local flags = flags_range:uint()
        record:add(pf_user_flags, flags_range)
        add_generated(record, pf_user_away, bit_is_set(flags, 0))
        add_generated(record, pf_user_admin, bit_is_set(flags, 1))
        add_generated(record, pf_user_refuse_pm, bit_is_set(flags, 2))
        add_generated(record, pf_user_refuse_chat, bit_is_set(flags, 3))
        record:add(pf_username, range(cursor + 8, name_length))
        cursor = cursor + record_length
        decoded = true
    end
    return decoded
end

local function decode_file_info(tree, range)
    if range:len() < 20 then return false end
    local name_length = range(18, 2):uint()
    if 20 + name_length > range:len() then return false end
    tree:add(pf_file_type, range(0, 4))
    tree:add(pf_file_creator, range(4, 4))
    tree:add(pf_file_size, range(8, 4))
    tree:add(pf_file_name, range(20, name_length))
    return true
end

local function decode_access(tree, range)
    if range:len() ~= 8 then return false end
    tree:add(pf_access_raw, range)
    local raw = range:bytes():raw()
    for bit_index, access_field in pairs(access_fields) do
        local byte_index = math.floor(bit_index / 8) + 1
        local bit_in_byte = 7 - (bit_index % 8)
        local byte_value = string.byte(raw, byte_index)
        add_generated(tree, access_field, bit_is_set(byte_value, bit_in_byte))
    end
    return true
end

local function decode_resume_data(tree, range)
    if range:len() < 42 then return false end
    tree:add(pf_resume_format, range(0, 4))
    tree:add(pf_resume_version, range(4, 2))
    if range_text(range(0, 4)) ~= "RFLT" then
        add_expert(tree, ex_malformed, "File resume data does not begin with RFLT")
        return false
    end
    if range(4, 2):uint() ~= 1 then add_expert(tree, ex_unknown, "Unknown RFLT version") end
    local fork_count = range(40, 2):uint()
    tree:add(pf_resume_fork_count, range(40, 2))
    if 42 + fork_count * 16 > range:len() then return false end
    local cursor = 42
    for _ = 1, fork_count do
        local fork = tree:add(hotline, range(cursor, 16), "Resume Fork")
        fork:add(pf_resume_fork_type, range(cursor, 4))
        fork:add(pf_resume_offset, range(cursor + 4, 4))
        cursor = cursor + 16
    end
    return true
end

local function decode_news_article_list(tree, range)
    if range:len() < 10 then return false end
    tree:add(pf_news_list_id, range(0, 4))
    local article_count = range(4, 4):uint()
    tree:add(pf_news_article_count, range(4, 4))
    local cursor = 8

    local name_length = range(cursor, 1):uint(); cursor = cursor + 1
    if cursor + name_length + 1 > range:len() then return false end
    tree:add(pf_news_list_name, range(cursor, name_length)); cursor = cursor + name_length
    local description_length = range(cursor, 1):uint(); cursor = cursor + 1
    if cursor + description_length > range:len() then return false end
    tree:add(pf_news_list_description, range(cursor, description_length))
    cursor = cursor + description_length

    for index = 1, article_count do
        if cursor + 23 > range:len() then return false end
        local record_start = cursor
        local article_id = range(cursor, 4):uint(); cursor = cursor + 4
        local timestamp_range = range(cursor, 8)
        cursor = cursor + 8
        local parent_id = range(cursor, 4):uint(); cursor = cursor + 4
        local flags = range(cursor, 4):uint(); cursor = cursor + 4
        local flavor_count = range(cursor, 2):uint(); cursor = cursor + 2

        local title_length = range(cursor, 1):uint(); cursor = cursor + 1
        if cursor + title_length + 1 > range:len() then return false end
        local title_range = range(cursor, title_length); cursor = cursor + title_length
        local poster_length = range(cursor, 1):uint(); cursor = cursor + 1
        if cursor + poster_length > range:len() then return false end
        local poster_range = range(cursor, poster_length); cursor = cursor + poster_length

        local article_tree = tree:add(hotline, range(record_start, cursor - record_start),
            string.format("News Article %d", index))
        add_generated(article_tree, pf_news_id, article_id)
        add_time(article_tree, timestamp_range)
        add_generated(article_tree, pf_news_parent_id, parent_id)
        add_generated(article_tree, pf_news_flags, flags)
        article_tree:add(pf_news_title, title_range)
        article_tree:add(pf_news_poster, poster_range)
        for _ = 1, flavor_count do
            if cursor + 1 > range:len() then return false end
            local flavor_length = range(cursor, 1):uint(); cursor = cursor + 1
            if cursor + flavor_length + 2 > range:len() then return false end
            article_tree:add(pf_news_flavor, range(cursor, flavor_length))
            cursor = cursor + flavor_length
            article_tree:add(pf_news_article_size, range(cursor, 2))
            cursor = cursor + 2
        end
        article_tree.len = cursor - record_start
    end
    return cursor == range:len()
end

local function decode_legacy_news_category(tree, range)
    if range:len() < 1 then return false end
    local category_type = range(0, 1):uint()
    tree:add(pf_news_legacy_category_type, range(0, 1))
    if category_type ~= 1 and category_type ~= 10 and category_type ~= 255 then
        add_expert(tree, ex_unknown, "Unknown legacy news category type")
    end
    if range:len() > 1 then tree:add(pf_news_category_name, range(1)) end
    return true
end

local function decode_news_category(tree, range)
    if range:len() < 5 then return false end
    local category_type = range(0, 2):uint()
    tree:add(pf_news_category_type, range(0, 2))
    tree:add(pf_news_category_count, range(2, 2))
    local cursor = 4
    if category_type ~= 2 and category_type ~= 3 then
        add_expert(tree, ex_unknown, "Unknown threaded news category type")
    end
    -- Type 3 is a category and carries GUID/add/delete serial numbers.
    if category_type == 3 then
        if cursor + 24 > range:len() then return false end
        tree:add(pf_news_category_guid, range(cursor, 16)); cursor = cursor + 16
        tree:add(pf_news_category_add_sn, range(cursor, 4)); cursor = cursor + 4
        tree:add(pf_news_category_delete_sn, range(cursor, 4)); cursor = cursor + 4
    end
    if cursor + 1 > range:len() then return false end
    local name_length = range(cursor, 1):uint(); cursor = cursor + 1
    if cursor + name_length > range:len() then return false end
    tree:add(pf_news_category_name, range(cursor, name_length))
    return true
end

local STRING_FIELDS = {
    [100] = true, [101] = true, [102] = true, [105] = true, [106] = true,
    [111] = true, [115] = true, [150] = true, [153] = true,
    [162] = true, [201] = true, [205] = true, [206] = true, [210] = true,
    [211] = true, [214] = true, [215] = true, [322] = true, [327] = true,
    [328] = true, [329] = true, [333] = true, [213] = true,
}

local INTEGER_FIELDS = {
    [103] = true, [104] = true, [107] = true, [108] = true, [109] = true,
    [112] = true, [113] = true, [114] = true, [116] = true, [152] = true,
    [154] = true, [160] = true, [161] = true, [204] = true, [207] = true,
    [220] = true, [326] = true, [331] = true, [332] = true,
    [334] = true, [335] = true, [336] = true, [337] = true,
}

local function add_specialized_integer(tree, field_id, value)
    if field_id == 103 then add_generated(tree, pf_user_id, value)
    elseif field_id == 104 then add_generated(tree, pf_user_icon, value)
    elseif field_id == 107 then add_generated(tree, pf_reference, value)
    elseif field_id == 108 then add_generated(tree, pf_transfer_size, value)
    elseif field_id == 114 then add_generated(tree, pf_chat_id, value)
    elseif field_id == 207 then add_generated(tree, pf_file_size, value)
    elseif field_id == 326 then add_generated(tree, pf_news_id, value)
    elseif field_id == 334 then add_generated(tree, pf_news_flags, value)
    elseif field_id == 335 then add_generated(tree, pf_news_parent_id, value)
    end
end

local parse_parameter_payload

local function decode_field_value(tree, range, field_id, opcode, nested)
    if field_id == 101 and (opcode == 348 or opcode == 349) and not nested then
        return parse_parameter_payload(range:tvb(), tree, opcode, true)
    end
    if field_id == 110 then return decode_access(tree, range)
    elseif field_id == 152 and range:len() == 4 then
        tree:add(pf_banner_type, range)
        return true
    elseif field_id == 200 then return decode_file_info(tree, range)
    elseif field_id == 202 or field_id == 212 then return decode_path(tree, range, pf_file_path)
    elseif field_id == 203 then return decode_resume_data(tree, range)
    elseif field_id == 208 or field_id == 209 or field_id == 330 then return add_time(tree, range)
    elseif field_id == 300 then return decode_user_records(tree, range)
    elseif field_id == 320 then return decode_legacy_news_category(tree, range)
    elseif field_id == 321 then return decode_news_article_list(tree, range)
    elseif field_id == 323 then return decode_news_category(tree, range)
    elseif field_id == 325 then return decode_path(tree, range, pf_news_path)
    end

    if STRING_FIELDS[field_id] then
        local text = range_text(range)
        tree:add(pf_value_string, range)
        if field_id == 102 then tree:add(pf_username, range)
        elseif field_id == 105 then tree:add(pf_user_login, range)
        elseif field_id == 115 then tree:add(pf_chat_subject, range)
        elseif field_id == 162 then tree:add(pf_server_name, range)
        elseif field_id == 201 or field_id == 211 then tree:add(pf_file_name, range)
        elseif field_id == 205 or field_id == 213 then tree:add(pf_file_type, range)
        elseif field_id == 206 then tree:add(pf_file_creator, range)
        elseif field_id == 210 then tree:add(pf_file_comment, range)
        elseif field_id == 328 then tree:add(pf_news_title, range)
        elseif field_id == 329 then tree:add(pf_news_poster, range)
        elseif field_id == 327 then tree:add(pf_news_flavor, range)
        elseif field_id == 333 then tree:add(pf_news_data, range)
        end

        if field_id == 105 or field_id == 106 then
            add_expert(tree, ex_credentials, "Hotline credentials use reversible byte obfuscation")
            -- Account lookup (352) sends the login in clear text.
            if hotline.prefs.decode_obfuscated_credentials and not (field_id == 105 and opcode == 352) then
                add_generated(tree, pf_decoded_credential, decode_obfuscated(range))
            elseif hotline.prefs.decode_obfuscated_credentials then
                add_generated(tree, pf_decoded_credential, text)
            end
        end
        return true
    end

    if INTEGER_FIELDS[field_id] then
        if range:len() == 8 and range.uint64 then
            tree:add(pf_value_uint64, range)
            return true
        end
        local value = integer_value(range)
        if value ~= nil then
            add_generated(tree, pf_value_uint, value)
            add_specialized_integer(tree, field_id, value)
            if field_id == 109 and opcode == 105 then
                add_generated(tree, pf_chat_emote, value == 1)
            elseif field_id == 112 then
                add_generated(tree, pf_user_away, bit_is_set(value, 0))
                add_generated(tree, pf_user_admin, bit_is_set(value, 1))
                add_generated(tree, pf_user_refuse_pm, bit_is_set(value, 2))
                add_generated(tree, pf_user_refuse_chat, bit_is_set(value, 3))
            elseif field_id == 113 and opcode == 107 then
                add_generated(tree, pf_option_refuse_pm, bit_is_set(value, 0))
                add_generated(tree, pf_option_refuse_chat, bit_is_set(value, 1))
                add_generated(tree, pf_option_auto_response, bit_is_set(value, 2))
            end
            return true
        end
    end
    return false
end

parse_parameter_payload = function(payload_tvb, transaction_tree, opcode, nested)
    local payload_length = payload_tvb:len()
    if payload_length == 0 then return true end
    if payload_length < 2 then
        add_expert(transaction_tree, ex_malformed, "Transaction payload is missing the field count")
        return false
    end

    local parameter_count = payload_tvb(0, 2):uint()
    transaction_tree:add(pf_param_count, payload_tvb(0, 2))
    local cursor = 2
    for index = 1, parameter_count do
        if cursor + 4 > payload_length then
            add_expert(transaction_tree, ex_malformed,
                string.format("Field %d header exceeds transaction payload", index))
            return false
        end

        local field_id = payload_tvb(cursor, 2):uint()
        local field_length = payload_tvb(cursor + 2, 2):uint()
        local record_length = 4 + field_length
        if cursor + record_length > payload_length then
            add_expert(transaction_tree, ex_malformed,
                string.format("Field %d declares %d bytes but only %d remain", index, field_length,
                    payload_length - cursor - 4))
            return false
        end

        local name = FIELD_NAMES[field_id] or string.format("Unknown Field (%d)", field_id)
        local field_tree = transaction_tree:add(hotline, payload_tvb(cursor, record_length), name)
        field_tree:add(pf_field_type, payload_tvb(cursor, 2))
        field_tree:add(pf_field_size, payload_tvb(cursor + 2, 2))
        local value_range = payload_tvb(cursor + 4, field_length)
        field_tree:add(pf_field_data, value_range)
        if not decode_field_value(field_tree, value_range, field_id, opcode, nested) and not FIELD_NAMES[field_id] then
            add_expert(field_tree, ex_unknown, string.format("Unknown Hotline field ID %d", field_id))
        end
        cursor = cursor + record_length
    end

    if cursor < payload_length then
        local trailing_range = payload_tvb(cursor, payload_length - cursor)
        transaction_tree:add(pf_trailing, trailing_range)
        add_expert(transaction_tree, ex_unknown,
            string.format("%d unparsed payload bytes follow the declared fields", payload_length - cursor))
    end
    return true
end

local function correlate_transaction(pinfo, offset, is_reply, transaction_id, opcode)
    local state = current_stream_state(pinfo)
    local key = transaction_key(pinfo, offset)
    local frame = frame_number(pinfo)
    local timestamp = frame_time(pinfo)

    if not pinfo.visited then
        if is_reply == 0 and transaction_id ~= 0 and opcode ~= 0 then
            local request = state.pending[transaction_id]
            if not request then
                request = { frame = frame, time = timestamp, opcode = opcode, key = key }
                state.pending[transaction_id] = request
            end
            state.links[key] = request
        elseif is_reply == 1 and transaction_id ~= 0 then
            local request = state.pending[transaction_id]
            if request then
                local response = {
                    frame = frame, time = timestamp, opcode = request.opcode,
                    key = key, request = request,
                }
                request.response = response
                state.links[key] = response
                state.reply_types[transaction_id] = request.opcode
                state.pending[transaction_id] = nil
            elseif state.reply_types[transaction_id] then
                state.links[key] = {
                    frame = frame, time = timestamp, opcode = state.reply_types[transaction_id], key = key,
                }
            end
        end
    end

    local link = state.links[key]
    if is_reply == 1 and link and link.opcode then return link.opcode, link end
    if is_reply == 1 and state.reply_types[transaction_id] then
        return state.reply_types[transaction_id], link
    end
    return opcode, link
end

local function add_correlation_fields(tree, is_reply, link)
    if not link then return end
    if is_reply == 0 and link.response then
        add_generated(tree, pf_response_in, link.response.frame)
    elseif is_reply == 1 and link.request then
        add_generated(tree, pf_request_in, link.request.frame)
        add_generated(tree, pf_response_time, math.max(0, link.time - link.request.time))
    end
end

local function reassembled_payload(pinfo, offset, transaction_id, is_reply, opcode, total_size, data_range)
    local state = current_stream_state(pinfo)
    local fragment_key = direction_key(pinfo) .. ":" .. tostring(transaction_id) .. ":" ..
        tostring(is_reply) .. ":" .. tostring(opcode)
    local fragment = state.fragments[fragment_key]
    local frame_key = transaction_key(pinfo, offset)

    if not pinfo.visited then
        if not fragment or fragment.complete or fragment.total ~= total_size then
            fragment = { total = total_size, received = 0, count = 0, hex = "" }
            state.fragments[fragment_key] = fragment
        end
        fragment.hex = fragment.hex .. data_range:bytes():tohex(false, "")
        fragment.received = fragment.received + data_range:len()
        fragment.count = fragment.count + 1
        if fragment.received >= fragment.total then
            fragment.complete = fragment.received == fragment.total
            fragment.overflow = fragment.received > fragment.total
            fragment.complete_key = frame_key
        end
    end

    fragment = state.fragments[fragment_key]
    if fragment and fragment.complete and fragment.complete_key == frame_key and ByteArray then
        return ByteArray.new(fragment.hex):tvb("Reassembled Hotline transaction"), fragment.count, true, false
    end
    return nil, fragment and fragment.count or 1, false, fragment and fragment.overflow or false
end

local function dissect_handshake(buffer, tree, offset, length)
    local range = buffer(offset, length)
    local subtree = tree:add(hotline, range, "Hotline Handshake")
    subtree:add(pf_handshake_magic, buffer(offset, 4))
    subtree:add(pf_handshake_protocol, buffer(offset, 4))
    if length == 12 then
        subtree:add(pf_handshake_subprotocol, buffer(offset + 4, 4))
        subtree:add(pf_handshake_version, buffer(offset + 8, 2))
        subtree:add(pf_handshake_subversion, buffer(offset + 10, 2))
        if range_text(buffer(offset + 4, 4)) ~= "HOTL" then
            add_expert(subtree, ex_unknown, "Unknown TRTP sub-protocol")
        end
        return "Client Handshake"
    end
    subtree:add(pf_handshake_error, buffer(offset + 4, 4))
    return buffer(offset + 4, 4):uint() == 0 and "Server Handshake" or "Server Handshake (rejected)"
end

local function dissect_transaction(buffer, pinfo, tree, offset, pdu_length)
    local pdu_range = buffer(offset, pdu_length)
    local is_reply = buffer(offset + 1, 1):uint()
    local opcode = buffer(offset + 2, 2):uint()
    local transaction_id = buffer(offset + 4, 4):uint()
    local total_size = buffer(offset + 12, 4):uint()
    local data_size = buffer(offset + 16, 4):uint()

    local effective_opcode, link = correlate_transaction(pinfo, offset, is_reply, transaction_id, opcode)
    local transaction_name = TRANSACTION_NAMES[effective_opcode] or string.format("Unknown (%d)", effective_opcode)
    local direction = is_reply == 1 and "Reply" or "Transaction"
    local subtree = tree:add(hotline, pdu_range, string.format("Hotline %s: %s", direction, transaction_name))
    subtree:add(pf_flag, buffer(offset, 1))
    subtree:add(pf_is_reply, buffer(offset + 1, 1))
    subtree:add(pf_req_type, buffer(offset + 2, 2))
    add_generated(subtree, pf_type_name, transaction_name)
    subtree:add(pf_tran_id, buffer(offset + 4, 4))
    subtree:add(pf_error_code, buffer(offset + 8, 4))
    subtree:add(pf_total_size, buffer(offset + 12, 4))
    subtree:add(pf_data_size, buffer(offset + 16, 4))
    add_correlation_fields(subtree, is_reply, link)

    if buffer(offset, 1):uint() ~= 0 then
        add_expert(subtree, ex_unknown, "Transaction flag byte is reserved and normally zero")
    end
    if is_reply > 1 then add_expert(subtree, ex_malformed, "Is Reply must be zero or one") end
    if total_size < data_size then
        add_expert(subtree, ex_malformed, "Part data size exceeds total transaction data size")
    end
    if not TRANSACTION_NAMES[effective_opcode] then
        add_expert(subtree, ex_unknown, string.format("Unknown transaction type %d", effective_opcode))
    elseif effective_opcode >= 294 and effective_opcode <= 296 then
        add_expert(subtree, ex_unknown,
            "This transaction is an unverified extension with no published field schema")
    end

    if data_size > 0 then
        local data_range = buffer(offset + 20, data_size)
        if total_size > data_size then
            add_generated(subtree, pf_fragment, true)
            local payload_tvb, fragment_count, complete, overflow = reassembled_payload(
                pinfo, offset, transaction_id, is_reply, effective_opcode, total_size, data_range
            )
            add_generated(subtree, pf_fragment_count, fragment_count)
            add_generated(subtree, pf_fragment_reassembled, complete)
            if overflow then
                add_expert(subtree, ex_malformed, "Application fragments exceed the declared total size")
            elseif payload_tvb then
                parse_parameter_payload(payload_tvb, subtree, effective_opcode)
            else
                subtree:add(pf_field_data, data_range)
            end
        else
            local payload_tvb = data_range:tvb()
            parse_parameter_payload(payload_tvb, subtree, effective_opcode)
        end
    end

    local summary_prefix = is_reply == 1 and "Reply" or "Request"
    if is_reply == 1 and buffer(offset + 8, 4):uint() ~= 0 then summary_prefix = "Error Reply" end
    return string.format("%s: %s, id=%d", summary_prefix, transaction_name, transaction_id)
end

local function command_pdu_length(buffer, offset)
    local remaining = buffer:len() - offset
    if remaining < 4 then return nil, 4 - remaining end

    if range_text(buffer(offset, 4)) == "TRTP" then
        if remaining < 8 then return nil, 8 - remaining end
        if range_text(buffer(offset + 4, 4)) == "HOTL" then
            if remaining < 12 then return nil, 12 - remaining end
            return 12, 0
        end
        return 8, 0
    end

    if remaining < 20 then return nil, 20 - remaining end
    local total_size = buffer(offset + 12, 4):uint()
    local data_size = buffer(offset + 16, 4):uint()
    if total_size > hotline.prefs.max_pdu_size or data_size > hotline.prefs.max_pdu_size then return -1, 0 end
    local length = 20 + data_size
    if remaining < length then return nil, length - remaining end
    return length, 0
end

local function looks_like_hotline(buffer)
    if buffer:len() >= 4 and range_text(buffer(0, 4)) == "TRTP" then return true end
    if buffer:len() < 20 then return false end
    local flags = buffer(0, 1):uint()
    local reply = buffer(1, 1):uint()
    local opcode = buffer(2, 2):uint()
    local total_size = buffer(12, 4):uint()
    local data_size = buffer(16, 4):uint()
    return flags == 0 and reply <= 1 and data_size <= total_size and
        total_size <= hotline.prefs.max_pdu_size and data_size <= hotline.prefs.max_pdu_size and
        (TRANSACTION_NAMES[opcode] ~= nil or reply == 1)
end

function hotline.dissector(buffer, pinfo, tree)
    if buffer:len() == 0 then return 0 end
    pinfo.cols.protocol = "HOTL"
    local offset = 0
    local summaries = {}
    while offset < buffer:len() do
        local pdu_length, missing = command_pdu_length(buffer, offset)
        if not pdu_length then
            if hotline.prefs.desegment and buffer:len() == buffer:reported_len() then
                pinfo.desegment_offset = offset
                pinfo.desegment_len = missing
                return buffer:len()
            end
            local truncated = tree:add(hotline, buffer(offset), "Truncated Hotline PDU")
            add_expert(truncated, ex_truncated, string.format("Need %d more bytes", missing))
            break
        elseif pdu_length < 0 then
            local malformed = tree:add(hotline, buffer(offset), "Malformed Hotline PDU")
            add_expert(malformed, ex_malformed, "Declared PDU exceeds the configured maximum")
            break
        end

        if range_text(buffer(offset, 4)) == "TRTP" then
            summaries[#summaries + 1] = dissect_handshake(buffer, tree, offset, pdu_length)
        else
            summaries[#summaries + 1] = dissect_transaction(buffer, pinfo, tree, offset, pdu_length)
        end
        offset = offset + pdu_length
    end

    if #summaries > 0 then pinfo.cols.info = table.concat(summaries, ", ") end
    return buffer:len()
end

function hotline.init() stream_state = {} end

hotline:register_heuristic("tcp", function(buffer, pinfo, tree)
    if not looks_like_hotline(buffer) then return false end
    hotline.dissector(buffer, pinfo, tree)
    return true
end)

-- File transfer protocol -----------------------------------------------------

do

local TRANSFER_TYPES = { [0] = "File", [1] = "Folder", [2] = "Banner" }
local FOLDER_ACTIONS = { [1] = "Send File", [2] = "Resume File", [3] = "Next File" }

local xf_protocol = ProtoField.string("htxf.protocol", "Protocol")
local xf_reference = ProtoField.uint32("htxf.reference", "Reference Number", base.DEC)
local xf_data_size = ProtoField.uint32("htxf.data_size", "Data Size", base.DEC)
local xf_type = ProtoField.uint16("htxf.type", "Transfer Type", base.DEC, TRANSFER_TYPES)
local xf_reserved = ProtoField.uint16("htxf.reserved", "Reserved", base.HEX)
local xf_action = ProtoField.uint16("htxf.folder.action", "Folder Action", base.DEC, FOLDER_ACTIONS)
local xf_header_size = ProtoField.uint16("htxf.folder.header_size", "Folder Header Size", base.DEC)
local xf_is_folder = ProtoField.bool("htxf.folder.is_folder", "Is Folder")
local xf_filp_format = ProtoField.string("htxf.filp.format", "Flattened File Format")
local xf_filp_version = ProtoField.uint16("htxf.filp.version", "Version", base.DEC)
local xf_filp_fork_count = ProtoField.uint16("htxf.filp.fork_count", "Fork Count", base.DEC)
local xf_fork_type = ProtoField.string("htxf.fork.type", "Fork Type")
local xf_fork_compression = ProtoField.uint32("htxf.fork.compression", "Compression", base.DEC)
local xf_fork_size = ProtoField.uint32("htxf.fork.size", "Fork Data Size", base.DEC)
local xf_object_size = ProtoField.uint32("htxf.object_size", "Flattened File Object Size", base.DEC)
local xf_fork_data = ProtoField.bytes("htxf.fork.data", "Fork Data")
local xf_platform = ProtoField.string("htxf.info.platform", "Platform")
local xf_file_type = ProtoField.string("htxf.info.file_type", "File Type")
local xf_creator = ProtoField.string("htxf.info.creator", "Creator")
local xf_finder_flags = ProtoField.uint32("htxf.info.finder_flags", "Finder Flags", base.HEX)
local xf_platform_flags = ProtoField.uint32("htxf.info.platform_flags", "Platform Flags", base.HEX)
local xf_name = ProtoField.string("htxf.info.name", "File Name")
local xf_comment = ProtoField.string("htxf.info.comment", "Comment")
local xf_payload = ProtoField.bytes("htxf.payload", "Transfer Payload")

htxf.fields = {
    xf_protocol, xf_reference, xf_data_size, xf_type, xf_reserved, xf_action, xf_header_size,
    xf_is_folder, xf_filp_format, xf_filp_version, xf_filp_fork_count, xf_fork_type,
    xf_fork_compression, xf_fork_size, xf_object_size, xf_fork_data, xf_platform, xf_file_type, xf_creator,
    xf_finder_flags, xf_platform_flags, xf_name, xf_comment, xf_payload,
}

local xf_malformed = ProtoExpert.new(
    "htxf.expert.malformed", "Malformed file transfer data", expert.group.MALFORMED, expert.severity.ERROR
)
local xf_unsupported = ProtoExpert.new(
    "htxf.expert.unsupported", "Unsupported file transfer feature", expert.group.UNDECODED, expert.severity.WARN
)
local xf_truncated = ProtoExpert.new(
    "htxf.expert.truncated", "Truncated file transfer header", expert.group.REASSEMBLE, expert.severity.WARN
)
htxf.experts = { xf_malformed, xf_unsupported, xf_truncated }
htxf.prefs.tcp_ports = Pref.range("Transfer TCP ports", "5501", "TCP ports used for Hotline transfers", MAX_PORT)
htxf.prefs.desegment = Pref.bool("Reassemble transfer headers", true, "Request TCP desegmentation for incomplete transfer headers")
htxf.prefs.max_info_size = Pref.uint("Maximum INFO fork size", 131144, "Reject larger INFO metadata forks")

local function request_more(buffer, pinfo, tree, proto, expert_field, needed, label)
    if buffer:len() == buffer:reported_len() and pinfo.can_desegment ~= 0 then
        pinfo.desegment_offset = 0
        pinfo.desegment_len = needed
        return true
    end
    local item = tree:add(proto, buffer(), label)
    add_expert(item, expert_field, string.format("Need %d more bytes", needed))
    return false
end

local function dissect_info_fork(range, tree)
    if range:len() < 72 then
        add_expert(tree, xf_malformed, "INFO fork is shorter than its fixed 72-byte header")
        return false
    end
    tree:add(xf_platform, range(0, 4))
    tree:add(xf_file_type, range(4, 4))
    tree:add(xf_creator, range(8, 4))
    tree:add(xf_finder_flags, range(12, 4))
    tree:add(xf_platform_flags, range(16, 4))
    add_time(tree, range(52, 8))
    add_time(tree, range(60, 8))
    local name_length = range(70, 2):uint()
    local cursor = 72
    if cursor + name_length > range:len() then
        add_expert(tree, xf_malformed, "INFO fork file name exceeds the fork data")
        return false
    end
    tree:add(xf_name, range(cursor, name_length))
    cursor = cursor + name_length
    if cursor + 2 <= range:len() then
        local comment_length = range(cursor, 2):uint()
        cursor = cursor + 2
        if cursor + comment_length <= range:len() then
            tree:add(xf_comment, range(cursor, comment_length))
        elseif comment_length ~= 0 then
            add_expert(tree, xf_malformed, "INFO fork comment exceeds the fork data")
        end
    end
    return true
end

local function dissect_filp(buffer, pinfo, tree)
    if buffer:len() < 24 then
        if htxf.prefs.desegment then request_more(buffer, pinfo, tree, htxf, xf_truncated, 24 - buffer:len(), "Truncated FILP Header") end
        return buffer:len(), "Flattened File (partial)"
    end

    local fork_count = buffer(22, 2):uint()
    local root = tree:add(htxf, buffer(), "Flattened File Object")
    root:add(xf_filp_format, buffer(0, 4))
    root:add(xf_filp_version, buffer(4, 2))
    root:add(xf_filp_fork_count, buffer(22, 2))
    if buffer(4, 2):uint() ~= 1 then add_expert(root, xf_unsupported, "Unknown FILP version") end

    local cursor = 24
    for fork_index = 1, fork_count do
        if cursor + 16 > buffer:len() then
            add_expert(root, xf_truncated, string.format("Fork %d header is not captured", fork_index))
            break
        end
        local fork_size = buffer(cursor + 12, 4):uint()
        local captured_size = math.min(fork_size, buffer:len() - cursor - 16)
        local fork_tree = root:add(htxf, buffer(cursor, 16 + captured_size),
            string.format("Fork %d: %s", fork_index, range_text(buffer(cursor, 4))))
        fork_tree:add(xf_fork_type, buffer(cursor, 4))
        fork_tree:add(xf_fork_compression, buffer(cursor + 4, 4))
        fork_tree:add(xf_fork_size, buffer(cursor + 12, 4))
        if buffer(cursor + 4, 4):uint() ~= 0 then
            add_expert(fork_tree, xf_unsupported, "Compressed Hotline forks are not documented")
        end
        if captured_size > 0 then
            local data_range = buffer(cursor + 16, captured_size)
            fork_tree:add(xf_fork_data, data_range)
            if range_text(buffer(cursor, 4)) == "INFO" then
                if fork_size > htxf.prefs.max_info_size then
                    add_expert(fork_tree, xf_malformed, "INFO fork exceeds the configured maximum")
                elseif captured_size == fork_size then
                    dissect_info_fork(data_range, fork_tree)
                else
                    add_expert(fork_tree, xf_truncated, "INFO fork data spans additional TCP segments")
                end
            end
        end
        if captured_size < fork_size then break end
        cursor = cursor + 16 + fork_size
    end
    return buffer:len(), "Flattened File"
end

local function looks_like_folder_header(buffer)
    if buffer:len() < 4 then return false end
    local size = buffer(0, 2):uint()
    local item_type = buffer(2, 2):uint()
    return size >= 2 and size + 2 <= buffer:len() and item_type <= 1
end

function htxf.dissector(buffer, pinfo, tree)
    if buffer:len() == 0 then return 0 end
    pinfo.cols.protocol = "HTXF"
    if buffer:len() < 4 then
        if htxf.prefs.desegment then request_more(buffer, pinfo, tree, htxf, xf_truncated, 4 - buffer:len(), "Truncated Transfer Data") end
        return buffer:len()
    end

    local magic = range_text(buffer(0, 4))
    if magic == "HTXF" then
        if buffer:len() < 16 then
            if htxf.prefs.desegment then request_more(buffer, pinfo, tree, htxf, xf_truncated, 16 - buffer:len(), "Truncated HTXF Preamble") end
            return buffer:len()
        end
        local root = tree:add(htxf, buffer(0, 16), "Hotline Transfer Preamble")
        root:add(xf_protocol, buffer(0, 4))
        root:add(xf_reference, buffer(4, 4))
        root:add(xf_data_size, buffer(8, 4))
        root:add(xf_type, buffer(12, 2))
        root:add(xf_reserved, buffer(14, 2))
        if not TRANSFER_TYPES[buffer(12, 2):uint()] then add_expert(root, xf_unsupported, "Unknown transfer type") end
        local preamble_length = 16
        if buffer:len() >= 18 and buffer(12, 2):uint() == 1 and FOLDER_ACTIONS[buffer(16, 2):uint()] then
            root:add(xf_action, buffer(16, 2))
            preamble_length = 18
        end
        if preamble_length < buffer:len() then
            local tail = buffer(preamble_length):tvb()
            local tail_magic = tail:len() >= 4 and range_text(tail(0, 4)) or ""
            if tail_magic == "FILP" then
                dissect_filp(tail, pinfo, tree)
            elseif tail_magic == "RFLT" then
                local resume_tree = tree:add(htxf, buffer(preamble_length), "File Resume Data")
                if not decode_resume_data(resume_tree, buffer(preamble_length)) then
                    add_expert(resume_tree, xf_malformed, "Invalid RFLT resume data")
                end
            else
                tree:add(xf_payload, buffer(preamble_length))
            end
        end
        pinfo.cols.info = string.format("Transfer %s, ref=%d", TRANSFER_TYPES[buffer(12, 2):uint()] or "Unknown", buffer(4, 4):uint())
    elseif magic == "FILP" then
        local _, summary = dissect_filp(buffer, pinfo, tree)
        pinfo.cols.info = summary
    elseif magic == "RFLT" then
        local root = tree:add(htxf, buffer(), "File Resume Data")
        if not decode_resume_data(root, buffer()) then add_expert(root, xf_malformed, "Invalid RFLT resume data") end
        pinfo.cols.info = "File Resume Data"
    elseif buffer:len() >= 8 and range_text(buffer(4, 4)) == "FILP" then
        local declared_size = buffer(0, 4):uint()
        local root = tree:add(htxf, buffer(0, 4), "Flattened File Size")
        root:add(xf_object_size, buffer(0, 4))
        dissect_filp(buffer(4):tvb(), pinfo, tree)
        if declared_size ~= buffer:len() - 4 then
            add_expert(root, xf_truncated, string.format(
                "Declared flattened file size is %d bytes; %d bytes are captured", declared_size, buffer:len() - 4))
        end
        pinfo.cols.info = "Flattened File"
    elseif buffer:len() == 2 and FOLDER_ACTIONS[buffer(0, 2):uint()] then
        local root = tree:add(htxf, buffer(), "Folder Transfer Action")
        root:add(xf_action, buffer(0, 2))
        pinfo.cols.info = "Folder Action: " .. FOLDER_ACTIONS[buffer(0, 2):uint()]
    elseif looks_like_folder_header(buffer) then
        local size = buffer(0, 2):uint()
        local root = tree:add(htxf, buffer(0, size + 2), "Folder Transfer Item")
        root:add(xf_header_size, buffer(0, 2))
        root:add(xf_is_folder, buffer(2, 2), buffer(2, 2):uint() == 1)
        if size > 2 then decode_path(root, buffer(4, size - 2), pf_file_path) end
        pinfo.cols.info = buffer(2, 2):uint() == 1 and "Folder Item" or "File Item"
    else
        local root = tree:add(htxf, buffer(), "File Transfer Payload")
        root:add(xf_payload, buffer())
        pinfo.cols.info = string.format("Transfer Payload (%d bytes)", buffer:len())
    end
    return buffer:len()
end

htxf:register_heuristic("tcp", function(buffer, pinfo, tree)
    if buffer:len() < 4 then return false end
    local magic = range_text(buffer(0, 4))
    if magic ~= "HTXF" and magic ~= "FILP" and magic ~= "RFLT" then return false end
    htxf.dissector(buffer, pinfo, tree)
    return true
end)

end

-- Tracker protocol ----------------------------------------------------------

do

local tr_protocol = ProtoField.string("htrk.protocol", "Protocol")
local tr_version = ProtoField.uint16("htrk.version", "Version", base.DEC)
local tr_message_type = ProtoField.uint16("htrk.message.type", "Message Type", base.DEC, { [1] = "Server List" })
local tr_message_size = ProtoField.uint16("htrk.message.size", "Message Data Size", base.DEC)
local tr_total_count = ProtoField.uint16("htrk.server.total_count", "Total Server Count", base.DEC)
local tr_batch_count = ProtoField.uint16("htrk.server.batch_count", "Batch Server Count", base.DEC)
local tr_ip = ProtoField.ipv4("htrk.server.ip", "Server Address")
local tr_port = ProtoField.uint16("htrk.server.port", "Server Port", base.DEC)
local tr_tls_port = ProtoField.uint16("htrk.server.tls_port", "Server TLS Port", base.DEC)
local tr_users = ProtoField.uint16("htrk.server.users", "Connected Users", base.DEC)
local tr_name = ProtoField.string("htrk.server.name", "Server Name")
local tr_description = ProtoField.string("htrk.server.description", "Server Description")
local tr_login = ProtoField.string("htrk.login", "Tracker Login")
local tr_password = ProtoField.string("htrk.password", "Tracker Password")
local tr_pass_id = ProtoField.uint32("htrk.registration.pass_id", "Pass ID", base.HEX)
local tr_registration_type = ProtoField.uint16("htrk.registration.type", "Registration Type", base.DEC)
local tr_payload = ProtoField.bytes("htrk.payload", "Tracker Payload")
htrk.fields = {
    tr_protocol, tr_version, tr_message_type, tr_message_size, tr_total_count, tr_batch_count,
    tr_ip, tr_port, tr_tls_port, tr_users, tr_name, tr_description, tr_login, tr_password,
    tr_pass_id, tr_registration_type, tr_payload,
}

local tr_malformed = ProtoExpert.new(
    "htrk.expert.malformed", "Malformed tracker data", expert.group.MALFORMED, expert.severity.ERROR
)
local tr_truncated = ProtoExpert.new(
    "htrk.expert.truncated", "Truncated tracker data", expert.group.REASSEMBLE, expert.severity.WARN
)
local tr_credentials = ProtoExpert.new(
    "htrk.expert.credentials", "Tracker credentials are present", expert.group.SECURITY, expert.severity.WARN
)
htrk.experts = { tr_malformed, tr_truncated, tr_credentials }
htrk.prefs.tcp_ports = Pref.range("Tracker TCP ports", "5498", "TCP ports used for tracker listings", MAX_PORT)
htrk.prefs.udp_ports = Pref.range("Tracker UDP ports", "5498-5499", "UDP ports used for tracker registration", MAX_PORT)
htrk.prefs.desegment = Pref.bool("Reassemble tracker messages", true, "Request another TCP segment for incomplete tracker records")
htrk.prefs.show_credentials = Pref.bool("Show tracker credentials", false, "Display tracker login/password strings")

local function pascal8(buffer, cursor, limit)
    if cursor + 1 > limit then return nil, cursor end
    local length = buffer(cursor, 1):uint()
    if cursor + 1 + length > limit then return nil, cursor end
    return buffer(cursor + 1, length), cursor + 1 + length
end

local function dissect_tracker_request(buffer, root, version)
    local cursor = 6
    if version ~= 2 or cursor == buffer:len() then return true end
    local login_range
    login_range, cursor = pascal8(buffer, cursor, buffer:len())
    if not login_range then return false end
    local password_range
    password_range, cursor = pascal8(buffer, cursor, buffer:len())
    if not password_range then return false end
    add_expert(root, tr_credentials, "Tracker version 2 request contains credentials")
    if htrk.prefs.show_credentials then
        root:add(tr_login, login_range)
        root:add(tr_password, password_range)
    end
    if cursor < buffer:len() then root:add(tr_payload, buffer(cursor)) end
    return true
end

local function dissect_server_record(buffer, root, cursor, limit, record_number)
    if cursor + 12 > limit then return nil end
    local name_length = buffer(cursor + 10, 1):uint()
    local name_start = cursor + 11
    if name_start + name_length + 1 > limit then return nil end
    local description_length = buffer(name_start + name_length, 1):uint()
    local description_start = name_start + name_length + 1
    if description_start + description_length > limit then return nil end
    local next_cursor = description_start + description_length
    local record = root:add(htrk, buffer(cursor, next_cursor - cursor), string.format("Server %d", record_number))
    record:add(tr_ip, buffer(cursor, 4))
    record:add(tr_port, buffer(cursor + 4, 2))
    record:add(tr_users, buffer(cursor + 6, 2))
    record:add(tr_tls_port, buffer(cursor + 8, 2))
    record:add(tr_name, buffer(name_start, name_length))
    record:add(tr_description, buffer(description_start, description_length))
    return next_cursor
end

local function dissect_tracker_response(buffer, root)
    local cursor = 6
    local total_servers = nil
    local decoded_servers = 0
    while cursor < buffer:len() do
        if cursor + 8 > buffer:len() then return false end
        local batch_count = buffer(cursor + 6, 2):uint()
        local header = root:add(htrk, buffer(cursor, 8), "Server List Batch")
        header:add(tr_message_type, buffer(cursor, 2))
        header:add(tr_message_size, buffer(cursor + 2, 2))
        header:add(tr_total_count, buffer(cursor + 4, 2))
        header:add(tr_batch_count, buffer(cursor + 6, 2))
        if buffer(cursor, 2):uint() ~= 1 then
            add_expert(header, tr_malformed, "Tracker server-list message type must be one")
        end
        if not total_servers then total_servers = buffer(cursor + 4, 2):uint() end
        cursor = cursor + 8
        for _ = 1, batch_count do
            local next_cursor = dissect_server_record(buffer, root, cursor, buffer:len(), decoded_servers + 1)
            if not next_cursor then return false end
            cursor = next_cursor
            decoded_servers = decoded_servers + 1
        end
        if total_servers and decoded_servers >= total_servers then break end
    end
    if total_servers and decoded_servers ~= total_servers then
        add_expert(root, tr_truncated, string.format("Decoded %d of %d tracker records", decoded_servers, total_servers))
        return false
    end
    if cursor < buffer:len() then root:add(tr_payload, buffer(cursor)) end
    return true
end

local function dissect_tracker_tcp(buffer, pinfo, tree)
    if buffer:len() < 6 then
        if htrk.prefs.desegment then
            request_more(buffer, pinfo, tree, htrk, tr_truncated, 6 - buffer:len(), "Truncated HTRK Header")
        end
        return buffer:len()
    end
    local root = tree:add(htrk, buffer(), "Hotline Tracker")
    root:add(tr_protocol, buffer(0, 4))
    root:add(tr_version, buffer(4, 2))
    local version = buffer(4, 2):uint()
    if version ~= 1 and version ~= 2 then add_expert(root, tr_malformed, "Tracker version must be one or two") end

    local is_response = buffer:len() >= 8 and buffer(6, 2):uint() == 1
    if is_response and buffer:len() < 14 then
        if htrk.prefs.desegment then
            request_more(buffer, pinfo, tree, htrk, tr_truncated, 14 - buffer:len(), "Truncated Tracker List Header")
        end
        return buffer:len()
    end
    local complete
    if is_response then
        complete = dissect_tracker_response(buffer, root)
        pinfo.cols.info = "Tracker Server List"
    else
        complete = dissect_tracker_request(buffer, root, version)
        pinfo.cols.info = "Tracker List Request"
    end
    if not complete then
        add_expert(root, tr_truncated, "Tracker message ends inside a declared record")
    end
    return buffer:len()
end

local function dissect_tracker_udp(buffer, pinfo, tree)
    local root = tree:add(htrk, buffer(), "Tracker Server Registration")
    if buffer:len() < 14 then
        add_expert(root, tr_truncated, "Tracker registration requires at least 14 bytes")
        return buffer:len()
    end
    root:add(tr_registration_type, buffer(0, 2))
    root:add(tr_port, buffer(2, 2))
    root:add(tr_users, buffer(4, 2))
    root:add(tr_tls_port, buffer(6, 2))
    root:add(tr_pass_id, buffer(8, 4))
    local cursor = 12
    local name_range
    name_range, cursor = pascal8(buffer, cursor, buffer:len())
    if not name_range then add_expert(root, tr_malformed, "Invalid registration server name"); return buffer:len() end
    root:add(tr_name, name_range)
    local description_range
    description_range, cursor = pascal8(buffer, cursor, buffer:len())
    if not description_range then add_expert(root, tr_malformed, "Invalid registration description"); return buffer:len() end
    root:add(tr_description, description_range)

    local trailing = {}
    while cursor < buffer:len() do
        local value_range
        value_range, cursor = pascal8(buffer, cursor, buffer:len())
        if not value_range then add_expert(root, tr_malformed, "Invalid registration credential field"); break end
        trailing[#trailing + 1] = value_range
    end
    if #trailing > 0 then
        add_expert(root, tr_credentials, "Tracker registration contains credentials")
        if htrk.prefs.show_credentials then
            if #trailing == 1 then root:add(tr_password, trailing[1])
            else root:add(tr_login, trailing[1]); root:add(tr_password, trailing[2]) end
        end
    end
    pinfo.cols.info = string.format("Tracker Registration: %s", range_text(name_range))
    return buffer:len()
end

function htrk.dissector(buffer, pinfo, tree)
    if buffer:len() == 0 then return 0 end
    pinfo.cols.protocol = "HTRK"
    if buffer:len() >= 4 and range_text(buffer(0, 4)) == "HTRK" then
        return dissect_tracker_tcp(buffer, pinfo, tree)
    end
    return dissect_tracker_udp(buffer, pinfo, tree)
end

htrk:register_heuristic("tcp", function(buffer, pinfo, tree)
    if buffer:len() < 4 or range_text(buffer(0, 4)) ~= "HTRK" then return false end
    htrk.dissector(buffer, pinfo, tree)
    return true
end)

htrk:register_heuristic("udp", function(buffer, pinfo, tree)
    if buffer:len() < 14 or buffer(0, 2):uint() ~= 1 then return false end
    local first_string_length = buffer(12, 1):uint()
    if 13 + first_string_length + 1 > buffer:len() then return false end
    htrk.dissector(buffer, pinfo, tree)
    return true
end)

end

-- HTTP tunneling ------------------------------------------------------------

do

local HTTP_CODES = { [0] = "Disconnect", [1] = "Data", [2] = "Padding" }
local http_code = ProtoField.uint32("hlhttp.code", "Data Code", base.DEC, HTTP_CODES)
local http_size = ProtoField.uint32("hlhttp.size", "Data Size", base.DEC)
local http_data = ProtoField.bytes("hlhttp.data", "Data")
hlhttp.fields = { http_code, http_size, http_data }
local http_malformed = ProtoExpert.new(
    "hlhttp.expert.malformed", "Malformed HTTP tunnel record", expert.group.MALFORMED, expert.severity.ERROR
)
local http_truncated = ProtoExpert.new(
    "hlhttp.expert.truncated", "Truncated HTTP tunnel record", expert.group.REASSEMBLE, expert.severity.WARN
)
hlhttp.experts = { http_malformed, http_truncated }
hlhttp.prefs.max_record_size = Pref.uint("Maximum tunnel record size", DEFAULT_MAX_PDU, "Reject larger tunneled records")

local function dispatch_tunnel_payload(payload_tvb, pinfo, tree)
    if payload_tvb:len() >= 4 then
        local magic = range_text(payload_tvb(0, 4))
        if magic == "HTRK" then return htrk.dissector(payload_tvb, pinfo, tree)
        elseif magic == "HTXF" or magic == "FILP" or magic == "RFLT" then
            return htxf.dissector(payload_tvb, pinfo, tree)
        end
    end
    return hotline.dissector(payload_tvb, pinfo, tree)
end

function hlhttp.dissector(buffer, pinfo, tree)
    if buffer:len() == 0 then return 0 end
    local cursor = 0
    local summaries = {}
    while cursor < buffer:len() do
        if cursor + 8 > buffer:len() then
            request_more(buffer, pinfo, tree, hlhttp, http_truncated, cursor + 8 - buffer:len(), "Truncated Tunnel Header")
            break
        end
        local code = buffer(cursor, 4):uint()
        local size = buffer(cursor + 4, 4):uint()
        if size > hlhttp.prefs.max_record_size then
            local malformed = tree:add(hlhttp, buffer(cursor), "Malformed Tunnel Record")
            add_expert(malformed, http_malformed, "Tunnel record exceeds the configured maximum")
            break
        end
        if cursor + 8 + size > buffer:len() then
            request_more(buffer, pinfo, tree, hlhttp, http_truncated,
                cursor + 8 + size - buffer:len(), "Truncated Tunnel Record")
            break
        end
        local record = tree:add(hlhttp, buffer(cursor, 8 + size), HTTP_CODES[code] or "Unknown Tunnel Record")
        record:add(http_code, buffer(cursor, 4))
        record:add(http_size, buffer(cursor + 4, 4))
        if size > 0 then
            local data_range = buffer(cursor + 8, size)
            record:add(http_data, data_range)
            if code == 1 then
                local payload_tvb = data_range:tvb()
                dispatch_tunnel_payload(payload_tvb, pinfo, record)
            end
        end
        if not HTTP_CODES[code] then add_expert(record, http_malformed, "Unknown tunnel data code") end
        summaries[#summaries + 1] = HTTP_CODES[code] or string.format("Unknown %d", code)
        cursor = cursor + 8 + size
    end
    pinfo.cols.protocol = "HLHTTP"
    if #summaries > 0 then pinfo.cols.info = "Tunnel: " .. table.concat(summaries, ", ") end
    return buffer:len()
end

end

-- Registration and preference reloads --------------------------------------

do

local tcp_port_table = DissectorTable.get("tcp.port")
local udp_port_table = DissectorTable.get("udp.port")
local media_type_table = DissectorTable.get("media_type")

local command_ports = hotline.prefs.tcp_ports
local transfer_ports = htxf.prefs.tcp_ports
local tracker_tcp_ports = htrk.prefs.tcp_ports
local tracker_udp_ports = htrk.prefs.udp_ports

tcp_port_table:add(command_ports, hotline)
tcp_port_table:add(transfer_ports, htxf)
tcp_port_table:add(tracker_tcp_ports, htrk)
udp_port_table:add(tracker_udp_ports, htrk)
if media_type_table then media_type_table:add("hotline/protocol", hlhttp) end

if tcp_port_table.add_for_decode_as then
    tcp_port_table:add_for_decode_as(hotline)
    tcp_port_table:add_for_decode_as(htxf)
    tcp_port_table:add_for_decode_as(htrk)
end
if udp_port_table.add_for_decode_as then udp_port_table:add_for_decode_as(htrk) end
if media_type_table and media_type_table.add_for_decode_as then media_type_table:add_for_decode_as(hlhttp) end

local function replace_registration(dissector_table, previous, current, dissector)
    if previous == current then return previous end
    if dissector_table.remove then dissector_table:remove(previous, dissector) end
    dissector_table:add(current, dissector)
    return current
end

function hotline.prefs_changed()
    command_ports = replace_registration(tcp_port_table, command_ports, hotline.prefs.tcp_ports, hotline)
    hotline.init()
end

function htxf.prefs_changed()
    transfer_ports = replace_registration(tcp_port_table, transfer_ports, htxf.prefs.tcp_ports, htxf)
end

function htrk.prefs_changed()
    tracker_tcp_ports = replace_registration(tcp_port_table, tracker_tcp_ports, htrk.prefs.tcp_ports, htrk)
    tracker_udp_ports = replace_registration(udp_port_table, tracker_udp_ports, htrk.prefs.udp_ports, htrk)
end

end
