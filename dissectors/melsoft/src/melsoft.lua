-- SPDX-License-Identifier: MIT
-- Import茅 de https://github.com/louislau86/Mitsubishi-protocol-wireshark-plugin (melsoft.lua),
-- commit 5890d27a405e28ce81b9610074039c4a60fd25a6 du 28/12/2025.
-- Licence amont : voir README.md et LICENSE.txt.

-- MELSOFT Protocol Dissector for Wireshark
-- Protocol: MELSOFT (Mitsubishi Electric FA protocol)
-- Author: Generated from protocol samples
-- Version: 1.13 (Fixed write value byte swapping and added decimal display)

-- Debug flag - set to true to enable debug output
local DEBUG = false

-- Create protocol object
local melsoft_proto = Proto("MELSOFT", "MELSOFT Protocol")

-- Device type abbreviation mapping (based on provided images)
local device_short_names = {
    [0x01] = "M",
    [0x02] = "SM",
    [0x03] = "L",
    [0x04] = "F",
    [0x08] = "S",
    [0x10] = "X",
    [0x11] = "Y",
    [0x20] = "D",
    [0x21] = "SD",
    [0x27] = "R",
    [0x30] = "W",
    [0x42] = "TN",
    [0x46] = "CN",
    [0x60] = "Z"
}

-- Device type full name mapping
local device_full_names = {
    [0x01] = "Internal relay (M)",
    [0x02] = "Special relay (SM)",
    [0x03] = "Latch relay (L)",
    [0x04] = "Annunciator (F)",
    [0x08] = "Step relay (S)",
    [0x10] = "Input (X)",
    [0x11] = "Output (Y)",
    [0x20] = "Data register (D)",
    [0x21] = "Special Register (SD)",
    [0x27] = "File register (R)",
    [0x30] = "Link register (W)",
    [0x42] = "Timer (TN)",
    [0x46] = "Counter (CN)",
    [0x60] = "Index register (Z)"
}

-- Command code mapping (based on provided images)
local command_names = {
    [0x0121] = "Model Name",
    [0x0410] = "Random Read",
    --[0x0411] = "Random Read",
    [0x0412] = "Batch Read",
    [0x1001] = "Remote RUN",
    [0x1002] = "Remote STOP",
    [0x100A] = "Remote RESET",
    [0x1410] = "Batch Write",
    [0x1411] = "Random Write",
    [0x1650] = "Remote Password Unlock",
    [0x1651] = "Remote Password Lock",
    [0x1867] = "Open File",
    [0x1868] = "Read File",
    [0x1869] = "Write File",
    [0x186A] = "Close File"
}

-- Define fields - ensure each field has a clear name
local fields = {
    -- MSG HEADER fields
    module_type = ProtoField.uint8("melsoft.msg_header.module_type", "Module Type", base.HEX, {
        [0x51] = "Ethernet Module Request (0x51)",
        [0x57] = "CPU Module Request (0x57)",
        [0xD1] = "Ethernet Module Response (0xD1)",
        [0xD7] = "CPU Module Response (0xD7)"
    }),
    frame_type = ProtoField.uint8("melsoft.msg_header.frame_type", "Frame Type", base.HEX, {
        [0x00] = "Session Transfer (0x00)",
        [0x01] = "Data Transfer (0x01)"
    }),
    seq_num1 = ProtoField.uint8("melsoft.msg_header.seq_num1", "Sequence Number-1", base.HEX),
    unknown1 = ProtoField.bytes("melsoft.msg_header.unknown1", "Unknown 1 (6 bytes)", base.SPACE),
    
    -- Destination information
    dst_net = ProtoField.uint8("melsoft.msg_header.dst_net", "Destination Network No.", base.HEX),
    dst_controller = ProtoField.uint8("melsoft.msg_header.dst_controller", "Destination Controller No.", base.HEX),
    dst_module = ProtoField.uint16("melsoft.msg_header.dst_module", "Destination Module No.", base.HEX),
    
    -- Source information
    src_net = ProtoField.uint8("melsoft.msg_header.src_net", "Source Network No.", base.HEX),
    src_controller = ProtoField.uint8("melsoft.msg_header.src_controller", "Source Controller No.", base.HEX),
    src_module = ProtoField.uint16("melsoft.msg_header.src_module", "Source Module No.", base.HEX),
    
    unknown2 = ProtoField.bytes("melsoft.msg_header.unknown2", "Unknown 2 (2 bytes)", base.SPACE),
    data_size = ProtoField.uint16("melsoft.msg_header.data_size", "Data Size", base.DEC),
    
    -- CMD HEADER fields
    flags = ProtoField.uint8("melsoft.cmd_header.flags", "Flags", base.HEX),
    parity = ProtoField.uint8("melsoft.cmd_header.parity", "Parity", base.HEX),
    cmdoff = ProtoField.uint8("melsoft.cmd_header.cmdoff", "Cmd Offset", base.HEX),
    cmd_header_size = ProtoField.uint8("melsoft.cmd_header.size", "Size", base.DEC),
    
    unknown3 = ProtoField.bytes("melsoft.cmd_header.unknown3", "Unknown Bytes", base.SPACE),
    
    -- CMD DATA fields - exactly as defined in provided images
    command = ProtoField.uint16("melsoft.cmd_data.command", "Command Code", base.HEX, command_names),
    seq_num2 = ProtoField.uint8("melsoft.cmd_data.seq_num2", "Sequence Number-2", base.HEX),
    cmd_data_size = ProtoField.uint16("melsoft.cmd_data.size", "Size 2", base.DEC),
    
    -- DATA SUMMARY fields
    unknown4 = ProtoField.bytes("melsoft.data_summary.unknown4", "Unknown 4 (9 bytes)", base.SPACE),
    subcmd = ProtoField.uint16("melsoft.data_summary.subcmd", "Sub Command", base.HEX),
    word_count = ProtoField.uint8("melsoft.data_summary.word_count", "2-byte Element Count", base.DEC),
    bit_count = ProtoField.uint8("melsoft.data_summary.bit_count", "Bit Element Count", base.DEC),
    dword_count = ProtoField.uint8("melsoft.data_summary.dword_count", "4-byte Element Count", base.DEC),
    qword_count = ProtoField.uint8("melsoft.data_summary.qword_count", "8-byte Element Count", base.DEC),
    unknown5 = ProtoField.bytes("melsoft.data_summary.unknown5", "Unknown 5 (6 bytes)", base.SPACE),
    
    -- DATA ONE ELEMENT fields - exactly as defined in device type images
    element_type = ProtoField.uint8("melsoft.data_element.element_type", "Element Type", base.HEX, device_full_names),
    element_code = ProtoField.uint8("melsoft.data_element.element_code", "Element Code", base.HEX),
    start_addr = ProtoField.uint32("melsoft.data_element.start_addr", "Start Address", base.HEX),
    start_addr_dec = ProtoField.uint32("melsoft.data_element.start_addr_dec", "Start Address (Decimal)", base.DEC),
    offset_addr = ProtoField.uint32("melsoft.data_element.offset_addr", "Offset Address", base.HEX),
    offset_addr_dec = ProtoField.uint32("melsoft.data_element.offset_addr_dec", "Offset Address (Decimal)", base.DEC),
    element_flags = ProtoField.uint16("melsoft.data_element.element_flags", "Element Flags", base.HEX),
    bit_len = ProtoField.uint16("melsoft.data_element.bit_len", "Bit Read/Write Position", base.DEC),
    
    -- 注意：对于写命令，原来的write_value字段实际上是未知数据
    element_unknown1 = ProtoField.uint16("melsoft.data_element.element_unknown1", "Unknown Field 1", base.HEX),
    element_unknown1_dec = ProtoField.uint16("melsoft.data_element.element_unknown1_dec", "Unknown Field 1 (Decimal)", base.DEC),
    
    -- 对于写命令，原来的element_unknown字段才是实际的写入值
    write_value = ProtoField.uint16("melsoft.data_element.write_value", "Write Value (Hex)", base.HEX),
    write_value_swapped = ProtoField.uint16("melsoft.data_element.write_value_swapped", "Write Value (Swapped)", base.HEX),
    write_value_dec = ProtoField.uint16("melsoft.data_element.write_value_dec", "Write Value (Decimal)", base.DEC),
    
    read_write_count = ProtoField.uint16("melsoft.data_element.read_write_count", "Read/Write Count", base.DEC),
    
    -- Response packet specific fields
    response_end_code = ProtoField.uint16("melsoft.response.end_code", "Response End Code", base.HEX, {
        [0x0000] = "Normal (0x0000)",
        [0x0001] = "Error (0x0001)",
        [0xC050] = "Command Error (0xC050)",
        [0xC051] = "Parameter Error (0xC051)",
        [0xC052] = "Data Error (0xC052)",
        [0xC054] = "Processing Impossible (0xC054)",
        [0xC058] = "Response Data Too Long (0xC058)"
    }),
    response_data_count = ProtoField.uint8("melsoft.response.data_count", "Response Data Count", base.DEC),
    response_data = ProtoField.bytes("melsoft.response.data", "Response Data", base.SPACE),
    
    -- Communication status fields
    comm_status = ProtoField.uint8("melsoft.response.comm_status", "Communication Status", base.HEX, {
        [0x00] = "Normal (0x00)",
        [0x01] = "Warning (0x01)",
        [0x02] = "Error (0x02)"
    }),
    
    -- Response specific fields
    response_header = ProtoField.bytes("melsoft.response.header", "Response Header", base.SPACE),
    response_unknown = ProtoField.bytes("melsoft.response.unknown", "Response Unknown", base.SPACE),
    
    -- Raw data fields for debugging
    raw_bytes = ProtoField.bytes("melsoft.raw_bytes", "Raw Bytes", base.SPACE)
}

-- Add fields to protocol
for k, v in pairs(fields) do
    melsoft_proto.fields[k] = v
end

-- Helper function: debug print (always print, ignoring DEBUG flag)
local function debug_print(msg)
    if DEBUG then
        print("[MELSOFT-DEBUG] " .. msg)
    end
end

-- Helper function: get device short name
local function get_device_short_name(device_type)
    return device_short_names[device_type] or string.format("0x%02X", device_type)
end

-- Helper function: get command name
local function get_command_name(command_code)
    return command_names[command_code] or string.format("0x%04X", command_code)
end

-- Helper function: check if valid MELSOFT module type
local function is_valid_melsoft_module_type(module_type)
    local valid = module_type == 0x51 or module_type == 0x57 or 
                  module_type == 0xD1 or module_type == 0xD7
    debug_print(string.format("Checking module type 0x%02X: %s", module_type, valid and "VALID" or "INVALID"))
    return valid
end

-- Helper function: check if valid MELSOFT frame type
local function is_valid_melsoft_frame_type(frame_type)
    local valid = frame_type == 0x00 or frame_type == 0x01
    debug_print(string.format("Checking frame type 0x%02X: %s", frame_type, valid and "VALID" or "INVALID"))
    return valid
end

-- Helper function: check if valid network/controller ID
local function is_valid_node_id(value, name)
    local valid = value >= 0x00 and value <= 0xFF
    debug_print(string.format("Checking %s 0x%02X: %s", name, value, valid and "VALID" or "INVALID"))
    return valid
end

-- Helper function: check if valid MELSOFT command code
local function is_valid_melsoft_command(command)
    local valid = command_names[command] ~= nil
    debug_print(string.format("Checking command code 0x%04X: %s", command, valid and "VALID" or "INVALID"))
    return valid
end

-- Helper function: check if valid device type
local function is_valid_device_type(device_type)
    local valid = device_short_names[device_type] ~= nil
    debug_print(string.format("Checking device type 0x%02X: %s", device_type, valid and "VALID" or "INVALID"))
    return valid
end

-- Helper function: format address display
local function format_address_display(device_type, start_addr, bit_len)
    local device_short = get_device_short_name(device_type)
    if bit_len and bit_len > 0 and bit_len < 16 then
        -- Bit operation, display as X0.0 or M10.1
        local word_addr = math.floor(start_addr)
        local bit_pos = start_addr - word_addr
        if bit_pos > 0 then
            return string.format("%s%d.%d", device_short, word_addr, bit_pos * 10)
        else
            return string.format("%s%d", device_short, word_addr)
        end
    else
        -- Word operation, display as D100 or W20
        return string.format("%s%d", device_short, start_addr)
    end
end

-- Helper function: check if write command
local function is_write_command(command)
    return command == 0x1410 or command == 0x1411
end

-- Helper function: check if read command
local function is_read_command(command)
    return command == 0x0410 or command == 0x0411 or command == 0x0412
end

-- Helper function: read multi-byte values with proper endianness (little-endian)
local function read_multi_byte(buffer, offset, length)
    if length == 1 then
        return buffer(offset, 1):uint()
    elseif length == 2 then
        return buffer(offset, 2):le_uint()  -- Little-endian for 16-bit values
    elseif length == 4 then
        return buffer(offset, 4):le_uint()  -- Little-endian for 32-bit values
    else
        -- For other lengths, return 0 or handle appropriately
        return 0
    end
end

-- Helper function: swap bytes in a 16-bit value
local function swap_bytes_16(value)
    local low_byte = value % 256
    local high_byte = math.floor(value / 256)
    return low_byte * 256 + high_byte
end

-- Helper function: read command code (big-endian, no byte order reversal)
local function read_command_code(buffer, offset)
    return buffer(offset, 2):uint()  -- Big-endian (network byte order)
end

-- Helper function: add field with decimal display (with proper endianness)
local function add_field_with_decimal(subtree, hex_field, dec_field, buffer, offset, length, field_name)
    local value = read_multi_byte(buffer, offset, length)
    local hex_item = subtree:add(hex_field, buffer(offset, length))
    local dec_item = subtree:add(dec_field, buffer(offset, length))
    
    -- Set display text, showing both hex and decimal
    hex_item:set_text(string.format("%s: 0x%0" .. (length*2) .. "X (%d)", field_name, value, value))
    dec_item:set_text(string.format("%s (Decimal): %d (0x%0" .. (length*2) .. "X)", field_name, value, value))
    
    return value
end

-- Helper function: add write value field with swapped bytes and decimal display
local function add_write_value_with_swap(subtree, buffer, offset)
    -- 读取原始字节
    local raw_value = buffer(offset, 2):uint()
    local swapped_value = swap_bytes_16(raw_value)
    
    -- 添加原始十六进制值
    local hex_item = subtree:add(fields.write_value, buffer(offset, 2))
    hex_item:set_text(string.format("Write Value (Raw): 0x%04X", raw_value))
    
    -- 添加交换后的十六进制值
    local swapped_item = subtree:add(fields.write_value_swapped, buffer(offset, 2))
    swapped_item:set_text(string.format("Write Value (Swapped): 0x%04X", swapped_value))
    
    -- 添加十进制值（基于交换后的值）
    local dec_item = subtree:add(fields.write_value_dec, buffer(offset, 2))
    dec_item:set_text(string.format("Write Value (Decimal): %d (Swapped: 0x%04X)", swapped_value, swapped_value))
    
    return raw_value, swapped_value
end

-- Main dissector function
function melsoft_proto.dissector(buffer, pinfo, tree)
    debug_print("\n=== Starting packet parsing ===")
    debug_print("Packet length: " .. buffer:len())
    
    -- First perform heuristic detection
    local length = buffer:len()
    if length < 20 then
        debug_print("Packet too short (" .. length .. " bytes), not MELSOFT")
        return 0  -- Packet too short, not MELSOFT
    end
    
    debug_print("Packet length check passed: " .. length .. " bytes")
    
    -- Check module type (single byte, no endianness issue)
    local module_type = buffer(0, 1):uint()
    if not is_valid_melsoft_module_type(module_type) then
        debug_print("Invalid module type, skipping parsing")
        return 0  -- Not valid MELSOFT module type
    end
    
    -- Check frame type (single byte, no endianness issue)
    local frame_type = buffer(1, 1):uint()
    if not is_valid_melsoft_frame_type(frame_type) then
        debug_print("Invalid frame type, skipping parsing")
        return 0  -- Not valid MELSOFT frame type
    end
    
    -- Check network and controller IDs (single bytes, no endianness issue)
    local dst_net = buffer(9, 1):uint()
    local dst_controller = buffer(10, 1):uint()
    local src_net = buffer(13, 1):uint()
    local src_controller = buffer(14, 1):uint()
    
    if not (is_valid_node_id(dst_net, "Destination Network No.") and 
            is_valid_node_id(dst_controller, "Destination Controller No.") and
            is_valid_node_id(src_net, "Source Network No.") and 
            is_valid_node_id(src_controller, "Source Controller No.")) then
        debug_print("Network/Controller IDs invalid, skipping parsing")
        return 0  -- Network/Controller IDs invalid
    end
    
    -- Check data size field (16-bit, little-endian)
    local data_size = read_multi_byte(buffer, 19, 2)
    debug_print("Data size field value: " .. data_size .. " (0x" .. string.format("%04X", data_size) .. ")")
    debug_print("Remaining data length: " .. (length - 21) .. " bytes")
    
    if data_size > length - 21 then
        debug_print("Data size field value greater than actual remaining data, skipping parsing")
        debug_print("data_size=" .. data_size .. ", available data=" .. (length - 21))
        return 0  -- Data size field value greater than actual remaining data
    end
    
    debug_print("All heuristic checks passed, confirmed as MELSOFT protocol")
    
    -- Passed all checks, confirmed as MELSOFT protocol
    pinfo.cols.protocol = "MELSOFT"
    
    -- Create main protocol tree
    local subtree = tree:add(melsoft_proto, buffer(), "MELSOFT Protocol Data")
    
    local offset = 0
    
    -- ==============================
    -- SECTION 1: MSG HEADER (20 bytes)
    -- ==============================
    debug_print("Parsing MSG HEADER (offset " .. offset .. ")")
    local msg_header_subtree = subtree:add(melsoft_proto, buffer(offset, 20), "MSG HEADER (20 bytes)")
    
    -- Module type (single byte)
    local module_type_val = buffer(offset, 1):uint()
    debug_print("Module type: 0x" .. string.format("%02X", module_type_val))
    msg_header_subtree:add(fields.module_type, buffer(offset, 1))
    offset = offset + 1
    
    -- Frame type (single byte)
    local frame_type_val = buffer(offset, 1):uint()
    debug_print("Frame type: 0x" .. string.format("%02X", frame_type_val))
    msg_header_subtree:add(fields.frame_type, buffer(offset, 1))
    offset = offset + 1
    
    -- Sequence Number-1 (single byte)
    local seq_num1_val = buffer(offset, 1):uint()
    debug_print("Sequence Number-1: 0x" .. string.format("%02X", seq_num1_val))
    msg_header_subtree:add(fields.seq_num1, buffer(offset, 1))
    offset = offset + 1
    
    -- Unknown 6 bytes
    debug_print("Unknown1 field (6 bytes)")
    msg_header_subtree:add(fields.unknown1, buffer(offset, 6))
    offset = offset + 6
    
    -- Destination information subsection
    debug_print("Parsing destination information")
    local dst_info_subtree = msg_header_subtree:add(melsoft_proto, buffer(offset, 4), "Destination Info")
    dst_info_subtree:add(fields.dst_net, buffer(offset, 1))
    offset = offset + 1
    dst_info_subtree:add(fields.dst_controller, buffer(offset, 1))
    offset = offset + 1
    dst_info_subtree:add_le(fields.dst_module, buffer(offset, 2))
    offset = offset + 2
    
    -- Source information subsection
    debug_print("Parsing source information")
    local src_info_subtree = msg_header_subtree:add(melsoft_proto, buffer(offset, 4), "Source Info")
    src_info_subtree:add(fields.src_net, buffer(offset, 1))
    offset = offset + 1
    src_info_subtree:add(fields.src_controller, buffer(offset, 1))
    offset = offset + 1
    src_info_subtree:add_le(fields.src_module, buffer(offset, 2))
    offset = offset + 2
    
    -- Unknown 2 bytes
    debug_print("Unknown2 field (2 bytes)")
    msg_header_subtree:add(fields.unknown2, buffer(offset, 2))
    offset = offset + 2
    
    -- Data Size (16-bit, little-endian)
    local data_size_val = read_multi_byte(buffer, offset, 2)
    debug_print("Data size: " .. data_size_val .. " bytes (0x" .. string.format("%04X", data_size_val) .. ")")
    msg_header_subtree:add_le(fields.data_size, buffer(offset, 2))
    offset = offset + 2
    
    -- Set Info column display
    local module_type_str = ""
    if module_type_val == 0x51 then
        module_type_str = "Ethernet Req"
    elseif module_type_val == 0x57 then
        module_type_str = "CPU Req"
    elseif module_type_val == 0xD1 then
        module_type_str = "Ethernet Resp"
    elseif module_type_val == 0xD7 then
        module_type_str = "CPU Resp"
    else
        module_type_str = string.format("Unknown (0x%02X)", module_type_val)
    end
    
    local info_str = module_type_str
    debug_print("Packet type: " .. module_type_str)
    
    -- Check if response packet
    if module_type_val == 0xD1 or module_type_val == 0xD7 then
        -- ========================================
        -- RESPONSE PACKET - Response packet processing
        -- ========================================
        debug_print("Processing response packet")
        pinfo.cols.info:append(" [Response]")
        
        -- Add main response subtree
        local response_subtree = subtree:add(melsoft_proto, buffer(offset, data_size_val), 
            string.format("RESPONSE DATA (%d bytes)", data_size_val))
        
        -- Process different response formats based on frame type
        if frame_type_val == 0x01 then
            -- Data transfer type response
            debug_print("Data frame type response")
            
            -- ==============================
            -- SECTION: RESPONSE DATA
            -- ==============================
            if offset + data_size_val <= length then
                debug_print("Parsing RESPONSE DATA")
                
                -- According to the example, response DATA section has a specific structure:
                -- 1. First 11 bytes: response header (9c 0a 18 14 00 00 00 00 02 04 00)
                -- 2. Then multiple zero bytes (15 in the example)
                -- 3. Then command code (2 bytes)
                -- 4. Then sequence number-2 (1 byte)
                -- 5. Then end code (2 bytes)
                -- 6. Then response data (remaining bytes)
                
                local resp_offset = offset
                local bytes_parsed = 0
                
                -- 1. Parse first 11 bytes as response header
                if bytes_parsed + 11 <= data_size_val then
                    debug_print("Parsing response header (11 bytes)")
                    local resp_header_subtree = response_subtree:add(melsoft_proto, 
                        buffer(resp_offset, 11), "Response Header (11 bytes)")
                    resp_header_subtree:add(fields.response_header, buffer(resp_offset, 11))
                    resp_offset = resp_offset + 11
                    bytes_parsed = bytes_parsed + 11
                end
                
                -- 2. Skip zero bytes until non-zero (or until we find command code)
                -- In the example, there are 15 zero bytes after the header
                local zero_byte_count = 0
                while bytes_parsed < data_size_val and buffer(resp_offset, 1):uint() == 0x00 do
                    resp_offset = resp_offset + 1
                    bytes_parsed = bytes_parsed + 1
                    zero_byte_count = zero_byte_count + 1
                end
                
                if zero_byte_count > 0 then
                    debug_print(string.format("Skipped %d zero bytes", zero_byte_count))
                    local zero_subtree = response_subtree:add(melsoft_proto, 
                        buffer(resp_offset - zero_byte_count, zero_byte_count), 
                        string.format("Zero Padding (%d bytes)", zero_byte_count))
                    zero_subtree:add(fields.response_unknown, buffer(resp_offset - zero_byte_count, zero_byte_count))
                end
                
                -- 3. Parse command code (2 bytes, big-endian)
                if bytes_parsed + 2 <= data_size_val then
                    local cmd_in_resp = read_command_code(buffer, resp_offset)
                    debug_print("Command code in response: 0x" .. string.format("%04X", cmd_in_resp))
                    
                    local cmd_subtree = response_subtree:add(melsoft_proto, 
                        buffer(resp_offset, 2), "Response Command Code")
                    cmd_subtree:add(fields.command, buffer(resp_offset, 2))
                    
                    -- Get command name
                    local cmd_name = get_command_name(cmd_in_resp)
                    info_str = info_str .. string.format(" %s(0x%04X)", cmd_name, cmd_in_resp)
                    
                    resp_offset = resp_offset + 2
                    bytes_parsed = bytes_parsed + 2
                end
                
                -- 4. Parse sequence number-2 (1 byte)
                if bytes_parsed + 1 <= data_size_val then
                    local seq_num2_resp = buffer(resp_offset, 1):uint()
                    debug_print("Sequence Number-2 in response: 0x" .. string.format("%02X", seq_num2_resp))
                    
                    local seq_subtree = response_subtree:add(melsoft_proto, 
                        buffer(resp_offset, 1), "Response Sequence Number-2")
                    seq_subtree:add(fields.seq_num2, buffer(resp_offset, 1))
                    
                    resp_offset = resp_offset + 1
                    bytes_parsed = bytes_parsed + 1
                end
                
                -- 5. Parse end code (2 bytes, little-endian)
                if bytes_parsed + 2 <= data_size_val then
                    local end_code = read_multi_byte(buffer, resp_offset, 2)
                    debug_print("End code: 0x" .. string.format("%04X", end_code))
                    
                    local end_subtree = response_subtree:add(melsoft_proto, 
                        buffer(resp_offset, 2), "Response End Code")
                    end_subtree:add_le(fields.response_end_code, buffer(resp_offset, 2))
                    
                    info_str = info_str .. string.format(" End:0x%04X", end_code)
                    
                    resp_offset = resp_offset + 2
                    bytes_parsed = bytes_parsed + 2
                end
                
                -- 6. Parse remaining data as response data
                local remaining_bytes = data_size_val - bytes_parsed
                if remaining_bytes > 0 then
                    debug_print(string.format("Response data remaining: %d bytes", remaining_bytes))
                    
                    local data_subtree = response_subtree:add(melsoft_proto, 
                        buffer(resp_offset, remaining_bytes), "Response Data Content")
                    
                    -- Try to parse based on command type
                    if bytes_parsed >= 5 then
                        local cmd_in_resp = read_command_code(buffer, resp_offset - 5)
                        
                        -- Check if it's a read command
                        local is_read_cmd = is_read_command(cmd_in_resp)
                        
                        if is_read_cmd then
                            -- Read operation response, contains data count (1 byte) followed by data
                            if remaining_bytes >= 1 then
                                local data_count = buffer(resp_offset, 1):uint()
                                debug_print("Response data count (1 byte for read command): " .. data_count)
                                data_subtree:add(fields.response_data_count, buffer(resp_offset, 1))
                                info_str = info_str .. string.format(" DataCount:%d", data_count)
                                
                                -- Add actual data
                                if remaining_bytes > 1 then
                                    data_subtree:add(fields.response_data, buffer(resp_offset + 1, remaining_bytes - 1))
                                end
                            else
                                data_subtree:add(fields.response_data, buffer(resp_offset, remaining_bytes))
                            end
                        else
                            -- Non-read operation response, may contain data count (2 bytes) or other structure
                            if remaining_bytes >= 2 then
                                local data_count = read_multi_byte(buffer, resp_offset, 2)
                                debug_print("Response data count (2 bytes for non-read command): " .. data_count)
                                
                                -- We don't have a 2-byte data count field, so we'll just show as raw data
                                data_subtree:add(fields.response_data, buffer(resp_offset, remaining_bytes))
                            else
                                data_subtree:add(fields.response_data, buffer(resp_offset, remaining_bytes))
                            end
                        end
                    else
                        data_subtree:add(fields.response_data, buffer(resp_offset, remaining_bytes))
                    end
                    
                    resp_offset = resp_offset + remaining_bytes
                    bytes_parsed = bytes_parsed + remaining_bytes
                end
                
                -- Update offset
                offset = offset + data_size_val
                debug_print("Response data parsing completed, total bytes: " .. bytes_parsed)
                
            else
                debug_print("RESPONSE DATA length insufficient")
            end
        else
            -- Session transfer type response
            debug_print("Session frame type response")
            local resp_subtree = subtree:add(melsoft_proto, buffer(offset, data_size_val), "Session Response")
            resp_subtree:add(fields.response_data, buffer(offset, data_size_val))
            offset = offset + data_size_val
        end
    else
        -- ========================================
        -- REQUEST PACKET - Request packet processing
        -- ========================================
        debug_print("Processing request packet")
        pinfo.cols.info:append(" [Request]")
        
        -- Check if enough bytes for CMD HEADER
        if offset + 4 <= length then
            -- ==============================
            -- SECTION 2: CMD HEADER
            -- ==============================
            debug_print("Parsing CMD HEADER (offset " .. offset .. ")")
            local cmd_header_subtree = subtree:add(melsoft_proto, buffer(offset, 4), "CMD HEADER (4 bytes)")
            
            -- Flags (single byte)
            local flags_val = buffer(offset, 1):uint()
            debug_print("Flags: 0x" .. string.format("%02X", flags_val))
            cmd_header_subtree:add(fields.flags, buffer(offset, 1))
            offset = offset + 1
            
            -- Parity (single byte)
            local parity_val = buffer(offset, 1):uint()
            debug_print("Parity: 0x" .. string.format("%02X", parity_val))
            cmd_header_subtree:add(fields.parity, buffer(offset, 1))
            offset = offset + 1
            
            -- Cmd Offset (single byte)
            local cmdoff_val = buffer(offset, 1):uint()
            debug_print("Cmd Offset: 0x" .. string.format("%02X", cmdoff_val))
            cmd_header_subtree:add(fields.cmdoff, buffer(offset, 1))
            offset = offset + 1
            
            -- Size (single byte)
            local size_val = buffer(offset, 1):uint()
            debug_print("Size: " .. size_val .. " (0x" .. string.format("%02X", size_val) .. ")")
            cmd_header_subtree:add(fields.cmd_header_size, buffer(offset, 1))
            offset = offset + 1
            
            -- Unknown bytes (length specified by size field)
            if size_val > 0 and offset + size_val <= length then
                debug_print("Parsing CMD HEADER unknown bytes (length=" .. size_val .. ")")
                local unknown3_subtree = cmd_header_subtree:add(melsoft_proto, buffer(offset, size_val), "Unknown Bytes (size=" .. size_val .. ")")
                unknown3_subtree:add(fields.unknown3, buffer(offset, size_val))
                offset = offset + size_val
            elseif size_val > 0 then
                debug_print("CMD HEADER unknown bytes length insufficient: size=" .. size_val .. ", available=" .. (length - offset))
            end
        else
            debug_print("CMD HEADER length insufficient: need 4 bytes, available " .. (length - offset) .. " bytes")
        end
        
        -- CMD DATA
        if offset + 5 <= length then
            -- ==============================
            -- SECTION 3: CMD DATA
            -- ==============================
            debug_print("Parsing CMD DATA (offset " .. offset .. ")")
            local cmd_data_subtree = subtree:add(melsoft_proto, buffer(offset, 5), "CMD DATA (5 bytes)")
            
            -- Command code (big-endian, no byte order reversal)
            local cmd = read_command_code(buffer, offset)
            debug_print("Command code: 0x" .. string.format("%04X", cmd))
            cmd_data_subtree:add(fields.command, buffer(offset, 2))
            offset = offset + 2
            
            -- Verify command code
            is_valid_melsoft_command(cmd)
            
            -- Get command name
            local cmd_name = get_command_name(cmd)
            info_str = info_str .. string.format(" %s(0x%04X)", cmd_name, cmd)
            
            -- Sequence Number-2 (single byte)
            local seq_num2_val = buffer(offset, 1):uint()
            debug_print("Sequence Number-2: 0x" .. string.format("%02X", seq_num2_val))
            cmd_data_subtree:add(fields.seq_num2, buffer(offset, 1))
            offset = offset + 1
            
            -- Size 2 (16-bit, little-endian)
            local size2_val = read_multi_byte(buffer, offset, 2)
            debug_print("Size 2: " .. size2_val .. " (0x" .. string.format("%04X", size2_val) .. ")")
            cmd_data_subtree:add_le(fields.cmd_data_size, buffer(offset, 2))
            offset = offset + 2
            
            -- Check if it's a write command
            local is_write_cmd = is_write_command(cmd)
            debug_print("Is write command: " .. tostring(is_write_cmd))
        else
            debug_print("CMD DATA length insufficient: need 5 bytes, available " .. (length - offset) .. " bytes")
        end
        
        -- Re-fetch command, as it was already parsed above
        local cmd = read_command_code(buffer, offset - 5)  -- Get command code from CMD DATA section
        local is_write_cmd = is_write_command(cmd)
        
        -- DATA SUMMARY
        -- Determine DATA SUMMARY length based on command type
        local summary_length = 20  -- Default length for most commands
        if cmd == 0x0410 then
            -- 0410 word batch read command, DATA SUMMARY only has 11 bytes
            summary_length = 11
        end
        
        if offset + summary_length <= length then
            -- ==============================
            -- SECTION 4: DATA SUMMARY
            -- ==============================
            debug_print("Parsing DATA SUMMARY (offset " .. offset .. ", length " .. summary_length .. " bytes)")
            local summary_subtree = subtree:add(melsoft_proto, buffer(offset, summary_length), 
                string.format("DATA SUMMARY (%d bytes)", summary_length))
            
            -- Parse unknown bytes (9 bytes for all commands)
            if offset + 9 <= length then
                debug_print("DATA SUMMARY unknown bytes (9 bytes)")
                local unknown4_subtree = summary_subtree:add(melsoft_proto, buffer(offset, 9), "Unknown Bytes (9 bytes)")
                unknown4_subtree:add(fields.unknown4, buffer(offset, 9))
                offset = offset + 9
            end
            
            -- Parse SUBCMD (16-bit, little-endian)
            if offset + 2 <= length then
                local subcmd_val = read_multi_byte(buffer, offset, 2)
                debug_print("Sub Command: 0x" .. string.format("%04X", subcmd_val))
                summary_subtree:add_le(fields.subcmd, buffer(offset, 2))
                offset = offset + 2
            end
            
            -- For non-0410 commands, continue parsing subsequent fields
            if cmd ~= 0x0410 then
                -- Element counts subsection
                local element_count_subtree = summary_subtree:add(melsoft_proto, buffer(offset, 4), "Element Counts")
                
                -- 2-byte element count (single byte)
                local word_count_val = buffer(offset, 1):uint()
                debug_print("2-byte element count: " .. word_count_val)
                element_count_subtree:add(fields.word_count, buffer(offset, 1))
                offset = offset + 1
                
                -- bit element count (single byte)
                local bit_count_val = buffer(offset, 1):uint()
                debug_print("bit element count: " .. bit_count_val)
                element_count_subtree:add(fields.bit_count, buffer(offset, 1))
                offset = offset + 1
                
                -- 4-byte element count (single byte)
                local dword_count_val = buffer(offset, 1):uint()
                debug_print("4-byte element count: " .. dword_count_val)
                element_count_subtree:add(fields.dword_count, buffer(offset, 1))
                offset = offset + 1
                
                -- 8-byte element count (single byte)
                local qword_count_val = buffer(offset, 1):uint()
                debug_print("8-byte element count: " .. qword_count_val)
                element_count_subtree:add(fields.qword_count, buffer(offset, 1))
                offset = offset + 1
                
                -- Process unknown fields based on command type
                local unknown5_bytes = is_write_cmd and 4 or 6
                debug_print(string.format("DATA SUMMARY unknown bytes (%d bytes) for %s command", 
                    unknown5_bytes, is_write_cmd and "write" or "read"))
                
                if offset + unknown5_bytes <= length then
                    local unknown5_subtree = summary_subtree:add(melsoft_proto, buffer(offset, unknown5_bytes), 
                        string.format("Unknown Bytes (%d bytes)", unknown5_bytes))
                    unknown5_subtree:add(fields.unknown5, buffer(offset, unknown5_bytes))
                    offset = offset + unknown5_bytes
                else
                    debug_print(string.format("DATA SUMMARY unknown bytes length insufficient: need %d bytes, available %d bytes", 
                        unknown5_bytes, length - offset))
                end
                
                -- Add element count information
                local total_elements = word_count_val + bit_count_val + dword_count_val + qword_count_val
                debug_print("Total elements: " .. total_elements)
                if total_elements > 0 then
                    info_str = info_str .. string.format(" Elems:%d", total_elements)
                end
            end
        else
            debug_print("DATA SUMMARY length insufficient: need " .. summary_length .. " bytes, available " .. (length - offset) .. " bytes")
        end
        
        -- DATA ONE ELEMENT parsing
        -- Determine element size based on command type
        local element_size = 16  -- Default read command size
        if cmd == 0x0410 then
            element_size = 12  -- 0410 word batch read command, element size is 12字节
        elseif is_write_cmd then
            element_size = 18  -- Write command size is 18字节
        end
        
        debug_print(string.format("Starting DATA ELEMENT parsing, each element size: %d bytes", element_size))
        
        local element_count = 0
        
        while offset + element_size <= length and offset < 20 + data_size_val do
            element_count = element_count + 1
            
            debug_print("Parsing DATA ELEMENT " .. element_count .. " (offset " .. offset .. ", size " .. element_size .. " bytes)")
            
            -- ==============================
            -- SECTION 5: DATA ELEMENT (multiple)
            -- ==============================
            local element_subtree = subtree:add(melsoft_proto, buffer(offset, element_size), 
                string.format("DATA ELEMENT %d (%d bytes)", element_count, element_size))
            
            -- Element type (single byte)
            local elem_type = buffer(offset, 1):uint()
            debug_print("Element " .. element_count .. " type: 0x" .. string.format("%02X", elem_type))
            local elem_type_subtree = element_subtree:add(melsoft_proto, buffer(offset, 2), "Element Type and Code")
            elem_type_subtree:add(fields.element_type, buffer(offset, 1))
            offset = offset + 1
            
            -- Verify device type
            is_valid_device_type(elem_type)
            
            -- Element code (single byte)
            local elem_code = buffer(offset, 1):uint()
            debug_print("Element " .. element_count .. " code: 0x" .. string.format("%02X", elem_code))
            elem_type_subtree:add(fields.element_code, buffer(offset, 1))
            offset = offset + 1
            
            -- Parse based on command type
            if cmd == 0x0410 then
                -- 0410 command: 12-byte structure
                -- Start address (4 bytes, little-endian)
                local start_addr_val = add_field_with_decimal(element_subtree,
                    fields.start_addr, fields.start_addr_dec,
                    buffer, offset, 4, "Start Address")
                debug_print(string.format("Element %d start address: 0x%08X (%d)", 
                    element_count, start_addr_val, start_addr_val))
                offset = offset + 4
                
                -- Offset address (4 bytes, little-endian)
                local offset_addr_val = add_field_with_decimal(element_subtree,
                    fields.offset_addr, fields.offset_addr_dec,
                    buffer, offset, 4, "Offset Address")
                debug_print(string.format("Element %d offset address: 0x%08X (%d)", 
                    element_count, offset_addr_val, offset_addr_val))
                offset = offset + 4
                
                -- Read/write count (2 bytes, little-endian)
                local read_write_count = read_multi_byte(buffer, offset, 2)
                debug_print("Element " .. element_count .. " read/write count: " .. read_write_count)
                element_subtree:add_le(fields.read_write_count, buffer(offset, 2))
                offset = offset + 2
                
                -- Add to info string
                if element_count == 1 then
                    local device_short = get_device_short_name(elem_type)
                    local addr_display = format_address_display(elem_type, start_addr_val, 0)
                    info_str = info_str .. string.format(" %s Count:%d", addr_display, read_write_count)
                end
            else
                -- Other commands (0412, 1410, 1411, etc.)
                -- Start address (4 bytes, little-endian)
                local start_addr_val = add_field_with_decimal(element_subtree,
                    fields.start_addr, fields.start_addr_dec,
                    buffer, offset, 4, "Start Address")
                debug_print(string.format("Element %d start address: 0x%08X (%d)", 
                    element_count, start_addr_val, start_addr_val))
                offset = offset + 4
                
                -- Offset address (4 bytes, little-endian)
                local offset_addr_val = add_field_with_decimal(element_subtree,
                    fields.offset_addr, fields.offset_addr_dec,
                    buffer, offset, 4, "Offset Address")
                debug_print(string.format("Element %d offset address: 0x%08X (%d)", 
                    element_count, offset_addr_val, offset_addr_val))
                offset = offset + 4
                
                -- Control information subsection
                local control_subtree = element_subtree:add(melsoft_proto, buffer(offset, 6), "Control Information")
                
                -- Flags (16-bit, little-endian)
                local element_flags_val = read_multi_byte(buffer, offset, 2)
                debug_print("Element " .. element_count .. " Flags: 0x" .. string.format("%04X", element_flags_val))
                control_subtree:add_le(fields.element_flags, buffer(offset, 2))
                offset = offset + 2
                
                -- bit read/write length (16-bit, little-endian)
                local bit_len_val = read_multi_byte(buffer, offset, 2)
                debug_print("Element " .. element_count .. " bit length: " .. bit_len_val .. " (0x" .. string.format("%04X", bit_len_val) .. ")")
                control_subtree:add_le(fields.bit_len, buffer(offset, 2))
                offset = offset + 2
                
                -- 这里需要特殊处理：对于写命令，原来标记为write value的字段实际上是未知数据
                -- 原来标记为element unknown的字段才是实际的写入值
                if is_write_cmd then
                    -- 对于写命令：当前位置的2字节是未知字段1
                    local unknown_val = read_multi_byte(buffer, offset, 2)
                    debug_print("Element " .. element_count .. " unknown field 1: 0x" .. string.format("%04X", unknown_val))
                    control_subtree:add_le(fields.element_unknown1, buffer(offset, 2))
                    offset = offset + 2
                    
                    -- 写命令还有额外的2字节，这是实际的写入值
                    if offset + 2 <= length then
                        -- 使用新的辅助函数解析写入值（包含字节交换和十进制显示）
                        local raw_write_val, swapped_write_val = add_write_value_with_swap(control_subtree, buffer, offset)
                        offset = offset + 2
                        
                        -- 使用交换后的值进行info字符串显示
                        local write_val = swapped_write_val
                        
                        -- If it's the first element, add to info
                        if element_count == 1 then
                            local device_short = get_device_short_name(elem_type)
                            local addr_display = format_address_display(elem_type, start_addr_val, bit_len_val)
                            info_str = info_str .. string.format(" %s", addr_display)
                            
                            if bit_len_val >= 0 then
                                info_str = info_str .. string.format("[%dbit]", bit_len_val)
                            end
                            
                            -- 对于写操作，显示交换后的写入值
                            
                            info_str = info_str .. string.format("=0x%04X(%d)", write_val, write_val)
                            
                        end
                    else
                        debug_print("Write value field length insufficient for write command")
                    end
                else
                    -- 对于读命令（非0410）：当前位置的2字节是未知字段1
                    local unknown_val = read_multi_byte(buffer, offset, 2)
                    debug_print("Element " .. element_count .. " unknown field 1: 0x" .. string.format("%04X", unknown_val))
                    control_subtree:add_le(fields.element_unknown1, buffer(offset, 2))
                    offset = offset + 2
                    
                    -- If it's the first element, add to info
                    if element_count == 1 then
                        local device_short = get_device_short_name(elem_type)
                        local addr_display = format_address_display(elem_type, start_addr_val, bit_len_val)
                        info_str = info_str .. string.format(" %s", addr_display)
                        
                        if bit_len_val >= 0 then
                            info_str = info_str .. string.format("[%dbit]", bit_len_val)
                        end
                    end
                end
            end
        end
        
        debug_print("DATA ELEMENT parsing completed, total " .. element_count .. " elements")
        
        -- If there's remaining data, display as raw data
        if offset < length then
            local remaining_bytes = length - offset
            debug_print("Remaining data: " .. remaining_bytes .. " bytes (offset " .. offset .. ")")
            local raw_data_subtree = subtree:add(melsoft_proto, buffer(offset, remaining_bytes), 
                string.format("REMAINING DATA (%d bytes)", remaining_bytes))
            raw_data_subtree:add(fields.raw_bytes, buffer(offset, remaining_bytes))
        end
    end
    
    pinfo.cols.info:set(info_str)
    
    -- Set protocol column
    pinfo.cols.protocol = "MELSOFT"
    
    debug_print("=== Packet parsing completed ===")
    debug_print("Final offset: " .. offset .. ", packet length: " .. length)
    debug_print("Info column content: " .. info_str)
    
    -- Return successfully parsed length
    return buffer:len()
end

-- Heuristic registration (TCP/UDP)
melsoft_proto:register_heuristic("tcp", melsoft_proto.dissector)
melsoft_proto:register_heuristic("udp", melsoft_proto.dissector)

print("MELSOFT Protocol Dissector v1.13 loaded successfully!")
print("Features:")
print("  - Clear section names (MSG HEADER, CMD HEADER, CMD DATA, DATA SUMMARY, DATA ELEMENT)")
print("  - Field names displayed in each section")
print("  - Address and write values shown in both hexadecimal and decimal")
print("  - Detailed debug prints in console for troubleshooting")
print("  - Debug mode: " .. (DEBUG and "ENABLED" or "DISABLED"))
print("  - Auto-detection based on packet content")
print("  - Device types and commands mapped according to provided images")
print("  - Fixed endianness: Most multi-byte values use little-endian (low-byte first)")
print("  - Command codes use big-endian (network byte order)")
print("  - Fixed response packet parsing with correct command code and sequence number-2")
print("  - Fixed write command parsing with different DATA SUMMARY and DATA ELEMENT structures")
print("  - Fixed 0410 word batch read parsing:")
print("    * DATA SUMMARY length: 11 bytes (9 bytes unknown + 2 bytes SUBCMD)")
print("    * DATA ELEMENT size: 12 bytes")
print("    * Element structure: Device Type(1) + Device Code(1) + Start Address(4) + Offset Address(4) + Read/Write Count(2)")
print("  - Fixed response data count for read commands: 1 byte (not 2 bytes)")
print("  - Fixed write command parsing:")
print("    * For write commands (1410, 1411):")
print("      - Control information structure: Flags(2) + Bit Length(2) + Unknown Field 1(2) + Write Value(2)")
print("      - The previously named 'write value' field is actually unknown data")
print("      - The previously named 'element unknown' field is the actual write value")
print("  - Write value byte swapping and decimal display:")
print("    * Write values are displayed in three formats:")
print("      - Raw hexadecimal value (as stored in packet)")
print("      - Swapped hexadecimal value (after byte swapping)")
print("      - Decimal value (after byte swapping)")
print("    * Byte swapping converts little-endian to big-endian representation")
