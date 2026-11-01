-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/busshark-fillheader.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
local fillheader = {
    _DESCRIPTION = "Interpret busshark fill header for ethernet packets",
    _VERSION = 0.2,
    _AUTHOR = "Coderwerk GmbH",
    _NAME = "Busshark",
    proto_map = {
        [0] = "MVB",
        [1] = "WTB"
    },
    filter_config_map = {
        [0] = "No filter is active.",
        [1] = "The line is active.",
        [2] = "The RTI filter is active",
        [3] = "The RTI and line filter is active",
        [4] = "Unkown filter settings.",
        [5] = "Unkown filter settings.",
        [6] = "Unkown filter settings.",
        [7] = "Unkown filter settings."
    },
    empty_header = {
        payload_version = 0,
        seq_number = 0,
        serial = 0,
        hw_revision = 0,
        sw_revision = 0,
        filter_config_line_a = 0,
        filter_config_line_b = 0
    }
}

-- Map detected protocol to Symbol
--
--@param: bus_proto, 2 bytes from fill header frame
-- RETRUN: Symbol MVB if C001/6B2D[old format]/696C/3030[ci4Rail format] or WTB if C002
function fillheader.map_proto(bus_proto)
    local bus_hex = bus_proto:bytes():tohex()
    if bus_hex == "C001" or bus_hex == "6B2D" or bus_hex == "696C" or bus_hex == "3030" then
        return 0
    elseif bus_hex == "C002" then
        return 1
    else
        return nil
    end
end


-- Initialize fill header fields
function fillheader.init(eth_fill)
    eth_fill.fields.payload_version = ProtoField.uint8("busshark.fill.version", "payload version", base.DEC, nil, nil,
        "Payload version")
    eth_fill.fields.seq_number = ProtoField.uint64("busshark.fill.seq", "sequence number", base.DEC, nil, nil,
        "Sequence Number Ethernet-Frame")
    eth_fill.fields.serial = ProtoField.uint32("busshark.fill.serial", "serial number busshark", base.DEC, nil, nil,
        "Busshark serial number")
    eth_fill.fields.hw_revision = ProtoField.uint8("busshark.fill.hw_revision", "hardware revision busshark", base.DEC,
        nil, nil, "Busshark hardware revision")
    eth_fill.fields.sw_revision = ProtoField.uint16("busshark.fill.sw_revision", "software version busshark", base.DEC,
        nil, nil, "Busshark software revision")
    eth_fill.fields.configured_protocol = ProtoField.uint16("busshark.fill.configured_proto", "configured protocol",
        base.DEC, fillheader.proto_map, nil, "Configured bus protocol from busshark")

    eth_fill.fields.filter_config_line_a = ProtoField.uint8(
        "busshark.fill.filter_config_line_a",
        "MVB filter settings of line A",
        base.DEC,
        fillheader.filter_config_map,
        nil,
        "Configured bus protocol from busshark"
    )

    eth_fill.fields.filter_config_line_b = ProtoField.uint8(
        "busshark.fill.filter_config_line_b",
        "MVB filter settings of line B",
        base.DEC,
        fillheader.filter_config_map,
        nil,
        "Configured bus protocol from busshark"
    )
end

-- Analysing ethernet packet fillheader created by busshark
--
--@param: tree, subtree element for displayed values extracted from fillheader
--@param: header 32 bytes containg fillheader
function fillheader.analyse(header, proto, info, tree)
    info.cols.protocol = fillheader._NAME

    local payload_version = header(0, 1):uint()
    local seq_number = header(1, 8):uint64()
    local serial = header(9, 4):uint()
    local hw_revision = header(13, 1):uint()
    local sw_revision = header(14, 2):uint()

    local filter_config_line_a_byte_index = 16;
    local filter_config_line_b_byte_index = 17;

    local filter_config_line_a = header(filter_config_line_a_byte_index, 1):uint()
    local filter_config_line_b = header(filter_config_line_b_byte_index, 1):uint()

    tree:add(proto.fields.payload_version, header(0, 1), payload_version)
    tree:add(proto.fields.seq_number, header(1, 8), seq_number)
    tree:add(proto.fields.serial, header(9, 4), serial)
    tree:add(proto.fields.hw_revision, header(13, 1), hw_revision)
    tree:add(proto.fields.sw_revision, header(14, 2), sw_revision)

    local det_proto
    if(payload_version < 2) then
        det_proto = fillheader.map_proto(header(16, 2))
    else
        det_proto = fillheader.map_proto(header(28, 2))
    end

    if det_proto ~= nil then
        tree:add(proto.fields.configured_protocol, header(28, 2), det_proto)
        if (det_proto == 0 and payload_version > 1) then
            -- handle ci4Rail format, which did not provide a filter config field
            if(serial ~= 1378698089) then
                tree:add(
                    proto.fields.filter_config_line_a,
                    header(filter_config_line_a_byte_index, 1),
                    filter_config_line_a
                )

                tree:add(
                    proto.fields.filter_config_line_b,
                    header(filter_config_line_b_byte_index, 1),
                    filter_config_line_b
                )
            end
        end
    end

    return {
        payload_version = payload_version,
		seq_number = 0,
		serial = 0,
		hw_revision = 0,
		sw_revision = 0
    }
end

return fillheader
