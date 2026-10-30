-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://codeberg.org/gcarlos/gc-wireshark-dissector (main.lua),
-- commit b75e846d20aa7da7081432f283dc0f2ae1da5ee6 du 18/11/2025.
-- Licence amont : GPLv3 (LICENSE, sans clause « or later ») — voir README.md.

project_path = "/home/mim/projects/gc/wireshark-dissector"
package.path = project_path .. "/?.lua;" .. package.path
package.path = project_path .. "/lib/lua-lockbox/?.lua;" .. package.path

local Payload = require("payload")

local Lockbox = require("lockbox")
Lockbox.ALLOW_INSECURE = true

local Array = require("lockbox.util.array")
local Stream = require("lockbox.util.stream")
local CBCMode = require("lockbox.cipher.mode.cbc")
local PKCS7Padding = require("lockbox.padding.pkcs7")
local DESCipher = require("lockbox.cipher.des")

gc_protocol = Proto("GrandChase", "Grand Chase Protocol")

-- Encrypted packet
size       = ProtoField.uint16("gc.size", "Size", base.DEC)
spi        = ProtoField.uint16("gc.spi", "SPI", base.DEC)
sequence   = ProtoField.uint32("gc.sequence", "Sequence", base.DEC)
iv         = ProtoField.bytes("gc.iv", "IV", base.SPACE)
crypt_data = ProtoField.bytes("gc.encrypted_data", "Encrypted data", base.NONE)
icv        = ProtoField.bytes("gc.icv", "ICV", base.SPACE)

-- Payload header
opcode           = ProtoField.uint16("gc.opcode", "Opcode", base.DEC)
psize            = ProtoField.uint32("gc.psize", "Payload size", base.DEC)
compression_flag = ProtoField.bool("gc.compression_flag", "Compression flag")

-- Payload content
uncompressed_psize = ProtoField.uint32("gc.uncompressed_psize", "Uncompressed payload size", base.DEC)
compressed_data    = ProtoField.bytes("gc.compressed_data", "Compressed data", base.NONE)
pad                = ProtoField.bytes("gc.pad", "Pad", base.SPACE)

gc_protocol.fields = {
    size, spi, sequence, iv, crypt_data, icv, data, -- Encrypted packet
    opcode, psize, compression_flag,                -- Payload header
    uncompressed_psize, compressed_data, pad        -- Payload content
}

for _,payload in pairs(Payload) do
    name = payload.name
    for field_name, field in pairs(payload.fields) do
        gc_protocol.fields[name..field_name] = field
    end
end

key_table = {
    values = {},

    get_key = function (self, client_addr, spi_v)
        if spi_v == 0 then return "C7D8C4BFB5E9C0FD" end
        return self.values[client_addr .. spi_v]
    end,

    put_key = function (self, client_addr, spi_v, key)
        self.values[client_addr .. spi_v] = key
        self.values[client_addr .. 17912] = key
    end,
}

server_addr = nil
function get_client_addr(pinfo)
    local client_addr = tostring(pinfo.src) .. ":" .. tostring(pinfo.src_port)
    if client_addr == server_addr then
        client_addr = tostring(pinfo.dst) .. ":" .. tostring(pinfo.dst_port)
    end

    return client_addr
end

function gc_protocol.dissector(buffer, pinfo, tree)
    local length = buffer:captured_len()
    local reported_length = buffer:reported_len()
    if length == 0 or length ~= reported_length then return end

    local size_v = buffer(0, 2):le_uint()

    if size_v < length then
        gc_protocol.dissector(buffer(0, size_v):bytes():tvb(), pinfo, tree)
        gc_protocol.dissector(buffer(size_v):bytes():tvb(), pinfo, tree)
        return
    elseif size_v > length then
        pinfo.desegment_len = size_v - length
        return
    end

    pinfo.cols.protocol = gc_protocol.name

    local subtree = tree:add(gc_protocol, buffer(), "Grand Chase Protocol Data")
    local encrypted_packet = subtree:add(gc_protocol, buffer(), "Encrypted Packet")

    encrypted_packet:add_le(size, buffer(0, 2))
    encrypted_packet:add_le(spi, buffer(2, 2))
    encrypted_packet:add_le(sequence, buffer(4, 4))
    encrypted_packet:add_le(iv, buffer(8, 8))
    encrypted_packet:add_le(crypt_data, buffer(16, length - (10 + 16)))
    encrypted_packet:add_le(icv, buffer(length - 10, 10))

    local spi_v = buffer(2, 2):le_uint()

    if spi_v == 0 then
        server_addr = tostring(pinfo.src) .. ":" .. tostring(pinfo.src_port)
    end

    local client_addr = get_client_addr(pinfo)
    local key = key_table:get_key(client_addr, spi_v)
    if not key then return end

    local decipher = CBCMode.Decipher()
                            .setKey(Array.fromHex(key))
                            .setBlockCipher(DESCipher)
                            .setPadding(PKCS7Padding)

    local packet = decipher.init()
                            .update(Stream.fromHex(buffer:bytes(8, 8):tohex()))
                            .update(Stream.fromHex(buffer:bytes(16, length - 26):tohex()))
                            .finish()
                            .asHex()

    packet = ByteArray.new(packet):tvb()
    local packet_subtree = subtree:add(gc_protocol, packet(), "Packet")

    local opcode_v     = packet(0, 2):uint()
    local payload_info = Payload[opcode_v] or Payload[-1]
    local payload_name = payload_info.name

    packet_subtree:add(opcode, packet(0, 2)):append_text(" (" .. payload_name .. ")")
    packet_subtree:add(psize, packet(2, 4))
    packet_subtree:add(compression_flag, packet(6, 1))


    local psize_v = packet(2,4):uint()
    local payload = packet(7, psize_v)
    local compression_flag_v = packet:raw(6, 1) == "\x01"
    if compression_flag_v and psize_v ~= 0 then
        packet_subtree:add_le(uncompressed_psize, packet(7, 4))
        packet_subtree:add_le(compressed_data, packet(11, psize_v - 4))

        payload = packet(11, psize_v - 4):uncompress_zlib("uncompressed_payload"):bytes():tvb()
    end

    local payload_subtree = payload:len() ~= 0 and
                            packet_subtree:add(gc_protocol, payload(), "Payload")

    if spi_v == 0 then
        local new_spi_v = payload(0, 2):uint()
        local new_key = payload(18, 8):bytes():tohex()
        key_table:put_key(client_addr, new_spi_v, new_key)
    end

    payload_info:dissect(payload, payload_subtree)
    packet_subtree:add_le(pad, packet(psize_v + 7))

end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add("9400,9500,9501", gc_protocol)
