-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/mvb/mvb-analyse.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
local dissector_root_path = string.sub(debug.getinfo(1).source, 2, string.len("/mvb/mvb-analyse.lua") * -1)
package.path = package.path .. ';' .. dissector_root_path .. '/?.lua;'
local cache = require "types/chache"

local analyse = {}

-- Analysing MVB data
--

local last_time_frame_cache = cache.new()

local conversation_ids = {}


-- Analyse a master frame
--
--@param: tree, subtree element for extracted data
--@param: is_valid, valid frame
--@param: delta_time, subtree element to extracted data
--@param: conversation_id, subtree element to extracted data
--@param: config containing data and tree views
-- RETURN: is_valid
function analyse.master(tree, is_valid, delta_time, conversation_id, config, analyse_api)
    local status_codes_mf = config.post_status_codes().value
    local is_emf = analyse_api.contains_errors(status_codes_mf)
    if is_emf then
        tree:add(config.ana_protocol.fields.is_emf, true)
        is_valid = false
    end

    if (delta_time > config.bti_time) then
        tree:add(config.ana_protocol.fields.is_bti, true)
        is_valid = false
    elseif (delta_time > config.rti_time) then
        tree:add(config.ana_protocol.fields.is_rti, true)
        is_valid = false
    end
    tree:add(config.ana_protocol.fields.conversation_f_code, math.floor(conversation_id / 4096))
    tree:add(config.ana_protocol.fields.conversation_address, conversation_id % 4096)
    tree:add(config.ana_protocol.fields.conversation_id, conversation_id)
    return is_valid
end

-- Analyse a slave frame
--
--@param: tree, subtree element for extracted data
--@param: frame, buffer frame
--@param: is_valid, valid frame
--@param: conversation_id, already found id
--@param: number, pinfo.number
--@param: config containing data and tree views
-- RETURN: is_valid
function analyse.slave(tree, frame, is_valid, conversation_id, number, config, analyse_api)
    if not conversation_id then
        conversation_id = conversation_ids[number]
        if not conversation_id then
            return
        end

        local status_codes_sf = config.post_status_codes().value
        local is_esf = analyse_api.contains_errors(status_codes_sf)
        if is_esf then
            tree:add(config.ana_protocol.fields.is_esf, true)
            is_valid = false
        end
        local cfCode = math.floor(conversation_id / 4096)
        -- offset: ethernet header + stretch bytes
        if (cfCode == 8) then
            -- Mastership Transfer
            tree:add(config.ana_protocol.fields.mastership_acp, frame:bitfield(0, 1))
            tree:add(config.ana_protocol.fields.mastership_key, frame:bitfield(1, 15))
        elseif (cfCode == 9 or cfCode == 13 or cfCode == 14) then
            -- General event identifier: 16 bit: F_Code 4bit, Address 12 bit
            -- f_code is set in conversation_f_code subtree item
            tree:add(config.ana_protocol.fields.event_address, frame:bitfield(4, 12))
        elseif (cfCode == 12) then
            -- message data
            local sftree = tree:add(config.ana_protocol, "mvb msg analyse data", frame(0, frame:len()))
            sftree:add(config.mvb_sf_layer_fields.mode, frame(0, 2))
            sftree:add(config.mvb_sf_layer_fields.dst, frame(0, 2))
            sftree:add(config.mvb_sf_layer_fields.proto, frame(2, 1))
            sftree:add(config.mvb_sf_layer_fields.src, frame(2, 2))
            sftree:add(config.mvb_sf_layer_fields.size, frame(4, 1))
            sftree:add(config.mvb_sf_layer_fields.fn, frame(5, 1))
            sftree:add(config.mvb_sf_layer_fields.ff, frame(6, 1))
            sftree:add(config.mvb_sf_layer_fields.on, frame(7, 1))
            sftree:add(config.mvb_master_frame_layer_fields.crc, frame(8, 1))
            sftree:add(config.mvb_sf_layer_fields.of, frame(9, 1))
            sftree:add(config.mvb_sf_layer_fields.mtc, frame(10, 1))
            local mtc_type = frame(10, 1):uint()
            local mtc_type_id = config.mtc.mtc_type_get(mtc_type)
            local mtc_type_str = config.mtc.map[mtc_type_id]
            if mtc_type_str ~= nil then
                sftree:add(config.mvb_sf_layer_fields.mtc_type, mtc_type_str)
            end

            config.mtc.mtc_type_fields(sftree, config.mvb_sf_layer_fields, mtc_type_id, mtc_type)

            sftree:add(config.mvb_sf_layer_fields.trans_data, frame(11, frame:len() - 11))
            -- transport layer
            if (mtc_type_id == config.mtc.MTC_TYPE_CR) then
                sftree:add(config.mvb_sf_layer_fields.cr_conn_ref, frame(11, 2))
                sftree:add(config.mvb_sf_layer_fields.cr_msg_size, frame(13, 4))
                sftree:add(config.mvb_sf_layer_fields.cr_credit, frame(18, 1))
                sftree:add(config.mvb_sf_layer_fields.cr_pack_size, frame(18, 1))
                sftree:add(config.mvb_sf_layer_fields.cr_session_header, frame(19, 1))
            elseif (mtc_type_id == config.mtc.MTC_TYPE_CC) then
                sftree:add(config.mvb_sf_layer_fields.cc_conn_ref, frame(11, 2))
                sftree:add(config.mvb_sf_layer_fields.cc_credit, frame(13, 1))
                sftree:add(config.mvb_sf_layer_fields.cc_pack_size, frame(13, 1))
            elseif (mtc_type_id == config.mtc.MTC_TYPE_DR) then
                sftree:add(config.mvb_sf_layer_fields.dr_reason, frame(11, 1))
            elseif (mtc_type_id == config.mtc.MTC_TYPE_DC) then
                sftree:add(config.mvb_sf_layer_fields.dc_reaons, frame(11, 1))
            end

        elseif (cfCode == 15) then
            -- Device status response
            -- 16 bit:
            --- capabilities 4 bit:   SP, BA, GW, MD
            local sftree = tree:add(config.ana_protocol, "mvb device analyse data", frame(0, frame:len()))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_sp, frame:bitfield(0, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_ba, frame:bitfield(1, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_gw, frame:bitfield(2, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_md, frame:bitfield(3, 1))
            --- class_specific 4 bit: T, T, T, T
            sftree:add(config.ana_protocol.fields.dev_stat_cap_cs1, frame:bitfield(4, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_cs2, frame:bitfield(5, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_cs3, frame:bitfield(6, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_cs4, frame:bitfield(7, 1))
            --- common flags 8 bit: LAT, RLD, SSD, SDD, ERD, FRC, DNR, SER
            sftree:add(config.ana_protocol.fields.dev_stat_cap_lat, frame:bitfield(8, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_rld, frame:bitfield(9, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_ssd, frame:bitfield(10, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_sdd, frame:bitfield(11, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_erd, frame:bitfield(12, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_frc, frame:bitfield(13, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_dnr, frame:bitfield(14, 1))
            sftree:add(config.ana_protocol.fields.dev_stat_cap_ser, frame:bitfield(15, 1))
        end
    end

    if not conversation_id then
        conversation_id = 0
    end

    tree:add(config.ana_protocol.fields.conversation_id, conversation_id)
    tree:add(config.ana_protocol.fields.conversation_f_code, math.floor(conversation_id / 4096))
    tree:add(config.ana_protocol.fields.conversation_address, conversation_id % 4096)

    return is_valid
end

-- Start mvb frame analyses and add results to tree
--
--@param: buffer
--@param: pinfo Packet information
--@param: tree Wireshark Tree
--@param: config contains needed data like Fields and layers for tree view
function analyse.run(buffer, pinfo, meta_analyse_result, config)
    local tree = meta_analyse_result.tree
    local delta_time = meta_analyse_result.delta_receive_time
    local analyse_api = meta_analyse_result.analyse

    local frame_type = config.post_frame_type()
    if frame_type then
        local frame_type_value = frame_type.value
        local proto_id = config.post_proto()
        local line_id = config.post_line()
        if line_id == nil then
            line_id = config.post_pins()
        end

        local frame_detail_info = ""
        local conversation_id = nil
        local f_code = config.post_f_code()
        if (frame_type_value == 0x01) then
            local address = config.post_address()
            frame_detail_info = "(f-code: " .. f_code.value .. ", address: " .. address.value .. ")"
            conversation_id = f_code.value * 4096 + address.value
        end

        if not pinfo.visited then
            local last_time = cache.get(last_time_frame_cache, proto_id.value, line_id.value)
            if last_time == nil then
                last_time = { conversation_id = conversation_id }
            end

            if not conversation_id then
                conversation_ids[pinfo.number] = last_time.conversation_id
            end

            -- update last time
            cache.update(
                last_time_frame_cache,
                { conversation_id = conversation_id },
                proto_id.value,
                line_id.value
            )
        end

        if config.create_frame_info_text then
            local frame_info_string =
                config.frame_type_map[frame_type_value] ..
                " " ..
                frame_detail_info ..
                " from " ..
                config.protocol_map[proto_id.value] .. "-proto"

            if proto_id.value == 1 then
                frame_info_string = frame_info_string .. " pins " .. config.wtb_pin_map[line_id.value]
            else
                frame_info_string = frame_info_string .. " line " .. config.line_map[line_id.value]
            end

            pinfo.cols.info = frame_info_string
        end

        local is_valid = true
        if (frame_type_value == 0x03) then     -- unknown frame
            is_valid = false
        elseif (frame_type_value == 0x01) then -- master frame
            is_valid = analyse.master(tree, is_valid, delta_time, conversation_id, config, analyse_api)
        elseif (frame_type_value == 0x02) then -- slave frame
            -- offset: ethernet header + stretch bytes
            local offset_header = 45
            local frame = buffer(offset_header + config.mvb_meta.size, config.mvb_meta.code_size - 2)
            is_valid = analyse.slave(tree, frame, is_valid, conversation_id, pinfo.number, config, analyse_api)
        end

        if is_valid then
            tree:add(config.ana_protocol.fields.is_valid, true)
        end
    end
end

return analyse
