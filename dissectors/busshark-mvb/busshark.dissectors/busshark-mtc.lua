-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/busshark-mtc.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
MTC_TYPE_CR = 0
MTC_TYPE_CC = 1
MTC_TYPE_DR = 2
MTC_TYPE_DC = 3
MTC_TYPE_BC = 4
MTC_TYPE_BD = 5
MTC_TYPE_BR = 6
MTC_TYPE_BS = 7
MTC_TYPE_DT = 8
MTC_TYPE_AK = 9
MTC_TYPE_NK = 10

local mtc = {

    MTC_TYPE_CR = MTC_TYPE_CR,
    MTC_TYPE_CC = MTC_TYPE_CC,
    MTC_TYPE_DR = MTC_TYPE_DR,
    MTC_TYPE_DC = MTC_TYPE_DC,
    MTC_TYPE_BC = MTC_TYPE_BC,
    MTC_TYPE_BD = MTC_TYPE_BD,
    MTC_TYPE_BR = MTC_TYPE_BR,
    MTC_TYPE_BS = MTC_TYPE_BS,
    MTC_TYPE_DT = MTC_TYPE_DT,
    MTC_TYPE_AK = MTC_TYPE_AK,
    MTC_TYPE_NK = MTC_TYPE_NK,

    map = {
        [MTC_TYPE_CR] = "CR",
        [MTC_TYPE_CC] = "CC",
        [MTC_TYPE_DR] = "DR",
        [MTC_TYPE_DC] = "DC",
        [MTC_TYPE_BC] = "BC",
        [MTC_TYPE_BD] = "BD",
        [MTC_TYPE_BR] = "BR",
        [MTC_TYPE_BS] = "BS",
        [MTC_TYPE_DT] = "DT",
        [MTC_TYPE_AK] = "AK",
        [MTC_TYPE_NK] = "NK"
    },

    map_mode = {
        [1] = "single cast",
        [15] = "broadcast"
    },

    map_type_cl = {
        [0] = "reply",
        [1] = "call"
    },

    map_type_co = {
        [0] = "consumer",
        [1] = "producer"
    },

    map_type_bc_rept = {
        [0] = "BC1",
        [1] = "BC2",
        [2] = "BC3",
        [3] = "BC??"
    },

    map_type_bool = {
        [0] = "false",
        [1] = "true"
    },

    map_dx_reason = {
        [0] = "AM_OK",
        [1] = "AM_FAILURE",
        [2] = "AM_BUS_ERR",
        [3] = "AM_REM_CONN_OVF",
        [4] = "AM_CONN_TMO_ERR",
        [5] = "AM_SEND_TMO_ERR",
        [6] = "AM_REPLY_TMO_ERR",
        [7] = "AM_ALIVE_TMO_ERR",
        [8] = "AM_NO_LOC_MEM_ERR",
        [9] = "AM_NO_REM_MEM_ERR",
        [10] = "AM_REM_CANC_ERR",
        [11] = "AM_ALREADY_USED",
        [12] = "AM_ADDR_FMT_ERR",
        [13] = "AM_NO_REPLY_EXP_ERR",
        [14] = "AM_NR_OF_CALLS_OVF",
        [15] = "AM_REPLY_LEN_OVF",
        [16] = "AM_DUPL_LINK_ERR",
        [17] = "AM_MY_DEV_UNKNOWN_ERR",
        [18] = "AM_NO_READY_INST_ERR",
        [19] = "AM_NR_OF_INST_OVF",
        [20] = "AM_CALL_LEN_OVF",
        [21] = "AM_UNKNOWN_DEST_ERR",
        [22] = "AM_INAUG_ERR",
        [23] = "AM_TRY_LATER_ERR",
        [24] = "AM_DEST_NOT_REG_ERR",
        [25] = "AM_GW_DEST_NOT_REG_ERR",
        [26] = "AM_GW_SRC_NOT_REG_ERR",
        [27] = "AM_REPEAT_TMO_ERR",
        [31] = "AM_MAX_ERR"
    }
}

-- Initialize fill header fields
function mtc.init(network_header, prefix)
    -- link header
    network_header.mtc = ProtoField.uint8(
        prefix .. ".mtc",
        "message transport control",
        base.HEX,
        nil,
        nil,
        "mtc description"
    )

    network_header.mtc_type = ProtoField.string(
        prefix .. ".mtc_type",
        "message transport control type",
        base.UNICODE,
        "mtc type description"
    )

    network_header.mtc_type_cl = ProtoField.uint8(
        prefix .. ".mtc.cl",
        "message transport control - control field",
        base.DEC,
        mtc.map_type_cl,
        0x80,
        "control field"
    )

    network_header.mtc_type_co = ProtoField.uint8(
        prefix .. ".mtc.co",
        "message transport control - origin",
        base.DEC,
        mtc.map_type_co,
        0x40,
        "origin"
    )

    network_header.mtc_type_bc_rept = ProtoField.uint8(
        prefix .. ".mtc.bc_rept",
        "message transport control - broadcast connect",
        base.DEC,
        mtc.map_type_bc_rept,
        0x03,
        "broadcast connect"
    )

    network_header.mtc_type_dt_e = ProtoField.uint8(
        prefix .. ".mtc.dt_e",
        "message transport control - end of message",
        base.DEC,
        mtc.map_type_bool,
        0x08,
        "end of message"
    )

    network_header.mtc_type_dt_seq_nr = ProtoField.uint8(
        prefix .. ".mtc.dt_seq_nr",
        "message transport control - sequence number",
        base.DEC,
        nil,
        0x07,
        "sequence number"
    )

    network_header.mtc_type_ak_e = ProtoField.uint8(
        prefix .. ".mtc.ak_e",
        "message transport control - end of message",
        base.DEC,
        mtc.map_type_bool,
        0x08,
        "acknowledged - end of message"
    )

    network_header.mtc_type_ak_seq_nr = ProtoField.uint8(
        prefix .. ".mtc.ak_seq_nr",
        "message transport control - sequence number",
        base.DEC,
        nil,
        0x07,
        "next packet number expected"
    )

    network_header.mtc_type_nk_e = ProtoField.uint8(
        prefix .. ".mtc.nk_e",
        "message transport control - end of message",
        base.DEC,
        mtc.map_type_bool, 0x08,
        "not acknowledged - end of message"
    )

    network_header.mtc_type_nk_seq_nr = ProtoField.uint8(
        prefix .. ".mtc.nk_seq_nr",
        "message transport control - sequence number",
        base.DEC,
        nil,
        0x07,
        "next packet number expected"
    )

    -- transport layer
    network_header.cr_conn_ref = ProtoField.uint16(
        prefix .. ".cr_conn_ref",
        "connection reference",
        base.DEC,
        nil,
        nil,
        "connection reference"
    )

    network_header.cr_msg_size = ProtoField.uint32(
        prefix .. ".cr_msg_size",
        "message size",
        base.DEC,
        nil,
        nil,
        "message size"
    )

    network_header.cr_credit = ProtoField.uint8(prefix .. ".cr_credit", "credit", base.DEC, nil, 0xF0, "credit")
    network_header.cr_pack_size = ProtoField.uint8(
        prefix .. ".cr_pack_size",
        "pack size",
        base.DEC,
        nil,
        0x0F,
        "pack size"
    )

    network_header.cr_session_header = ProtoField.uint8(
        prefix .. ".cr_session_header",
        "session header",
        base.DEC,
        nil,
        nil,
        "session header"
    )

    network_header.cc_conn_ref = ProtoField.uint16(
        prefix .. ".cc_conn_ref",
        "connection reference",
        base.DEC,
        nil,
        nil,
        "connection reference"
    )

    network_header.cc_credit = ProtoField.uint8(prefix .. ".cc_credit", "credit", base.DEC, nil, 0xF0, "credit")
    network_header.cc_pack_size = ProtoField.uint8(
        prefix .. ".cc_pack_size",
        "pack size",
        base.DEC,
        nil,
        0x0F,
        "pack size"
    )

    network_header.dr_reason = ProtoField.uint8(
        prefix .. ".dr_reason",
        "dr reason",
        base.DEC,
        mtc.map_dx_reason,
        nil,
        "dr reason"
    )

    network_header.dc_reason = ProtoField.uint8(
        prefix .. ".dc_reason",
        "dc reason",
        base.DEC,
        mtc.map_dx_reason,
        nil,
        "dc reason"
    )
end

function mtc.mtc_type_get(mtc_type)
    if (bit.band(mtc_type, 0x7F) == 0) then
        return MTC_TYPE_CR
    elseif (bit.band(mtc_type, 0x7F) == 0x41) then
        return MTC_TYPE_CC
    elseif (bit.band(mtc_type, 0x3F) == 0x02) then
        return MTC_TYPE_DR
    elseif (bit.band(mtc_type, 0x3F) == 0x03) then
        return MTC_TYPE_DC
    elseif (bit.band(mtc_type, 0xFC) == 0x88) then
        return MTC_TYPE_BC
    elseif (mtc_type == 0x8C) then
        return MTC_TYPE_BD
    elseif (mtc_type == 0xCD) then
        return MTC_TYPE_BR
    elseif (bit.band(mtc_type, 0xBF) == 0x8E) then
        return MTC_TYPE_BS
    elseif (bit.band(mtc_type, 0x70) == 0x10) then
        return MTC_TYPE_DT
    elseif (bit.band(mtc_type, 0x70) == 0x60) then
        return MTC_TYPE_AK
    elseif (bit.band(mtc_type, 0x70) == 0x70) then
        return MTC_TYPE_NK
    else
        return nil
    end
end

function mtc.mtc_type_fields(tree, fields, mtc_type_id, mtc_type)
    if (mtc_type_id == MTC_TYPE_CR) then
        tree:add(fields.mtc_type_cl, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_CC) then
        tree:add(fields.mtc_type_cl, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_DR) then
        tree:add(fields.mtc_type_cl, mtc_type)
        tree:add(fields.mtc_type_co, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_DC) then
        tree:add(fields.mtc_type_cl, mtc_type)
        tree:add(fields.mtc_type_co, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_BC) then
        tree:add(fields.mtc_type_bc_rept, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_BS) then
        tree:add(fields.mtc_type_co, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_DT) then
        tree:add(fields.mtc_type_cl, mtc_type)
        tree:add(fields.mtc_type_dt_e, mtc_type)
        tree:add(fields.mtc_type_dt_seq_nr, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_AK) then
        tree:add(fields.mtc_type_cl, mtc_type)
        tree:add(fields.mtc_type_ak_e, mtc_type)
        tree:add(fields.mtc_type_ak_seq_nr, mtc_type)
    elseif (mtc_type_id == MTC_TYPE_NK) then
        tree:add(fields.mtc_type_cl, mtc_type)
        tree:add(fields.mtc_type_nk_e, mtc_type)
        tree:add(fields.mtc_type_nk_seq_nr, mtc_type)
    end
end

return mtc
