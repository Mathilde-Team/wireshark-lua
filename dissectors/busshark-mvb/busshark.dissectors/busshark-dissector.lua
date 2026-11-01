-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/busshark-dissector.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
-- inspired by Torsten from http://torsten-traenkner.de/linux/development/wireshark.php
--
-- Load required modules
-- Notice: use module file name

local current_path = string.sub(debug.getinfo(1).source, 2, string.len("/busshark-dissector.lua") * -1)

-- set package path to current script folder
local origin_package_path = package.path
package.path = package.path .. ';' .. current_path .. '/?.lua;'

local slave = require("mvb/mvb-slaveframe")
local bs_meta = require("mvb/mvb-meta")
local meta_analyse = require("meta/meta-analyse")
local mvb_analyse = require("mvb/mvb-analyse")
local wtb_analyse = require("wtb/wtb-analyse")
local fill = require("busshark-fillheader")
local mtc = require("busshark-mtc")
local wtb_dis = require("wtb/wtb-dissector")

-- restore origin package path
package.path = origin_package_path

node_period_map = {
    [0] = "1 T_bp (25ms)",
    [1] = "2 T_bp (50ms)",
    [2] = "4 T_bp (100ms)",
    [3] = "8 T_bp (200ms)",
    [4] = "16 T_bp (400ms)",
    [5] = "32 T_bp (800ms)",
    [6] = "64 T_bp (1600ms)",
    [7] = "128 T_bp (3200ms)"
}

-- Busshark fill header definition
local busshark_fill = Proto("busshark", "Busshark Fill Header")
fill.init(busshark_fill)

mvb_protocol = Proto("mvb", "mvb")
local wtb_proto = Proto("wtb", "WTB Protocol")
local wtb_proto_data = Proto("busshark.wtb.data", "WTB Data")
local wtb_proto_link_header = Proto("busshark.wtb.link-header", "WTB Link-Header")
local wtb_proto_network_header = Proto("busshark.wtb.network-header", "WTB Network-Header")
local wtb_proto_frame_pd_request = Proto("busshark.wtb.pd-request", "WTB PD Request")
local wtb_proto_frame_pd_response = Proto("busshark.wtb.pd-response", "WTB PD Response")
local wtb_proto_frame_md_request = Proto("busshark.wtb.md-request", "WTB MD Request")
local wtb_proto_frame_md_response = Proto("busshark.wtb.md-response", "WTB MD Response")
local wtb_proto_frame_detect_request = Proto("busshark.wtb.detect-request", "WTB Detect Request")
local wtb_proto_frame_detect_response = Proto("busshark.wtb.detect-response", "WTB Detect Response")
local wtb_proto_frame_status_request = Proto("busshark.wtb.status-request", "WTB Status Request")
local wtb_proto_frame_status_response = Proto("busshark.wtb.status-response", "WTB Status Response")
local wtb_proto_frame_setint_request = Proto("busshark.wtb.setint-request", "WTB SetInt Request")
local wtb_proto_frame_setint_response = Proto("busshark.wtb.setint-response", "WTB SetInt Response")
local wtb_proto_frame_setend_request = Proto("busshark.wtb.setend-request", "WTB SetEnd Request")
local wtb_proto_frame_setend_response = Proto("busshark.wtb.setend-response", "WTB SetEnd Response")
local wtb_proto_frame_uname_request = Proto("busshark.wtb.uname-request", "WTB Unname Request")
local wtb_proto_frame_uname_response = Proto("busshark.wtb.uname-response", "WTB Unname Response")
local wtb_proto_frame_naming_request = Proto("busshark.wtb.naming-request", "WTB Naming Request")
local wtb_proto_frame_naming_response = Proto("busshark.wtb.naming-response", "WTB Naming Response")
local wtb_proto_frame_topography_request = Proto("busshark.wtb.topography-request", "WTB Topography Request")
local wtb_proto_frame_topography_response = Proto("busshark.wtb.tophgraphy-response", "WTB Topography Response")
local wtb_proto_frame_presence_request = Proto("busshark.wtb.presence-request", "WTB Presence Request")
local wtb_proto_frame_presence_response = Proto("busshark.wtb.presence-response", "WTB Presence Response")
local wtb_proto_node_report = Proto("busshark.wtb.node-report", "WTB Node Report")
local wtb_proto_master_report = Proto("busshark.wtb.master-report", "WTB Master Report")
local wtb_proto_strength = Proto("busshark.wtb.strength", "WTB Strength")
local wtb_proto_user_report = Proto("busshark.wtb.user-report", "WTB User Report")
local wtb_proto_node_descriptor = Proto("busshark.wtb.node-descriptor", "WTB Node Descriptor")
wtb_dis.init(
    wtb_proto,
    wtb_proto_link_header,
    wtb_proto_network_header,
    wtb_proto_data,
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
    node_period_map
)

function busshark_fill.init()
    local ether_dissector = DissectorTable.get("ethertype")
    ether_dissector:add(0xc001, busshark_fill)
    ether_dissector:add(0xc002, busshark_fill)
end

-- Busshark dissector protocol decision method based on
-- busshark fill header
--
--@param buffer
--@param packet_info
--@tree
function busshark_fill.dissector(buffer, packet_info, tree)
    local fill_header = buffer(0, 30)
    -- Fill header not showing if old header in use
    -- First two bytes == 4255
    local fill_header_values = fill.empty_header
    if fill_header(0, 2):bytes():tohex() ~= "4255" then
        local fill_tree = tree:add(busshark_fill, fill_header, "Busshark Fill Header")
        fill_header_values = fill.analyse(fill_header, busshark_fill, packet_info, fill_tree)
    end

    local bus_hex = fill.map_proto(fill_header(16, 2))

    if bus_hex == nil then
        bus_hex = fill.map_proto(fill_header(28, 2))
    end

    -- Unkonw protocol
    if bus_hex == nil then
        print("Error: not provided known proto checked Values:" ..
            "'0x" .. fill_header(16, 2):bytes():tohex() .. "', '0x" .. fill_header(28, 2):bytes():tohex() .. "'")
        return
    end

     apply_settings()
    -- MVB = fillheader.proto_map[0]
    if bus_hex == 0 or bus_hex == nil then
        busshark_meta(
            buffer(30, buffer:len() - 30),
            packet_info, tree,
            mvb_protocol_internal_dissector,
            mvb_protocol.name,
            fill_header_values
        )
    end
    -- WTB
    if bus_hex == 1 then
        busshark_meta(
            buffer(30, buffer:len() - 30),
            packet_info,
            tree,
            wtb_dis.dissector,
            wtb_proto.name,
            fill_header_values
        )
    end
end

-- #####################
-- ## Busshark meta Layer  ##
-- #####################
busshark_meta_layer = Proto("busshark.meta", "Busshark Meta")

frame_type_map = { [0] = "Undefined", [1] = "Masterframe", [2] = "Slaveframe", [3] = "Unkown" }
line_map = { [0] = "B", [1] = "A" }
wtb_pin_map = { [0] = "Pin 1,2", [1] = "Pin 4,5" }
protocol_map = {
    [0] = "MVB",
    [1] = "WTB",
    [2] = "ProfiBus",
    [3] = "Undefined Input"
}

local bs_meta_layer_fields = busshark_meta_layer.fields
bs_meta_layer_fields.frame_number = ProtoField.uint64("busshark.meta.frame_number", "frame number", base.DEC)
bs_meta_layer_fields.receive_time = ProtoField.relative_time("busshark.meta.receive_time", "receive time")
bs_meta_layer_fields.frame_duration = ProtoField.relative_time("busshark.meta.frame_duration", "frame duration")
bs_meta_layer_fields.frame_type =
    ProtoField.uint8("busshark.meta.frame_type", "frame type", base.DEC, frame_type_map, 0xc7, "frame type")
bs_meta_layer_fields.line = ProtoField.uint8("busshark.meta.line", "line", base.DEC, line_map, 0x20, "line")
bs_meta_layer_fields.pins = ProtoField.uint8(
    "busshark.meta.wtb.pins",
    "pins",
    base.DEC,
     wtb_pin_map,
     0x20,
     "Indicates which WTB pins were used for transmission"
)
bs_meta_layer_fields.protocol =
    ProtoField.uint8("busshark.meta.protocol", "protocol", base.DEC, protocol_map, 0xc0, "protocol")
bs_meta_layer_fields.status_codes =
    ProtoField.bytes(
        "busshark.meta.status_codes",
        "status codes",
        base.SPACE,
        nil --[[valuestring]],
        nil,
        "status codes description"
    )

-- #####################
-- ## mvb mf Layer ##
-- #####################

f_code_map = {
    [0] = "2 bytes process data",
    [1] = "4 bytes process data",
    [2] = "8 bytes process data",
    [3] = "16 bytes process data",
    [4] = "32 bytes process data",
    [5] = "reserved",
    [6] = "reserved",
    [7] = "reserved",
    [8] = "master transfer",
    [9] = "general event",
    [10] = "reserved",
    [11] = "reserved",
    [12] = "message data",
    [13] = "group event",
    [14] = "single event",
    [15] = "device status"
}

mvb_master_frame_layer = Proto("mvb.mf", "mvb master frame")
local mvb_master_frame_layer_fields = mvb_master_frame_layer.fields
mvb_master_frame_layer_fields.f_code =
    ProtoField.uint8("mvb.mf.f_code", "f code", base.DEC, f_code_map, 0xF0, "f_code description")
mvb_master_frame_layer_fields.address =
    ProtoField.uint16("mvb.mf.address", "address", base.DEC, nil, 0x0FFF, "address description")
mvb_master_frame_layer_fields.crc = ProtoField.uint8("mvb.mf.crc", "crc", base.HEX, nil, nil, "crc description")

-- #####################
-- ## mvb sf Layer ##
-- #####################

mvb_slave_frame_layer = Proto("mvb.sf", "mvb slave frame")
local mvb_slave_frame_layer_fields = mvb_slave_frame_layer.fields
mvb_slave_frame_layer_fields.data1 =
    ProtoField.bytes("mvb.sf.data.1", "data 1", base.SPACE, nil --[[valuestring]], nil, "slave frame data description")
mvb_slave_frame_layer_fields.data2 =
    ProtoField.bytes("mvb.sf.data.2", "data 2", base.SPACE, nil --[[valuestring]], nil, "slave frame data description")
mvb_slave_frame_layer_fields.data3 =
    ProtoField.bytes("mvb.sf.data.3", "data 3", base.SPACE, nil --[[valuestring]], nil, "slave frame data description")
mvb_slave_frame_layer_fields.data4 =
    ProtoField.bytes("mvb.sf.data.4", "data 4", base.SPACE, nil --[[valuestring]], nil, "slave frame data description")
mvb_slave_frame_layer_fields.crc1 = ProtoField.uint8("mvb.sf.crc.1", "crc 1", base.HEX, nil, nil, "crc description")
mvb_slave_frame_layer_fields.crc2 = ProtoField.uint8("mvb.sf.crc.2", "crc 2", base.HEX, nil, nil, "crc description")
mvb_slave_frame_layer_fields.crc3 = ProtoField.uint8("mvb.sf.crc.3", "crc 3", base.HEX, nil, nil, "crc description")
mvb_slave_frame_layer_fields.crc4 = ProtoField.uint8("mvb.sf.crc.4", "crc 4", base.HEX, nil, nil, "crc description")

-- #########################################
-- ## mvb protocol all layers chained ##
-- #########################################
mvb_protocol.prefs.sample_each_ns = Pref.uint("samples.each.ns", 20, "samples each ns")
mvb_protocol.prefs.enable_time_analyze = Pref.bool("enable.time.analyze", true, "enable_time_analyze")
mvb_protocol.prefs.enable_conversation_analyze =
    Pref.bool("enable.conversation.analyze", true, "enable_conversation_analyze")
mvb_protocol.prefs.create_frame_info_text = Pref.bool("create.frame_info_text", true, "create_frame_info_text")

sample_each_ns = 0
enable_time_analyze = false
enable_conversation_analyze = false
create_frame_info_text = false

function apply_settings()
    sample_each_ns = mvb_protocol.prefs.sample_each_ns
    enable_time_analyze = mvb_protocol.prefs.enable_time_analyze
    enable_conversation_analyze = mvb_protocol.prefs.enable_conversation_analyze
    create_frame_info_text = mvb_protocol.prefs.create_frame_info_text
    apply_timing_settings()
end

-- Parse busshark meta header and parse protocol
--
--@param buffer, raw packet data
--@param packet_info, wireshark packet information
--@param tree, wireshark gui tree
--@param proto_dis, dissector function for current protocol
--@param proto_name, name of protocol to show in wireshark gui table
--@param fill_header, extracted data of the fill header
function busshark_meta(buffer, packet_info, tree, proto_dis, proto_name, fill_header)
    packet_info.cols.protocol = proto_name
    -- extract meta data
    bs_meta.extract(buffer, fill_header)

    local bs_meta_layer_tree = tree:add(busshark_meta_layer, buffer(0, bs_meta.size))

    local receive_time = mvb_protocol.prefs.sample_each_ns * buffer(8, 8):uint64()
    local receive_time_s = (receive_time / 1000000000):tonumber()
    local receive_time_ns = (receive_time % 1000000000):tonumber()

    bs_meta_layer_tree:add(bs_meta_layer_fields.frame_number, buffer(0, 8))
    bs_meta_layer_tree:add(
        bs_meta_layer_fields.receive_time,
        buffer(8, 8),
        NSTime.new(receive_time_s, receive_time_ns)
    )

    if fill_header.payload_version > 2 then
        local frame_duration = mvb_protocol.prefs.sample_each_ns * buffer(16, 2):uint64()
        local frame_duration_s = (frame_duration / 1000000000):tonumber()
        local frame_duration_ns = (frame_duration % 1000000000):tonumber()

        bs_meta_layer_tree:add(
            bs_meta_layer_fields.frame_duration,
            buffer(16, 2),
            NSTime.new(frame_duration_s, frame_duration_ns)
        )
    end

    if (proto_name:lower() ~= "wtb") then
        bs_meta_layer_tree:add(bs_meta_layer_fields.frame_type, bs_meta.firstCode, bs_meta.frame_type):set_generated()
        bs_meta_layer_tree:add(bs_meta_layer_fields.line, bs_meta.firstCode):set_generated()
    else
        bs_meta_layer_tree:add(bs_meta_layer_fields.pins, bs_meta.firstCode):set_generated()
    end

    bs_meta_layer_tree:add(bs_meta_layer_fields.protocol, bs_meta.firstCode):set_generated()

    -- Unknown frame_type split status code in symbols
    if (bs_meta.frame_type == 0x03) then
        bs_meta_layer_tree:add(bs_meta_layer_fields.status_codes, bs_meta.status_codes)
    else
        -- process correct frame type data
        bs_meta_layer_tree:add(bs_meta_layer_fields.status_codes, bs_meta.status_codes)
        local frame = buffer(bs_meta.size + 1, bs_meta.code_size - 2)
        proto_dis(frame, tree, fill_header)
    end
end

function mvb_protocol_internal_dissector(buffer, tree)
    local mvb_tree = tree:add(mvb_protocol, buffer())
    local frame = buffer

    if (bs_meta.frame_type == 0x01) then
        -- Master frame
        mvb_mf_layer_tree = mvb_tree:add(mvb_master_frame_layer, frame)

        local size = frame:len()
        if (size < 1) then
            return
        end
        mvb_mf_layer_tree:add(mvb_master_frame_layer_fields.f_code, frame(0, 1))
        if (size < 2) then
            return
        end

        mvb_mf_layer_tree:add(mvb_master_frame_layer_fields.address, frame(0, 2))
        if (size < 3) then
            return
        end

        mvb_mf_layer_tree:add_le(mvb_master_frame_layer_fields.crc, frame(2, 1))
    elseif (bs_meta.frame_type == 0x02) then
        -- Slave frame
        mvb_sf_layer_tree = mvb_tree:add(mvb_slave_frame_layer, frame)
        local data, crc = slave.extract_crc(frame)
        if data ~= nil and crc ~= nil then
            -- subtree for frame_data and checksums
            local subtree_fd = mvb_sf_layer_tree:add(mvb_slave_frame_layer, "frame data")
            local subtree_crc = mvb_sf_layer_tree:add(mvb_slave_frame_layer, "checksums")
            -- add frame_data to subtree view
            for k, v in pairs(data) do
                local data_field = mvb_slave_frame_layer_fields["data" .. k];
                if (data_field == nil) then
                    break;
                end
                subtree_fd:add(data_field, v)
            end
            -- add checksums to subtree view
            for k, v in pairs(crc) do
                local crc_field = mvb_slave_frame_layer_fields["crc" .. k];
                if (crc_field == nil) then
                    break;
                end

                subtree_crc:add(crc_field, v)
            end
        else
            print("Error, finding frame_data or crc of slave frame")
            mvb_sf_layer_tree:add(
                mvb_slave_frame_layer_fields.data,
                "Invalid! Accpected size 2, 4 or n * 8 byte of frame_data"
            )
        end
    end
end

function mvb_protocol.prefs_changed()
    apply_settings()
end

busshark_ana_protocol = Proto("bussharkProtocol_ana", "bussharkProtocol_ana")
busshark_ana_protocol.fields.delta_receive_time =
    ProtoField.relative_time("busshark.meta.delta_receive_time", "delta receive time next frame")
busshark_ana_protocol.fields.frame_end_time =
    ProtoField.relative_time("busshark.meta.frame_end_time", "timestamp of the frame end")
busshark_ana_protocol.fields.is_rti = ProtoField.bool("mvb.meta.is.rti", "is reply timeout")
busshark_ana_protocol.fields.is_bti = ProtoField.bool("mvb.meta.is.bti", "is bus timeout")
busshark_ana_protocol.fields.is_emf = ProtoField.bool("mvb.meta.is.emf", "is error master frame")
busshark_ana_protocol.fields.is_esf = ProtoField.bool("mvb.meta.is.esf", "is error slave frame")
busshark_ana_protocol.fields.is_valid = ProtoField.bool("mvb.meta.is.valid", "is valid")
busshark_ana_protocol.fields.conversation_id = ProtoField.uint16(
    "mvb.meta.conversation.id",
    "conversation id",
    base.DEC
)

busshark_ana_protocol.fields.conversation_f_code =
    ProtoField.uint8("mvb.meta.conversation.f_code", "conversation f_code", base.DEC, f_code_map)
busshark_ana_protocol.fields.conversation_address =
    ProtoField.uint16("mvb.meta.conversation.address", "conversation address", base.DEC)
busshark_ana_protocol.prefs.rti_in_ns = Pref.uint("rti_in_ns", 42000, "rti_in_ns")
busshark_ana_protocol.prefs.bti_in_ns = Pref.uint("bti_in_ns", 1300000, "bti_in_ns")
-- event identifier response
busshark_ana_protocol.fields.event_address = ProtoField.uint8("mvb.sf.event_address", "Event Address")
-- Mastership transfer response
busshark_ana_protocol.fields.mastership_acp = ProtoField.bool("mvb.sf.mastership.acp", "ACP")
busshark_ana_protocol.fields.mastership_key = ProtoField.uint8("mvb.sf.mastership.key", "Actual Key")
-- device status response
--- capabilities
busshark_ana_protocol.fields.dev_stat_cap_sp = ProtoField.bool("mvb.sf.dev_stat.cap.sp", "SP")
busshark_ana_protocol.fields.dev_stat_cap_ba = ProtoField.bool("mvb.sf.dev_stat.cap.ba", "BA")
busshark_ana_protocol.fields.dev_stat_cap_gw = ProtoField.bool("mvb.sf.dev_stat.cap.gw", "GW")
busshark_ana_protocol.fields.dev_stat_cap_md = ProtoField.bool("mvb.sf.dev_stat.cap.md", "MD")
--- class_specific
busshark_ana_protocol.fields.dev_stat_cap_cs1 = ProtoField.bool("mvb.sf.dev_stat.cap.cs1", "CS1")
busshark_ana_protocol.fields.dev_stat_cap_cs2 = ProtoField.bool("mvb.sf.dev_stat.cap.cs2", "CS2")
busshark_ana_protocol.fields.dev_stat_cap_cs3 = ProtoField.bool("mvb.sf.dev_stat.cap.cs3", "CS3")
busshark_ana_protocol.fields.dev_stat_cap_cs4 = ProtoField.bool("mvb.sf.dev_stat.cap.cs4", "CS4")
--- common flags
busshark_ana_protocol.fields.dev_stat_cap_lat = ProtoField.bool("mvb.sf.dev_stat.cap.lat", "LAT")
busshark_ana_protocol.fields.dev_stat_cap_rld = ProtoField.bool("mvb.sf.dev_stat.cap.rld", "RLD")
busshark_ana_protocol.fields.dev_stat_cap_ssd = ProtoField.bool("mvb.sf.dev_stat.cap.ssd", "SSD")
busshark_ana_protocol.fields.dev_stat_cap_sdd = ProtoField.bool("mvb.sf.dev_stat.cap.sdd", "SDD")
busshark_ana_protocol.fields.dev_stat_cap_erd = ProtoField.bool("mvb.sf.dev_stat.cap.erd", "ERD")
busshark_ana_protocol.fields.dev_stat_cap_frc = ProtoField.bool("mvb.sf.dev_stat.cap.frc", "FRC")
busshark_ana_protocol.fields.dev_stat_cap_dnr = ProtoField.bool("mvb.sf.dev_stat.cap.dnr", "DNR")
busshark_ana_protocol.fields.dev_stat_cap_ser = ProtoField.bool("mvb.sf.dev_stat.cap.ser", "SER")

mvb_slave__message_frame_layer = Proto("mvb.sf.msg", "mvb slave frame msg")
local mvb_slave__message_frame_layer_fields = mvb_slave_frame_layer.fields
-- link header
mvb_slave__message_frame_layer_fields.mode =
    ProtoField.uint16("mvb.sf.msg.mode", "mode", base.DEC, map_mode, 0xF000, "message mode")
mvb_slave__message_frame_layer_fields.src =
    ProtoField.uint16("mvb.sf.msg.src", "src device", base.DEC, nil, 0x0FFF, "source device description")
mvb_slave__message_frame_layer_fields.dst =
    ProtoField.uint16("mvb.sf.msg.dst", "dst device", base.DEC, nil, 0x0FFF, "dest device description")
mvb_slave__message_frame_layer_fields.proto =
    ProtoField.uint8("mvb.sf.msg.proto", "protocol", base.DEC, nil, 0xF0, "proto description")
mvb_slave__message_frame_layer_fields.size =
    ProtoField.uint8("mvb.sf.msg.size", "size", base.DEC, nil, nil, "proto description")
-- network header
mvb_slave__message_frame_layer_fields.fn =
    ProtoField.uint8("mvb.sf.msg.fn", "final node", base.DEC, nil, nil, "fn description")
mvb_slave__message_frame_layer_fields.ff =
    ProtoField.uint8("mvb.sf.msg.ff", "final function", base.DEC, nil, nil, "ff description")
mvb_slave__message_frame_layer_fields.on =
    ProtoField.uint8("mvb.sf.msg.on", "origin node", base.DEC, nil, nil, "on description")
mvb_slave__message_frame_layer_fields.of =
    ProtoField.uint8("mvb.sf.msg.of", "origin function", base.DEC, nil, nil, "of description")
mvb_slave__message_frame_layer_fields.trans_data =
    ProtoField.bytes("mvb.sf.msg.payload", "payload", base.SPACE, nil --[[valuestring]], nil, "payload description")

mtc.init(mvb_slave__message_frame_layer_fields, "mvb.sf.msg")

rti_time = NSTime.new(0, 42000)
bti_time = NSTime.new(0, 1300000)

function apply_timing_settings()
    rti_time = NSTime.new(0, busshark_ana_protocol.prefs.rti_in_ns)
    bti_time = NSTime.new(0, busshark_ana_protocol.prefs.bti_in_ns)
end

-- Configuration field for anaylser run
--
-- Wireshark Fields can only be created outside of callback functions of dissectors
config = {
    post_frame_type = Field.new("busshark.meta.frame_type"),
    post_proto = Field.new("busshark.meta.protocol"),
    post_line = Field.new("busshark.meta.line"),
    post_pins = Field.new("busshark.meta.wtb.pins"),
    post_receive_time = Field.new("busshark.meta.receive_time"),
    post_frame_duration = Field.new("busshark.meta.frame_duration"),
    post_f_code = Field.new("mvb.mf.f_code"),
    post_address = Field.new("mvb.mf.address"),
    post_status_codes = Field.new("busshark.meta.status_codes"),
    post_sf_payload_size = Field.new("mvb.sf.msg.size"),
    ana_protocol = busshark_ana_protocol,
    mvb_sf_layer_fields = mvb_slave__message_frame_layer_fields,
    bti_time = bti_time,
    rti_time = rti_time,
    mvb_master_frame_layer_fields = mvb_master_frame_layer_fields,
    mvb_meta = bs_meta,
    create_frame_info_text = create_frame_info_text,
    frame_type_map = frame_type_map,
    protocol_map = protocol_map,
    line_map = line_map,
    wtb_pin_map = wtb_pin_map,
    mtc = mtc
}

function busshark_ana_protocol.dissector(buffer, pinfo, tree)
    pinfo.cols.info = ""
    if not enable_time_analyze and not enable_conversation_analyze then
        return
    end

    local meta_analyse_result = meta_analyse.run(pinfo, tree, config)

    local proto_id = config.post_proto()
    if proto_id.value == 0 then
        mvb_analyse.run(buffer, pinfo, meta_analyse_result, config)
    end

    if proto_id.value == 1 then
        wtb_analyse.run(meta_analyse_result, config)
    end
end

-- Wireshark post dissector registartion
register_postdissector(busshark_ana_protocol, true)
