-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://codeberg.org/gcarlos/gc-wireshark-dissector (payload.lua),
-- commit b75e846d20aa7da7081432f283dc0f2ae1da5ee6 du 18/11/2025.
-- Licence amont : GPLv3 (LICENSE, sans clause « or later ») — voir README.md.

package.path = "plugins/grandchase/?.lua;" .. package.path
utf16_to_utf8 = require("utf16")

local function read_string(tvbrange, offset)
    local strlen = tvbrange(offset, 4):uint()
    return tvbrange(offset + 4, strlen), offset + 4 + strlen
end

local UNKNOWN = {
    name   = "UNKNOWN",
    fields = {},

    dissect = function(self, tvbrange, subtree)
        return
    end
}

local ACK = {
    name   = "ACK",
    fields = {},

    dissect = function(self, tvbrange, subtree)
        return
    end
}

local CRYPT_SETUP = {
    name   = "CRYPT_SETUP",
    fields = {
        spi           = ProtoField.uint16("gc.crypt_setup_spi", "SPI", base.DEC),
        key           = ProtoField.bytes("gc.crypt_setup_key", "Key", base.SPACE),
        auth_key      = ProtoField.bytes("gc.crypt_setup_auth_key", "Auth key", base.SPACE),
        sequence      = ProtoField.uint32("gc.crypt_setup_sequence", "Sequence", base.DEC),
        last_sequence = ProtoField.uint32("gc.crypt_setup_last_sequence", "Last sequence", base.DEC),
        rpl_win_mask  = ProtoField.uint32("gc.crypt_setup_rpl_win_mask", "Replay window mask", base.DEC)
    },

    dissect = function(self, tvbrange, subtree)
        subtree:add(self.fields.spi, tvbrange(0, 2))
        subtree:add(self.fields.auth_key, tvbrange(6, 8))
        subtree:add(self.fields.key, tvbrange(18, 8))
        subtree:add(self.fields.sequence, tvbrange(26, 4))
        subtree:add(self.fields.last_sequence, tvbrange(30, 4))
        subtree:add(self.fields.rpl_win_mask, tvbrange(34, 4))
    end
}

local LOGIN = {
    name   = "LOGIN",
    fields = {
        user     = ProtoField.string("gc.login_user", "User", base.ASCII),
        password = ProtoField.string("gc.login_password", "Password (md5)", base.ASCII),
        unknown1 = ProtoField.bytes("gc.login_unknown1", "Unknown1", base.SPACE),
    },

    dissect = function(self, tvbrange, subtree)
        local offset = 0
        local user, password, unknown1

        user    , offset = read_string(tvbrange, offset)
        password, offset = read_string(tvbrange, offset)
        unknown1         = tvbrange(offset)

        subtree:add(self.fields.user, user)
        subtree:add(self.fields.password, password)
        subtree:add(self.fields.unknown1, unknown1)
    end
}

local LOGIN_RESPONSE = {
    name   = "LOGIN_RESPONSE",
    fields = {
        user     = ProtoField.string("gc.login_response_user", "User", base.ASCII),
        password = ProtoField.string("gc.login_response_password", "Password (md5)", base.ASCII),
        unknown1 = ProtoField.uint32("gc.login_response_unknown1", "Unknown1", base.DEC),
        unknown2 = ProtoField.bytes("gc.login_response_unknown2", "Unknown2", base.SPACE),
    },

    dissect = function(self, tvbrange, subtree)
        local offset = 0
        local user, password, unknown1, unknown2

        unknown1, offset = tvbrange(offset, 4), offset + 4
        user    , offset = read_string(tvbrange, offset)
        password, offset = read_string(tvbrange, offset)
        unknown2         = tvbrange(offset)

        subtree:add(self.fields.unknown1, unknown1)
        subtree:add(self.fields.user, user, utf16_to_utf8(user))
        subtree:add(self.fields.password, password)
        subtree:add(self.fields.unknown2, unknown2)
    end
}

local SERVER_LIST = {
    name   = "SERVER_LIST",
    fields = {
        num_servers = ProtoField.uint32("gc.server_list_num_servers", "Num. of servers", base.DEC),
        name        = ProtoField.string("gc.server_list_name", "Name", base.UNICODE),
        ip          = ProtoField.string("gc.server_list_ip", "IP", base.ASCII),
        port        = ProtoField.uint16("gc.server_list_port", "Port", base.DEC),
        entry       = ProtoField.string("gc.server_list_entry", "Server", base.UNICODE),
        unknown1    = ProtoField.uint32("gc.server_list_unknown1", "Unkown1", base.DEC),
        unknown2    = ProtoField.bytes("gc.server_list_unknown2", "Unkown2", base.SPACE),
    },

    dissect = function(self, tvbrange, subtree)
        local num_servers = tvbrange(0, 4):uint()
        subtree:add(self.fields.num_servers, tvbrange(0, 4))

        local offset = 4
        local start_offset, unknown1, name, ip, port, unknown2
        for _ = 1, num_servers do
            local start_offset = offset
            unknown1, offset = tvbrange(offset, 4), offset + 4
            name    , offset = read_string(tvbrange, offset)
            ip      , offset = read_string(tvbrange, offset)
            port    , offset = tvbrange(offset, 2), offset + 2
            unknown2, offset = tvbrange(offset, 12), offset + 12

            local name_v = utf16_to_utf8(name)

            local entry = subtree:add(self.fields.entry,
                                      tvbrange(start_offset, offset - start_offset),
                                      name_v)

            entry:add(self.fields.unknown1, unknown1)
            entry:add(self.fields.name, name, name_v)
            entry:add(self.fields.ip, ip)
            entry:add(self.fields.port, port)
            entry:add(self.fields.unknown2, unknown2)
        end
    end
}

local CRYPT_SETUP_VALIDATION = {
    name   = "CRYPT_SETUP_VALIDATION",
    fields = {
        test = ProtoField.uint32("gc.crypt_setup_valdation_test", "Test", base.DEC),
    },

    dissect = function(self, tvbrange, subtree)
        subtree:add(self.fields.test, tvbrange(0, 4))
    end
}

local CONTENT = {
    [-1] = UNKNOWN,
    [0]  = ACK,
    [1]  = CRYPT_SETUP,
    [2]  = LOGIN,
    [3]  = LOGIN_RESPONSE,
    [4]  = SERVER_LIST,
    [5]  = CRYPT_SETUP_VALIDATION
}

return CONTENT
