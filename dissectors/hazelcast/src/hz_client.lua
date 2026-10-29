-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/pmcgleenon/hazelcast-wireshark-plugin,
-- commit 559ca1349222092b5786ffd2d3be2070f7a3e3db du 14/12/2024.
-- Licence amont : MIT (LICENSE amont) — voir README.md.

-- Define the protocol
local hazelcast_client = Proto("HazelcastClient", "Hazelcast Protocol")

-- Define the protocol fields
local f = hazelcast_client.fields
f.frame_length = ProtoField.uint32("hazelcast_client.frame_length", "Frame Length", base.DEC)
f.flags = ProtoField.uint16("hazelcast_client.flags", "Flags", base.HEX)
f.payload = ProtoField.bytes("hazelcast_client.payload", "Payload")
f.initial_bytes = ProtoField.bytes("hazelcast_client.initial_bytes", "Initial Bytes", base.SPACE)
f.initial_text = ProtoField.string("hazelcast_client.initial_text", "Initial Text")
f.reserved = ProtoField.uint8("hazelcast_client.reserved", "Reserved Bits", base.HEX)
f.message_type = ProtoField.string("hazelcast_client.message_type", "Message Type")

-- Define individual flag fields
f.begin_fragment_flag = ProtoField.bool("hazelcast_client.begin_fragment_flag", "Begin Fragment Flag")
f.end_fragment_flag = ProtoField.bool("hazelcast_client.end_fragment_flag", "End Fragment Flag")
f.is_final_flag = ProtoField.bool("hazelcast_client.is_final_flag", "Is Final Flag")
f.begin_data_structure_flag = ProtoField.bool("hazelcast_client.begin_data_structure_flag", "Begin Data Structure Flag")
f.end_data_structure_flag = ProtoField.bool("hazelcast_client.end_data_structure_flag", "End Data Structure Flag")
f.is_null_flag = ProtoField.bool("hazelcast_client.is_null_flag", "Is Null Flag")
f.is_event_flag = ProtoField.bool("hazelcast_client.is_event_flag", "Is Event Flag")
f.backup_aware_flag = ProtoField.bool("hazelcast_client.backup_aware_flag", "Backup Aware Flag")
f.backup_event_flag = ProtoField.bool("hazelcast_client.backup_event_flag", "Backup Event Flag")

-- TCP port for the protocol
local tcp_port = 5701

-- Import the message types module
local message_types = require("hz_message_types")
local decoders = require("hz_decoders")

-- Dissector function
function hazelcast_client.dissector(buffer, pinfo, tree)
    pinfo.cols.protocol = "Hazelcast"

    -- Check for initial bytes on a new TCP connection
    if buffer:len() >= 3 and buffer(0,3):uint() == 0x435032 then
        local subtree = tree:add(hazelcast_client, buffer(), "Connection Initialization")
        subtree:add(f.initial_bytes, buffer(0,3))
        subtree:add(f.initial_text, buffer(0,3))
        subtree:append_text(" (Connection Initialization with CP2)")
        return -- Stop further processing if this is just the initialization
    end

    local offset = 0
    while offset < buffer:len() do
        local frame_length = buffer(offset, 4):le_uint()
        
        -- Validate frame_length
        if frame_length < 6 or frame_length > buffer:len() - offset then
            pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
            return
        end

        local flags_value = buffer(offset + 4, 2):le_uint() -- Read the flags value

        -- Calculate payload length (frame_length - header_size)
        local header_size = 6 -- 4 bytes for frame_length + 2 bytes for flags
        local payload_length = frame_length - header_size

        local subtree = tree:add(hazelcast_client, buffer(offset, frame_length), "Hazelcast Frame")
        subtree:add(f.frame_length, frame_length)

        -- Add the flags as a single item
        subtree:add(f.flags, flags_value)

        -- Add individual flag fields to the tree using bitwise operations
        subtree:add(f.begin_fragment_flag, bit.band(flags_value, 0x8000) ~= 0) -- Bit 15
        subtree:add(f.end_fragment_flag, bit.band(flags_value, 0x4000) ~= 0)   -- Bit 14
        subtree:add(f.is_final_flag, bit.band(flags_value, 0x2000) ~= 0)      -- Bit 13
        subtree:add(f.begin_data_structure_flag, bit.band(flags_value, 0x1000) ~= 0) -- Bit 12
        subtree:add(f.end_data_structure_flag, bit.band(flags_value, 0x0800) ~= 0)   -- Bit 11
        subtree:add(f.is_null_flag, bit.band(flags_value, 0x0400) ~= 0)            -- Bit 10
        subtree:add(f.is_event_flag, bit.band(flags_value, 0x0200) ~= 0)           -- Bit 9
        subtree:add(f.backup_aware_flag, bit.band(flags_value, 0x0100) ~= 0)       -- Bit 8
        subtree:add(f.backup_event_flag, bit.band(flags_value, 0x0080) ~= 0)       -- Bit 7

        -- Decode and display reserved bits (bits 6 to 0)
        local reserved_bits = bit.band(flags_value, 0x003F) -- Mask for bits 6 to 0
        subtree:add(f.reserved, reserved_bits) -- Display reserved bits

        -- Parse the message type if payload length is sufficient
        if payload_length >= 4 then
            local message_type = buffer(offset + header_size, 4):le_uint() -- Read the message type
            local message_type_key = string.format("0x%06x", message_type) -- Format as hex string
            local message_type_description = message_types.getMessageTypeString(message_type_key)
            subtree:add(f.message_type, message_type_key .. " - " .. message_type_description)

            -- Debug print for message type
            print("Debug: Message Type = " .. message_type_key .. " - " .. message_type_description)

            -- Call the decoder method if message_type is found and not "0x000000"
            if message_type ~= "0x000000" and message_type_description ~= "Unknown Message Type" then
                -- local decoder_function = decoders[message_type_key]
                callDecoder(message_type_key)
            else
                print("Debug2: Skipping decoder lookup for message type = " .. message_type_key)
            end
        end

        -- print("Payload length: " .. payload_length)
        if payload_length > 0 then
            -- Read the payload
            subtree:add(f.payload, buffer(offset + header_size, payload_length))
        end

        offset = offset + frame_length
    end
end

-- Register the dissector to handle packets on specific ports
DissectorTable.get("tcp.port"):add(tcp_port, hazelcast_client)