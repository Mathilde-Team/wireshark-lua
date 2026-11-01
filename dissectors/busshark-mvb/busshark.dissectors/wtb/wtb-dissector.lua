-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/wtb/wtb-dissector.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
local flipping_byte_table = {
    0x00, 0x80, 0x40, 0xc0, 0x20, 0xa0, 0x60, 0xe0,
    0x10, 0x90, 0x50, 0xd0, 0x30, 0xb0, 0x70, 0xf0,
    0x08, 0x88, 0x48, 0xc8, 0x28, 0xa8, 0x68, 0xe8,
    0x18, 0x98, 0x58, 0xd8, 0x38, 0xb8, 0x78, 0xf8,
    0x04, 0x84, 0x44, 0xc4, 0x24, 0xa4, 0x64, 0xe4,
    0x14, 0x94, 0x54, 0xd4, 0x34, 0xb4, 0x74, 0xf4,
    0x0c, 0x8c, 0x4c, 0xcc, 0x2c, 0xac, 0x6c, 0xec,
    0x1c, 0x9c, 0x5c, 0xdc, 0x3c, 0xbc, 0x7c, 0xfc,
    0x02, 0x82, 0x42, 0xc2, 0x22, 0xa2, 0x62, 0xe2,
    0x12, 0x92, 0x52, 0xd2, 0x32, 0xb2, 0x72, 0xf2,
    0x0a, 0x8a, 0x4a, 0xca, 0x2a, 0xaa, 0x6a, 0xea,
    0x1a, 0x9a, 0x5a, 0xda, 0x3a, 0xba, 0x7a, 0xfa,
    0x06, 0x86, 0x46, 0xc6, 0x26, 0xa6, 0x66, 0xe6,
    0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6, 0x76, 0xf6,
    0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee,
    0x1e, 0x9e, 0x5e, 0xde, 0x3e, 0xbe, 0x7e, 0xfe,
    0x01, 0x81, 0x41, 0xc1, 0x21, 0xa1, 0x61, 0xe1,
    0x11, 0x91, 0x51, 0xd1, 0x31, 0xb1, 0x71, 0xf1,
    0x09, 0x89, 0x49, 0xc9, 0x29, 0xa9, 0x69, 0xe9,
    0x19, 0x99, 0x59, 0xd9, 0x39, 0xb9, 0x79, 0xf9,
    0x05, 0x85, 0x45, 0xc5, 0x25, 0xa5, 0x65, 0xe5,
    0x15, 0x95, 0x55, 0xd5, 0x35, 0xb5, 0x75, 0xf5,
    0x0d, 0x8d, 0x4d, 0xcd, 0x2d, 0xad, 0x6d, 0xed,
    0x1d, 0x9d, 0x5d, 0xdd, 0x3d, 0xbd, 0x7d, 0xfd,
    0x03, 0x83, 0x43, 0xc3, 0x23, 0xa3, 0x63, 0xe3,
    0x13, 0x93, 0x53, 0xd3, 0x33, 0xb3, 0x73, 0xf3,
    0x0b, 0x8b, 0x4b, 0xcb, 0x2b, 0xab, 0x6b, 0xeb,
    0x1b, 0x9b, 0x5b, 0xdb, 0x3b, 0xbb, 0x7b, 0xfb,
    0x07, 0x87, 0x47, 0xc7, 0x27, 0xa7, 0x67, 0xe7,
    0x17, 0x97, 0x57, 0xd7, 0x37, 0xb7, 0x77, 0xf7,
    0x0f, 0x8f, 0x4f, 0xcf, 0x2f, 0xaf, 0x6f, 0xef,
    0x1f, 0x9f, 0x5f, 0xdf, 0x3f, 0xbf, 0x7f, 0xff,
};

-- Flip bytes
-- @param buffer byte
-- @return flipped bytes
local function static_flip_byte(buf)
    local result = ByteArray.new()
    result:set_size(buf:len())
    for i = 0, buf:len() - 1, 1 do
        local value = buf(i, 1):uint()
        local new_or = flipping_byte_table[value + 1]
        result:set_index(i, new_or)
    end

    if buf:len() ~= result:len() then
        error("Wrong convertion of bytes. Result has not same length than input buffer")
    end
    return result:tvb("Data"):range(0, result:len())
end

local function static_skip_flip_byte(buf)
    return buf
end

local flipping_byte_service = {
    flip_byte = static_flip_byte
}

local wtb_dis = {
    _DESCRIPTION = "WTB Protocol dissector",
    _VERSION = 0.1,
    _AUTHOR = "Codewerk GmbH",
    _NAME = "Busshark",
    preamble_size = 1, -- size  flag  0x7E mark start and end (0x7E) of of data payload
    proto = nil,
    link_header = nil,
    frame_presence_response = nil,
    node_report = nil,
    master_report = nil,
    network_header = nil,
    data = nil,
    mtc_map = nil,
    node_period_map = nil,
    link_ctl_map = {
        [0] = "Process Data",
        [1] = "Message Data",
        [2] = "Supervisory Detect",
        [3] = "Supervisory Status",
        [4] = "Supervisory SetInt",
        [5] = "Supervisory SetEnd",
        [6] = "Supervisory Unname",
        [7] = "Supervisory Naming",
        [8] = "Supervisory Topography",
        [9] = "Supervisory Presence",
        [10] = "Not supported type"
    },
    frame_type = {
        [0] = "Response",
        [1] = "Request",
        [3] = "Unknown Frame"
    },
    -- LLC decoder map like WTB Line Monitor (WLM)
    link_ctl_decode_map = {
        [0x80] = "M --- PD",
        [0x88] = "M --I PD",
        [0x90] = "M -C- PD",
        [0x98] = "M -CI PD",
        [0xa0] = "M A-- PD",
        [0xa8] = "M A-I PD",
        [0xb0] = "M AC- PD",
        [0xb8] = "M ACI PD",
        [0x00] = "S --- PD",
        [0x08] = "S --I PD",
        [0x10] = "S -C- PD",
        [0x18] = "S -CI PD",
        [0x20] = "S A-- PD",
        [0x28] = "S A-I PD",
        [0x30] = "S AC- PD",
        [0x38] = "S ACI PD",
        [0x87] = "M --  MD",
        [0x97] = "M -C  MD",
        [0xa7] = "M A-  MD",
        [0xb7] = "M AC  MD",
        [0x07] = "S --  MD",
        [0x17] = "S -C  MD",
        [0x27] = "S A-  MD",
        [0x37] = "S AC  MD",
        [0xc0] = "M Detect",
        [0x40] = "S Detect",
        [0xc1] = "M Status",
        [0xd1] = "M Status RI",
        [0x41] = "S Status",
        [0x51] = "S Status RI",
        [0xc2] = "M SetInt",
        [0x42] = "S SetInt",
        [0xc3] = "M SetEnd",
        [0x43] = "S SetEnd",
        [0xc4] = "M Unname",
        [0x44] = "S Unname",
        [0xc5] = "M Naming",
        [0x45] = "S Naming",
        [0xc6] = "M Topo",
        [0x46] = "S Topo",
        [0xc7] = "M Pres",
        [0xcf] = "M Pres --I",
        [0xd7] = "M Pres RI-",
        [0xdf] = "M Pres RII",
        [0x47] = "S Pres",
        [0x4f] = "S Pres --I",
        [0x57] = "S Pres RI-",
        [0x5f] = "S Pres RII",
        [0xff] = "???"
    }
}

-- Initialize wtb dissector header fields
function wtb_dis.init(
    wtb,
    wtb_proto_link_header,
    wtb_proto_network_header,
    wtb_data,
    wtb_proto_frame_pd_request,
    wtb_proto_frame_pd_response,
    wtb_proto_frame_md_request,
    wtb_proto_frame_md_response,
    wtb_proto_frame_detect_request,
    wtb_proto_frame_detect_response,
    wtb_proto_frame_status_request,
    wtb_proto_frame_status_response,
    wtb_proto_frame_setint_request,
    wtb_proto_frame_setint_response,
    wtb_proto_frame_setend_request,
    wtb_proto_frame_setend_response,
    wtb_proto_frame_uname_request,
    wtb_proto_frame_uname_response,
    wtb_proto_frame_naming_request,
    wtb_proto_frame_naming_response,
    wtb_proto_frame_topography_request,
    wtb_proto_frame_topography_response,
    wtb_proto_frame_presence_request,
    wtb_proto_frame_presence_response,
    wtb_proto_node_report,
    wtb_proto_master_report,
    wtb_proto_strength,
    wtb_proto_user_report,
    wtb_proto_node_descriptor,
    mtc,
    node_period_map)
    wtb_dis.proto = wtb
    wtb_dis.mtc = mtc
    wtb_dis.node_period_map = node_period_map
    wtb_proto_link_header.fields.frame_type = ProtoField.uint8(
        "busshark.wtb.type",
        "frame type",
        base.DEC,
        wtb_dis.frame_type,
        nil,
        "Busshark WTB frame type"
    )

    wtb_proto_link_header.fields.link_control = ProtoField.uint8(
        "busshark.wtb.lc",
        "link control",
        base.HEX,
        nil,
        nil,
        "WTB link control"
    )

    wtb_proto_link_header.fields.telegram_type = ProtoField.uint8(
        "busshark.wtb.telegram",
        "telegram type",
        base.DEC,
        wtb_dis.link_ctl_map,
        nil,
        "WTB telegram type"
    )

    wtb_proto_link_header.fields.llc_decoded = ProtoField.uint8(
        "busshark.wtb.llc_decoded",
        "llc decoded",
        base.HEX,
        wtb_dis.link_ctl_decode_map,
        nil,
        "WTB LLC decoded"
    )

    wtb_proto_link_header.fields.destination_device = ProtoField.uint8(
        "busshark.wtb.dd",
        "destination device",
        base.HEX,
        nil,
        nil,
        "WTB destination device"
    )

    wtb_proto_link_header.fields.source_device = ProtoField.uint8(
        "busshark.wtb.sd",
        "source device",
        base.HEX,
        nil,
        nil,
        "WTB source device"
    )

    wtb_proto_link_header.fields.link_data_size = ProtoField.uint8(
        "busshark.wtb.sz",
        "link data size",
        base.DEC,
        nil,
        nil,
        "WTB link data size"
    )

    wtb_dis.link_header = wtb_proto_link_header

    wtb.fields.crc = ProtoField.uint16(
        "busshark.wtb.crc",
        "checksum",
        base.DEC,
        nil,
        nil,
        "WTB frame checksum"
    )

    wtb_proto_network_header.fields.fn = ProtoField.uint8(
        "busshark.wtb.md.fn",
        "final node",
        base.DEC,
        nil,
        nil,
        "fn description"
    )

    wtb_proto_network_header.fields.ff = ProtoField.uint8(
        "busshark.wtb.md.ff",
        "final function",
        base.DEC,
        nil,
        nil,
        "ff description"
    )

    wtb_proto_network_header.fields.on = ProtoField.uint8(
        "busshark.wtb.md.on",
        "origin node",
        base.DEC,
        nil,
        nil,
        "on description"
    )

    wtb_proto_network_header.fields.of = ProtoField.uint8(
        "busshark.wtb.md.of",
        "origin function",
        base.DEC,
        nil,
        nil,
        "of description"
    )

    wtb_proto_network_header.fields.mtc = ProtoField.uint8(
        "busshark.wtb.md.mtc",
        "message transport control",
        base.HEX,
        nil,
        nil,
        "mtc description"
    )

    wtb_proto_network_header.fields.mtc_type = ProtoField.string(
        "busshark.wtb.md.mtc_type",
        "message transport control type",
        base.UNICODE,
        "mtc type description"
    )

    -- transport layer
    mtc.init(wtb_proto_network_header.fields, "busshark.wtb.md")
    wtb_dis.network_header = wtb_proto_network_header

    wtb_dis.data = wtb_data
    wtb_data.fields.data1 = ProtoField.bytes(
        "busshark.wtb.data.0",
        "0x00",
        base.SPACE,
        nil,
        nil,
        "wtb frame data first 16 bytes")
    wtb_data.fields.data2 = ProtoField.bytes(
        "busshark.wtb.data.16",
        "0x10",
        base.SPACE,
        nil,
        nil,
        "wtb frame data second 16 bytes")
    wtb_data.fields.data3 = ProtoField.bytes(
        "busshark.wtb.data.32",
        "0x20",
        base.SPACE,
        nil,
        nil,
        "wtb frame data third 16 bytes")
    wtb_data.fields.data4 = ProtoField.bytes(
        "busshark.wtb.data.48",
        "0x30",
        base.SPACE,
        nil,
        nil,
        "wtb frame data 4th 16 bytes")
    wtb_data.fields.data5 = ProtoField.bytes(
        "busshark.wtb.data.64",
        "0x40",
        base.SPACE,
        nil,
        nil,
        "wtb frame data 5th 16 bytes")
    wtb_data.fields.data6 = ProtoField.bytes(
        "busshark.wtb.data.80",
        "0x50",
        base.SPACE,
        nil,
        nil,
        "wtb frame data 6th 16 bytes")
    wtb_data.fields.data7 = ProtoField.bytes(
        "busshark.wtb.data.96",
        "0x60",
        base.SPACE,
        nil,
        nil,
        "wtb frame data 7th 16 bytes")
    wtb_data.fields.data8 = ProtoField.bytes(
        "busshark.wtb.data.112",
        "0x70",
        base.SPACE,
        nil,
        nil,
        "wtb frame data 8th 16 bytes")

    wtb_proto_node_report.fields.da1 = ProtoField.bool(
        "busshark.wtb.node-report.da1",
        "Line A1 disturbed")
    wtb_proto_node_report.fields.da2 = ProtoField.bool(
        "busshark.wtb.node-report.da2",
        "Line A2 disturbed")
    wtb_proto_node_report.fields.db1 = ProtoField.bool(
        "busshark.wtb.node-report.db1",
        "Line B1 disturbed")
    wtb_proto_node_report.fields.db2 = ProtoField.bool(
        "busshark.wtb.node-report.db2",
        "Line B2 disturbed")
    wtb_proto_node_report.fields.int = ProtoField.bool(
        "busshark.wtb.node-report.int",
        "Intermediate setting")
    wtb_proto_node_report.fields.dsc = ProtoField.bool(
        "busshark.wtb.node-report.dsc",
        "Node descriptor changed")
    wtb_proto_node_report.fields.slp = ProtoField.bool(
        "busshark.wtb.node-report.slp",
        "Sleep request")
    wtb_proto_node_report.fields.sam = ProtoField.bool(
        "busshark.wtb.node-report.sam",
        "Same orientation as master")

    wtb_dis.node_report = wtb_proto_node_report

    wtb_proto_master_report.fields.dma = ProtoField.bool(
        "busshark.wtb.master-report.dma",
        "Line A main channel disturbed")
    wtb_proto_master_report.fields.dmb = ProtoField.bool(
        "busshark.wtb.master-report.dmb",
        "Line B main channel disturbed")
    wtb_proto_master_report.fields.c12 = ProtoField.bool(
        "busshark.wtb.master-report.c12",
        "Sent to direction 2")
    wtb_proto_master_report.fields.inh = ProtoField.bool(
        "busshark.wtb.master-report.inh",
        "Inhibit inauguration")
    wtb_dis.master_report = wtb_proto_master_report

    wtb_proto_strength.fields.mas = ProtoField.bool(
        "busshark.wtb.strength.mas",
        "Strong master")
    wtb_proto_strength.fields.nns = ProtoField.uint8(
        "busshark.wtb.strength.nns",
        "Number of named nodes")
    wtb_proto_strength.fields.ins = ProtoField.bool(
        "busshark.wtb.strength.ins",
        "Insist (true), Yield (false)")
    wtb_dis.strength = wtb_proto_strength

    wtb_proto_frame_presence_request.fields.mastertopo = ProtoField.uint16(
        "busshark.wtb.mastertopo",
        "Master topo")

    wtb_proto_user_report.fields.ur0 = ProtoField.bool(
        "busshark.wtb.user-report.ur0",
        "User Report 0")
    wtb_proto_user_report.fields.ur1 = ProtoField.bool(
        "busshark.wtb.user-report.ur1",
        "User Report 1")
    wtb_proto_user_report.fields.ur2 = ProtoField.bool(
        "busshark.wtb.user-report.ur2",
        "User Report 2")
    wtb_proto_user_report.fields.ur3 = ProtoField.bool(
        "busshark.wtb.user-report.ur3",
        "User Report 3")
    wtb_proto_user_report.fields.ur4 = ProtoField.bool(
        "busshark.wtb.user-report.ur4",
        "User Report 4")
    wtb_proto_user_report.fields.ur5 = ProtoField.bool(
        "busshark.wtb.user-report.ur5",
        "User Report 5")
    wtb_proto_user_report.fields.ur6 = ProtoField.bool(
        "busshark.wtb.user-report.ur6",
        "User Report 6")
    wtb_proto_user_report.fields.ur7 = ProtoField.bool(
        "busshark.wtb.user-report.ur7",
        "User Report 7")
    wtb_dis.user_report = wtb_proto_user_report

    wtb_proto_node_descriptor.fields.nfs = ProtoField.uint8(
        "busshark.wtb.node-descriptor.nodeframesize",
        "Node frame size")
    wtb_proto_node_descriptor.fields.np = ProtoField.string(
        "busshark.wtb.node-descriptor.nodeperiod",
        "Node period",
        base.UNICODE,
        "node period description")
    wtb_proto_node_descriptor.fields.nt = ProtoField.uint8(
        "busshark.wtb.node-descriptor.nodetype",
        "Node type")
    wtb_proto_node_descriptor.fields.nv = ProtoField.uint8(
        "busshark.wtb.node-descriptor.nodeversion",
        "Node version")
    wtb_dis.node_descriptor = wtb_proto_node_descriptor

    wtb_proto_frame_naming_request.fields.dir1 = ProtoField.bool(
        "busshark.wtb.naming-request.dir1",
        "Naming ascending")
    wtb_proto_frame_naming_request.fields.your_address = ProtoField.uint8(
        "busshark.wtb.naming-request.addr",
        "Your Address")

    wtb_proto_frame_topography_request.fields.bottomaddr = ProtoField.uint8(
        "busshark.wtb.topo-request.bottomaddr",
        "Bottom address")

    wtb_proto_frame_topography_request.fields.mastertopo = ProtoField.uint16(
        "busshark.wtb.mastertopo",
        "Master topo")

    wtb_proto_frame_topography_response.fields.node_type = ProtoField.uint8(
        "busshark.wtb.topo-reponse.nodetype",
        "Node type")
    wtb_proto_frame_topography_response.fields.node_version = ProtoField.uint8(
        "busshark.wtb.topo-reponse.nodeversion",
        "Node version")
    wtb_proto_frame_topography_response.fields.inaug_size = ProtoField.uint8(
        "busshark.wtb.topo-reponse.inaug_size",
        "Inauguration data size")
    wtb_proto_frame_topography_response.fields.sam = ProtoField.bool(
        "busshark.wtb.topo-reponse.sam",
        "Same orientation as master")
    wtb_proto_frame_topography_response.fields.node_address = ProtoField.uint8(
        "busshark.wtb.topo-reponse.addr",
        "Node address")

    wtb_dis.frame_pd_reques = wtb_proto_frame_pd_request
    wtb_dis.frame_pd_response = wtb_proto_frame_pd_response
    wtb_dis.frame_md_request = wtb_proto_frame_md_request
    wtb_dis.frame_md_response = wtb_proto_frame_md_response
    wtb_dis.frame_detect_request = wtb_proto_frame_detect_request
    wtb_dis.frame_detect_response = wtb_proto_frame_detect_response
    wtb_dis.frame_status_request = wtb_proto_frame_status_request
    wtb_dis.frame_status_response = wtb_proto_frame_status_response
    wtb_dis.frame_setint_request = wtb_proto_frame_setint_request
    wtb_dis.frame_setint_response = wtb_proto_frame_setint_response
    wtb_dis.frame_setend_request = wtb_proto_frame_setend_request
    wtb_dis.frame_setend_response = wtb_proto_frame_setend_response
    wtb_dis.frame_uname_request = wtb_proto_frame_uname_request
    wtb_dis.frame_uname_response = wtb_proto_frame_uname_response
    wtb_dis.frame_naming_request = wtb_proto_frame_naming_request
    wtb_dis.frame_naming_response = wtb_proto_frame_naming_response
    wtb_dis.frame_topography_request = wtb_proto_frame_topography_request
    wtb_dis.frame_topography_response = wtb_proto_frame_topography_response
    wtb_dis.frame_presence_request = wtb_proto_frame_presence_request
    wtb_dis.frame_presence_response = wtb_proto_frame_presence_response
end

-- wrap service
function flip_byte(buf)
    return flipping_byte_service.flip_byte(buf)
end

-- Map link control field to frame types
--
-- @param lc_tree table, wireshark table
-- @param lci any, wireshark tvbRange
local function map_link_control(lc_tree, lci, lc_buffer)
    local lc = static_flip_byte(lci)
    lc_tree:add(wtb_dis.link_header.fields.frame_type, lc_buffer, lc:bitfield(7, 1))
    if lc:bitfield(6, 1) == 0 then
        -- Process data
        if lc:bitfield(0, 3) == 0 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 0)
            -- Message data
        elseif lc:bitfield(0, 3) == 7 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 1)
        else
            -- Default: Not supported type
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 10)
        end
        -- Supervisory data
    elseif lc:bitfield(6, 1) == 1 then
        local last_three = lc:bitfield(0, 3)
        if last_three == 0 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 2)
        elseif last_three == 1 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 6)
        elseif last_three == 2 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 4)
        elseif last_three == 3 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 8)
        elseif last_three == 4 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 3)
        elseif last_three == 5 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 7)
        elseif last_three == 6 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 5)
        elseif last_three == 7 then
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 9)
        else
            lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 10)
        end
    else
        -- Default: Not supported type
        lc_tree:add(wtb_dis.link_header.fields.telegram_type, lc_buffer, 10)
    end
    -- LLC decoder like WTB Line Monitor (WLM)
    lc_tree:add(wtb_dis.link_header.fields.llc_decoded, lc_buffer, lci:uint())
end

local function chunk(wtb_frame, chunk_size)
    local size = wtb_frame:len()
    local frame_data = {}
    local offset = chunk_size
    for i = 1, ((size / chunk_size) + 1) do
        if (size > offset) then
            frame_data[i] = wtb_frame(offset - chunk_size, chunk_size)
            offset = offset + chunk_size
        else
            frame_data[i] = wtb_frame(offset - chunk_size, (size - offset + chunk_size))
            return frame_data
        end
    end
    return frame_data
end

-- Dissector for WTB Protocol - strength
local function wtb_strength(tree, strength)
    tree:add(wtb_dis.strength.fields.mas, strength:bitfield(0, 1))
    tree:add(wtb_dis.strength.fields.nns, strength:bitfield(1, 6))
    tree:add(wtb_dis.strength.fields.ins, strength:bitfield(7, 1))
end

local function wtb_node_report(tree, nr)
    tree:add(wtb_dis.node_report.fields.da1, nr:bitfield(0, 1))
    tree:add(wtb_dis.node_report.fields.da2, nr:bitfield(1, 1))
    tree:add(wtb_dis.node_report.fields.db1, nr:bitfield(2, 1))
    tree:add(wtb_dis.node_report.fields.db2, nr:bitfield(3, 1))
    tree:add(wtb_dis.node_report.fields.int, nr:bitfield(4, 1))
    tree:add(wtb_dis.node_report.fields.dsc, nr:bitfield(5, 1))
    tree:add(wtb_dis.node_report.fields.slp, nr:bitfield(6, 1))
    tree:add(wtb_dis.node_report.fields.sam, nr:bitfield(7, 1))
end

local function wtb_master_report(tree, mr)
    tree:add(wtb_dis.master_report.fields.dma, mr:bitfield(7, 1))
    tree:add(wtb_dis.master_report.fields.dmb, mr:bitfield(6, 1))
    tree:add(wtb_dis.master_report.fields.c12, mr:bitfield(5, 1))
    tree:add(wtb_dis.master_report.fields.inh, mr:bitfield(4, 1))
end

local function wtb_user_report(tree, ur)
    tree:add(wtb_dis.user_report.fields.ur0, ur:bitfield(0, 1))
    tree:add(wtb_dis.user_report.fields.ur1, ur:bitfield(1, 1))
    tree:add(wtb_dis.user_report.fields.ur2, ur:bitfield(2, 1))
    tree:add(wtb_dis.user_report.fields.ur3, ur:bitfield(3, 1))
    tree:add(wtb_dis.user_report.fields.ur4, ur:bitfield(4, 1))
    tree:add(wtb_dis.user_report.fields.ur5, ur:bitfield(5, 1))
    tree:add(wtb_dis.user_report.fields.ur6, ur:bitfield(6, 1))
    tree:add(wtb_dis.user_report.fields.ur7, ur:bitfield(7, 1))
end

local function wtb_node_description(tree, buffer)
    tree:add(wtb_dis.node_descriptor.fields.nfs, buffer(0, 1))
    local np = flip_byte(buffer(1, 1)):uint()
    local node_period = wtb_dis.node_period_map[np % 8]
    tree:add(wtb_dis.node_descriptor.fields.np, node_period)
    tree:add(wtb_dis.node_descriptor.fields.nt, buffer(2, 1))
    tree:add(wtb_dis.node_descriptor.fields.nv, buffer(3, 1))
end

-- Dissector for WTB Protocol
--
-- @param buffer any, buffer containing wtb packet
-- @param tree any, analyse tree
function wtb_dis.dissector(buffer, tree, fill_header)
    local wtb_tree = tree:add(wtb_dis.proto, buffer())
    if fill_header.payload_version > 1 then
        -- disable flip bytes, because since payload version 2 its done by FPGA
        flipping_byte_service.flip_byte = static_skip_flip_byte
    else
        flipping_byte_service.flip_byte = static_flip_byte
    end

    local lc_buffer = buffer(1 + wtb_dis.preamble_size, 1)
    local lc = flip_byte(lc_buffer)

    local wtb_lh_tree = wtb_tree:add(wtb_dis.link_header, buffer(1 + wtb_dis.preamble_size, 3))
    -- Link Control Fields
    wtb_lh_tree:add(wtb_dis.link_header.fields.link_control, buffer(1 + wtb_dis.preamble_size, 1), lc:uint())
    map_link_control(wtb_lh_tree, lc, lc_buffer)
    -- Other fields
    wtb_lh_tree:add(
        wtb_dis.link_header.fields.destination_device,
        buffer(0 + wtb_dis.preamble_size, 1),
        flip_byte(buffer(0 + wtb_dis.preamble_size, 1)):uint())
    wtb_lh_tree:add(
        wtb_dis.link_header.fields.source_device,
        buffer(2 + wtb_dis.preamble_size, 1),
        flip_byte(buffer(2 + wtb_dis.preamble_size, 1)):uint())
    wtb_lh_tree:add(
        wtb_dis.link_header.fields.link_data_size,
        buffer(3 + wtb_dis.preamble_size, 1),
        flip_byte(buffer(3 + wtb_dis.preamble_size, 1)):uint())

    local data_size = flip_byte(buffer(3 + wtb_dis.preamble_size, 1)):uint()
    local data_offset = 0;

    if lc:bitfield(1, 1) == 0 and lc:bitfield(5, 3) == 7 then
        -- luacheck: push ignore 542
        if lc:bitfield(0, 1) == 1 then
            -- MD request

            -- no specific fields
        else
            -- MD response
            data_offset = 5
            local wtb_nh_tree = wtb_tree:add(wtb_dis.network_header, buffer(4 + wtb_dis.preamble_size, 5))
            wtb_nh_tree:add(
                wtb_dis.network_header.fields.fn,
                buffer(4 + wtb_dis.preamble_size, 1),
                flip_byte(buffer(4 + wtb_dis.preamble_size, 1)):uint()
            )

            wtb_nh_tree:add(
                wtb_dis.network_header.fields.ff,
                buffer(5 + wtb_dis.preamble_size, 1),
                flip_byte(buffer(5 + wtb_dis.preamble_size, 1)):uint()
            )

            wtb_nh_tree:add(
                wtb_dis.network_header.fields.on,
                buffer(6 + wtb_dis.preamble_size, 1),
                flip_byte(buffer(6 + wtb_dis.preamble_size, 1)):uint()
            )

            wtb_nh_tree:add(
                wtb_dis.network_header.fields.of,
                buffer(7 + wtb_dis.preamble_size, 1),
                flip_byte(buffer(7 + wtb_dis.preamble_size, 1)):uint()
            )

            local mtc_buffer = buffer(8 + wtb_dis.preamble_size, 1)
            local mtc_type = flip_byte(mtc_buffer):uint()
            wtb_nh_tree:add(
                wtb_dis.network_header.fields.mtc,
                mtc_buffer,
                mtc_type
            )

            local mtc_type_id = wtb_dis.mtc.mtc_type_get(mtc_type)
            local mtc_type_str = wtb_dis.mtc.map[mtc_type_id]
            if mtc_type_str ~= nil then
                wtb_nh_tree:add(wtb_dis.network_header.fields.mtc_type, mtc_type_str)
            end

            wtb_dis.mtc.mtc_type_fields(wtb_nh_tree, wtb_dis.network_header.fields, mtc_type_id, mtc_type)

            -- transport layer
            if (mtc_type_id == MTC_TYPE_CR) then
                wtb_nh_tree:add(
                    wtb_dis.network_header.fields.cr_conn_ref,
                     buffer(10, 2),
                    flip_byte(buffer(10, 2):uint())
                )

                wtb_nh_tree:add(
                    wtb_dis.network_header.fields.cr_msg_size,
                    buffer(12, 4),
                    flip_byte(buffer(12, 4):uint())
                )

                wtb_nh_tree:add(
                    wtb_dis.network_header.fields.cr_credit,
                     buffer(16, 1),
                     flip_byte(buffer(16, 1):uint())
                )

                wtb_nh_tree:add(
                    wtb_dis.network_header.fields.cr_pack_size,
                     buffer(16, 1),
                    flip_byte(buffer(12, 1):uint())
                )

                wtb_nh_tree:add(wtb_dis.network_header.fields.cr_session_header, buffer(17, 1))
            elseif (mtc_type_id == MTC_TYPE_CC) then
                wtb_nh_tree:add(
                    wtb_dis.network_header.fields.cc_conn_ref,
                    buffer(10, 2),
                    flip_byte(buffer(10, 2):uint())
                )

                wtb_nh_tree:add(
                    wtb_dis.network_header.fields.cc_credit,
                    buffer(12, 1),
                    flip_byte(buffer(12, 1):uint())
                )

                wtb_nh_tree:add(
                    wtb_dis.network_header.fields.cc_pack_size,
                    buffer(12, 1),
                    flip_byte(buffer(12, 1):uint())
                )
            elseif (mtc_type_id == MTC_TYPE_DR) then
                wtb_nh_tree:add(wtb_dis.network_header.fields.dr_reason, buffer(10, 1), flip_byte(buffer(10, 1):uint()))
            elseif (mtc_type_id == MTC_TYPE_DC) then
                wtb_nh_tree:add(wtb_dis.network_header.fields.dc_reaons, buffer(10, 1), flip_byte(buffer(10, 1):uint()))
            end
        end
        -- luacheck: pop
    end
    if lc:bitfield(1, 1) == 0 and lc:bitfield(5, 3) == 0 then
        -- luacheck: push ignore 542
        if lc:bitfield(0, 1) == 1 then
            -- PD request

            -- no specific fields (only data)
        else
            -- PD response

            -- no specific fields (only data)
        end
        -- luacheck: pop
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 0 then
        if lc:bitfield(0, 1) == 1 then
            -- Detect request
            data_offset = 2
            local wtb_dr_tree = wtb_tree:add(wtb_dis.frame_detect_request, buffer(4 + wtb_dis.preamble_size, 2))
            local wtb_mr_tree = wtb_dr_tree:add(wtb_dis.master_report, buffer(4 + wtb_dis.preamble_size, 1))
            local mr = flip_byte(buffer(4 + wtb_dis.preamble_size, 1))
            wtb_master_report(wtb_mr_tree, mr)
            local wtb_strength_tree = wtb_dr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)
        else
            -- Detect response
            data_offset = 2
            local wtb_dr_tree = wtb_tree:add(wtb_dis.frame_detect_request, buffer(4 + wtb_dis.preamble_size, 2))
            local wtb_mr_tree = wtb_dr_tree:add(wtb_dis.master_report, buffer(4 + wtb_dis.preamble_size, 1))
            local mr = flip_byte(buffer(4 + wtb_dis.preamble_size, 1))
            wtb_master_report(wtb_mr_tree, mr)
            local wtb_strength_tree = wtb_dr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)
        end
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 1 then
        if lc:bitfield(0, 1) == 1 then
            -- Status request
            data_offset = 4
            local wtb_sr_tree = wtb_tree:add(wtb_dis.frame_status_request, buffer(4 + wtb_dis.preamble_size, 4))
            local wtb_mr_tree = wtb_sr_tree:add(wtb_dis.master_report, buffer(4 + wtb_dis.preamble_size, 1))
            local mr = flip_byte(buffer(4 + wtb_dis.preamble_size, 1))
            wtb_master_report(wtb_mr_tree, mr)
            local wtb_strength_tree = wtb_sr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)
        else
            -- Status response
            data_offset = 8
            local wtb_sr_tree = wtb_tree:add(wtb_dis.frame_status_response, buffer(4 + wtb_dis.preamble_size, 8))
            local wtb_nr_tree = wtb_sr_tree:add(wtb_dis.node_report, buffer(4 + wtb_dis.preamble_size, 1))
            local nr = flip_byte(buffer(4 + wtb_dis.preamble_size, 1))
            wtb_node_report(wtb_nr_tree, nr)
            local wtb_strength_tree = wtb_sr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)
            local wtb_userreport_tree = wtb_sr_tree:add(wtb_dis.user_report, buffer(7 + wtb_dis.preamble_size, 1))
            local userreport = flip_byte(buffer(7 + wtb_dis.preamble_size, 1))
            wtb_user_report(wtb_userreport_tree, userreport)
            local wtb_nodedescriptor_tree = wtb_sr_tree:add(
                wtb_dis.node_descriptor,
                buffer(8 + wtb_dis.preamble_size, 4)
            )

            wtb_node_description(wtb_nodedescriptor_tree, buffer(8 + wtb_dis.preamble_size, 4))
        end
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 2 then
        -- luacheck: push ignore 542
        if lc:bitfield(0, 1) == 1 then
            -- SetInt request

            -- no specific fields
        else
            -- SetInt response

            -- no specific fields
        end
        -- luacheck: pop
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 3 then
        -- luacheck: push ignore 542
        if lc:bitfield(0, 1) == 1 then
            -- SetEnd request
            data_offset = 2
            local wtb_sr_tree = wtb_tree:add(wtb_dis.frame_setend_request, buffer(4 + wtb_dis.preamble_size, 2))
            local wtb_strength_tree = wtb_sr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)
        else
            -- SetEnd response

            -- no specific fields
        end
        -- luacheck: pop
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 4 then
        -- luacheck: push ignore 542
        if lc:bitfield(0, 1) == 1 then
            -- Unname request

            -- no specific fields
        else
            -- Unname response

            -- no specific fields
        end
        -- luacheck: pop
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 5 then
        -- luacheck: push ignore 542
        if lc:bitfield(0, 1) == 1 then
            -- Naming request
            data_offset = 2
            local wtb_nr_tree = wtb_tree:add(wtb_dis.frame_naming_request, buffer(4 + wtb_dis.preamble_size, 2))
            local temp = flip_byte(buffer(4 + wtb_dis.preamble_size, 1))
            wtb_nr_tree:add(wtb_dis.frame_naming_request.fields.dir1, temp:bitfield(7, 1))
            wtb_nr_tree:add(wtb_dis.frame_naming_request.fields.your_address, temp:uint() % 64)
            local wtb_strength_tree = wtb_nr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)
        else
            -- Naming response

            -- no specific fields
        end
        -- luacheck: pop
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 6 then
        if lc:bitfield(0, 1) == 1 then
            -- Topography request
            data_offset = 4
            local wtb_tr_tree = wtb_tree:add(wtb_dis.frame_topography_request, buffer(4 + wtb_dis.preamble_size, 4))
            wtb_tr_tree:add(wtb_dis.frame_topography_request.fields.bottomaddr, buffer(4 + wtb_dis.preamble_size, 1))
            local wtb_strength_tree = wtb_tr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)

            local np = flip_byte(buffer(6 + wtb_dis.preamble_size, 1)):uint()
            local node_period = wtb_dis.node_period_map[np / 16]
            wtb_tr_tree:add(wtb_dis.node_descriptor.fields.np, node_period)

            local mastertopo = (flip_byte(buffer(6 + wtb_dis.preamble_size, 1)):uint() % 16) * 256
                + flip_byte(buffer(7 + wtb_dis.preamble_size, 1)):uint()

            wtb_tr_tree:add(
                wtb_dis.frame_topography_request.fields.mastertopo,
                buffer(6 + wtb_dis.preamble_size, 2),
                mastertopo
            )
        else
            -- Topography response
            data_offset = 4
            local wtb_tr_tree = wtb_tree:add(wtb_dis.frame_topography_response, buffer(4 + wtb_dis.preamble_size, 4))
            wtb_tr_tree:add(
                wtb_dis.frame_topography_response.fields.node_type,
                buffer(4 + wtb_dis.preamble_size, 1))
            wtb_tr_tree:add(
                wtb_dis.frame_topography_response.fields.node_version,
                buffer(5 + wtb_dis.preamble_size, 1))
            local temp = buffer(6 + wtb_dis.preamble_size, 1):uint()
            wtb_tr_tree:add(
                wtb_dis.frame_topography_response.fields.sam,
                temp / 128)
            wtb_tr_tree:add(
                wtb_dis.frame_topography_response.fields.node_address,
                temp % 64)
            wtb_tr_tree:add(
                wtb_dis.frame_topography_response.fields.inaug_size,
                buffer(7 + wtb_dis.preamble_size, 1))
        end
    end
    if lc:bitfield(1, 1) == 1 and lc:bitfield(5, 3) == 7 then
        if lc:bitfield(0, 1) == 1 then
            -- Presence request
            data_offset = 4
            local wtb_pr_tree = wtb_tree:add(wtb_dis.frame_presence_request, buffer(4 + wtb_dis.preamble_size, 4))
            local wtb_mr_tree = wtb_pr_tree:add(wtb_dis.master_report, buffer(4 + wtb_dis.preamble_size, 1))
            local mr = flip_byte(buffer(4 + wtb_dis.preamble_size, 1))
            wtb_master_report(wtb_mr_tree, mr)
            local wtb_strength_tree = wtb_pr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)

            local mastertopo = (flip_byte(buffer(6 + wtb_dis.preamble_size, 1)):uint() % 16) * 256
                + flip_byte(buffer(7 + wtb_dis.preamble_size, 1)):uint()

            wtb_pr_tree:add(
                wtb_dis.frame_presence_request.fields.mastertopo,
                buffer(6 + wtb_dis.preamble_size, 2),
                mastertopo
            )
        else
            -- Presence response
            data_offset = 2
            local wtb_pr_tree = wtb_tree:add(wtb_dis.frame_presence_response, buffer(4 + wtb_dis.preamble_size, 2))
            local wtb_nr_tree = wtb_pr_tree:add(wtb_dis.node_report, buffer(4 + wtb_dis.preamble_size, 1))
            local nr = flip_byte(buffer(4 + wtb_dis.preamble_size, 1))
            wtb_node_report(wtb_nr_tree, nr)
            local wtb_strength_tree = wtb_pr_tree:add(wtb_dis.strength, buffer(5 + wtb_dis.preamble_size, 1))
            local strength = flip_byte(buffer(5 + wtb_dis.preamble_size, 1))
            wtb_strength(wtb_strength_tree, strength)
        end
    end

    -- Only add data if size is greater than 0
    local payload_size = data_size - data_offset
    if payload_size > 0 then
        local payload_start = 4 + wtb_dis.preamble_size + data_offset
        local data = chunk(buffer(payload_start, payload_size), 16)
        if data ~= nil then
            local data_tree = wtb_tree:add(wtb_dis.data,
                buffer(payload_start, payload_size))

            -- add frame_data to subtree view
            for k, v in pairs(data) do
                data_tree:add(wtb_dis.data.fields["data" .. k], v, flip_byte(v):raw())
                if (k > 7) then
                    break
                end
            end
        end
    end

    wtb_tree:add(
        wtb_dis.proto.fields.crc,
        buffer(buffer:len() - 3, 2),
        flip_byte(buffer(buffer:len() - 3, 2)):uint())
end

return wtb_dis
