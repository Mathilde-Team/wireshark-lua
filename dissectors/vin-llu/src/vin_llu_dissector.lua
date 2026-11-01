-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/DinhNguyen34/tool-test-robot (tools/wireshark/vin_llu_dissector.lua),
-- commit e71f4d3bffc0fa79ee7ce19aeadec60e9e4fa93b du 07/09/2026 (dernière modification du fichier :
-- commit bf19b9a1aa6d1d6aad46cb967fb09b8e45617c0f du 29/08/2026).
-- Licence amont : MIT, « Copyright (c) 2026 DinhNguyen34 » (LICENSE du dépôt) — voir README.md et LICENSE.
--[[
  vin_llu_dissector.lua

  Wireshark Lua dissector for the VIN robot v2 UDP protocol between PC and the
  Low-Level Unit (LLU / STM32 board). Mirrors the parsing logic in
  Modules/ModuleNetwork/Models/{NucProtocol.cs, PacketHeader.cs, Packets.cs}.

  Packet families (all little-endian, magic 0xAA55):
    LowCmd  0x10 / LowState  0x11   -- 1280 B, 32 motors
    HandCmd 0x20 / HandState 0x21   -- 1024 B
    LedCmd  0x30 / LedState  0x31   --   48 B

  Install:
    Copy this file into your Wireshark "Personal Lua Plugins" folder
    (Help > About Wireshark > Folders > Personal Lua Plugins), or run
    Wireshark with:  wireshark -X lua_script:vin_llu_dissector.lua
    Then Analyze > Reload Lua Plugins (Ctrl+Shift+L).

  It registers on UDP ports 8888/8889/12345/12346 AND as a heuristic dissector
  keyed on the 0xAA55 magic, so it still fires even if traffic shows up on an
  unexpected port.
]]

local p_vinllu = Proto("vinllu", "VIN Robot LLU Protocol")

-- ── bit-op compatibility shim (Lua 5.2 bit32 vs Lua 5.3+ native operators) ──
local band, bxor, lshift
if bit32 then
    band, bxor, lshift = bit32.band, bit32.bxor, bit32.lshift
else
    local f = load([[
        return function(a,b) return a & b end,
               function(a,b) return a ~ b end,
               function(a,n) return (a << n) & 0xFFFFFFFF end
    ]])
    band, bxor, lshift = f()
end

-- CRC32 — identical to NucProtocol.Crc32(): poly 0x04C11DB7, init/final 0xFFFFFFFF, MSB-first.
local function crc32(bytes)
    local crc = 0xFFFFFFFF
    for i = 1, #bytes do
        crc = bxor(crc, lshift(bytes:byte(i), 24))
        for _ = 1, 8 do
            if band(crc, 0x80000000) ~= 0 then
                crc = bxor(lshift(crc, 1), 0x04C11DB7)
            else
                crc = lshift(crc, 1)
            end
        end
    end
    return bxor(crc, 0xFFFFFFFF)
end

-- ── Constants (match NucProtocol.cs) ────────────────────────────────────────
local LOW_SIZE  = 1280
local HAND_SIZE = 1024
local LED_SIZE  = 48
local HDR_SIZE  = 26
local N_MOTORS  = 32
local MOTOR_CMD_SIZE   = 32   -- 5 float + 3 uint reserve
local MOTOR_STATE_SIZE = 24   -- 4 float + 2 uint
local IMU_SIZE      = 40
local BATTERY_SIZE  = 40
local N_BATTERIES   = 2
local BRANCH_SIZE   = 8
local N_BRANCHES    = 6

local MSG_TYPE = {
    [0x10] = "LowCmd",  [0x11] = "LowState",
    [0x20] = "HandCmd", [0x21] = "HandState",
    [0x30] = "LedCmd",  [0x31] = "LedState",
}
local BOARD_ID = { [1] = "Lower (legs)", [2] = "Upper (arms)", [3] = "Both" }

-- ── Fields ───────────────────────────────────────────────────────────────
local f = {}
f.magic       = ProtoField.uint16("vinllu.magic", "Magic", base.HEX)
f.version     = ProtoField.uint8 ("vinllu.version", "Version")
f.msg_type    = ProtoField.uint8 ("vinllu.msg_type", "Msg Type", base.HEX, MSG_TYPE)
f.board_id    = ProtoField.uint8 ("vinllu.board_id", "Board Id", base.DEC, BOARD_ID)
f.err_flags   = ProtoField.uint8 ("vinllu.error_or_flags", "Error(state)/Flags(cmd)", base.HEX)
f.hdr_len     = ProtoField.uint16("vinllu.hdr_len", "Header Len")
f.seq         = ProtoField.uint32("vinllu.seq", "Sequence")
f.ts_us       = ProtoField.uint64("vinllu.timestamp_us", "Timestamp (us)")
f.payload_len = ProtoField.uint16("vinllu.payload_len", "Payload Len")
f.hdr_reserve = ProtoField.uint32("vinllu.hdr_reserve", "Header Reserve", base.HEX)

f.motor_idx    = ProtoField.uint32("vinllu.motor.index", "Motor Index")
f.motor_q      = ProtoField.float ("vinllu.motor.q", "q")
f.motor_dq     = ProtoField.float ("vinllu.motor.dq", "dq")
f.motor_tau    = ProtoField.float ("vinllu.motor.tau", "tau")
f.motor_kp     = ProtoField.float ("vinllu.motor.kp", "kp")
f.motor_kd     = ProtoField.float ("vinllu.motor.kd", "kd")
f.motor_tauest = ProtoField.float ("vinllu.motor.tau_est", "tau_est")
f.motor_temp   = ProtoField.float ("vinllu.motor.temperature", "temperature")
f.motor_err    = ProtoField.uint32("vinllu.motor.error_code", "error_code", base.HEX)
f.motor_opmode = ProtoField.uint32("vinllu.motor.operation_mode", "operation_mode")

f.imu_quat  = ProtoField.float("vinllu.imu.quat", "quaternion[]")
f.imu_gyro  = ProtoField.float("vinllu.imu.gyro", "gyroscope[]")
f.imu_accel = ProtoField.float("vinllu.imu.accel", "accelerometer[]")

f.batt_idx      = ProtoField.uint32("vinllu.battery.index", "Battery Index")
f.batt_type     = ProtoField.uint32("vinllu.battery.type", "type")
f.batt_serial   = ProtoField.uint32("vinllu.battery.serial", "serial_number")
f.batt_voltage  = ProtoField.float ("vinllu.battery.voltage", "voltage")
f.batt_soc      = ProtoField.float ("vinllu.battery.soc", "soc")
f.batt_soh      = ProtoField.float ("vinllu.battery.soh", "soh")
f.batt_current  = ProtoField.float ("vinllu.battery.current", "current")
f.batt_temp     = ProtoField.float ("vinllu.battery.temp", "temp")
f.batt_err      = ProtoField.uint32("vinllu.battery.error_code", "error_code", base.HEX)
f.batt_avail    = ProtoField.uint32("vinllu.battery.available", "available")
f.batt_reserve  = ProtoField.uint32("vinllu.battery.reserve", "reserve", base.HEX)

f.branch_idx     = ProtoField.uint32("vinllu.branch.index", "Branch Index")
f.branch_voltage = ProtoField.float ("vinllu.branch.voltage", "voltage")
f.branch_current = ProtoField.float ("vinllu.branch.current", "current")

f.led_index      = ProtoField.uint8("vinllu.led.index", "Index (0:chest, 1:head)")
f.led_r          = ProtoField.uint8("vinllu.led.r", "R")
f.led_g          = ProtoField.uint8("vinllu.led.g", "G")
f.led_b          = ProtoField.uint8("vinllu.led.b", "B")
f.led_brightness = ProtoField.uint8("vinllu.led.brightness", "Brightness")
f.led_mode       = ProtoField.uint8("vinllu.led.mode", "Mode")
f.led_reserve    = ProtoField.uint32("vinllu.led.reserve", "Reserve", base.HEX)

f.hand_side      = ProtoField.uint8("vinllu.hand.side", "Hand Side (0:left, 1:right)")
f.hand_iface     = ProtoField.uint8("vinllu.hand.interface_type", "Interface (0:CAN, 1:RS485)")
f.hand_data      = ProtoField.bytes("vinllu.hand.data", "Data")

f.reserved_bytes = ProtoField.bytes("vinllu.reserved", "Reserved / undecoded")
f.crc            = ProtoField.uint32("vinllu.crc32", "CRC32", base.HEX)
f.crc_calc       = ProtoField.uint32("vinllu.crc32_calc", "CRC32 (calculated)", base.HEX)
f.crc_ok         = ProtoField.bool  ("vinllu.crc32_ok", "CRC OK")

p_vinllu.fields = f

-- ── Helpers ──────────────────────────────────────────────────────────────
local function add_header(tree, tvb)
    local t = tree:add(p_vinllu, tvb(0, HDR_SIZE), "Header")
    t:add_le(f.magic,       tvb(0, 2))
    t:add    (f.version,    tvb(2, 1))
    local mt = tvb(3,1):uint()
    t:add    (f.msg_type,   tvb(3, 1))
    t:add    (f.board_id,   tvb(4, 1))
    t:add    (f.err_flags,  tvb(5, 1))
    t:add_le (f.hdr_len,    tvb(6, 2))
    t:add_le (f.seq,        tvb(8, 4))
    t:add_le (f.ts_us,      tvb(12, 8))
    t:add_le (f.payload_len,tvb(20, 2))
    t:add_le (f.hdr_reserve,tvb(22, 4))
    return mt
end

local function add_crc(tree, tvb)
    local len = tvb:len()
    local crc_range = tvb(len - 4, 4)
    local stated = crc_range:le_uint()
    local calc   = crc32(tvb(0, len - 4):raw())
    local t = tree:add(p_vinllu, crc_range, string.format("CRC32: 0x%08X", stated))
    t:add_le(f.crc, crc_range)
    t:add(f.crc_calc, crc_range, calc):set_generated()
    t:add(f.crc_ok, crc_range, stated == calc):set_generated()
    return stated == calc
end

local function add_motor_cmd(tree, tvb, off, idx)
    local mt = tree:add(p_vinllu, tvb(off, MOTOR_CMD_SIZE), string.format("Motor[%d]", idx))
    mt:add(f.motor_idx, idx):set_generated()
    mt:add_le(f.motor_q,  tvb(off, 4))
    mt:add_le(f.motor_dq, tvb(off + 4, 4))
    mt:add_le(f.motor_tau,tvb(off + 8, 4))
    mt:add_le(f.motor_kp, tvb(off + 12, 4))
    mt:add_le(f.motor_kd, tvb(off + 16, 4))
    mt:add(f.reserved_bytes, tvb(off + 20, 12))
end

local function add_motor_state(tree, tvb, off, idx)
    local mt = tree:add(p_vinllu, tvb(off, MOTOR_STATE_SIZE), string.format("Motor[%d]", idx))
    mt:add(f.motor_idx, idx):set_generated()
    mt:add_le(f.motor_q,      tvb(off, 4))
    mt:add_le(f.motor_dq,     tvb(off + 4, 4))
    mt:add_le(f.motor_tauest, tvb(off + 8, 4))
    mt:add_le(f.motor_temp,   tvb(off + 12, 4))
    local err = tvb(off + 16, 4):le_uint()
    local errItem = mt:add_le(f.motor_err, tvb(off + 16, 4))
    if err ~= 0 then
        errItem:add_expert_info(PI_RESPONSE_CODE, PI_NOTE,
            string.format("error_code = 0x%X (nonzero) -- see rs_motor_control.h / motor_control.c for bit meanings (e.g. bit10=0x400 Disconnect)", err))
        mt:append_text(string.format("  [ERROR 0x%X]", err))
    end
    mt:add_le(f.motor_opmode, tvb(off + 20, 4))
end

-- ── Main dissector ───────────────────────────────────────────────────────
function p_vinllu.dissector(tvb, pinfo, tree)
    local len = tvb:len()
    if len < HDR_SIZE + 4 then return 0 end
    if tvb(0, 2):le_uint() ~= 0xAA55 then return 0 end

    pinfo.cols.protocol = "VIN-LLU"

    local root = tree:add(p_vinllu, tvb(), "VIN LLU Protocol")
    local msg_type = add_header(root, tvb)
    local name = MSG_TYPE[msg_type] or string.format("Unknown(0x%02X)", msg_type)
    pinfo.cols.info = string.format("%s  len=%d  seq=%d", name, len, tvb(8, 4):le_uint())

    local off = HDR_SIZE

    if len == LOW_SIZE and (msg_type == 0x10 or msg_type == 0x11) then
        local motors = root:add(p_vinllu, tvb(off, N_MOTORS * (msg_type == 0x10 and MOTOR_CMD_SIZE or MOTOR_STATE_SIZE)),
            string.format("Motors (%d)", N_MOTORS))
        for i = 0, N_MOTORS - 1 do
            if msg_type == 0x10 then
                add_motor_cmd(motors, tvb, off, i)
                off = off + MOTOR_CMD_SIZE
            else
                add_motor_state(motors, tvb, off, i)
                off = off + MOTOR_STATE_SIZE
            end
        end

        if msg_type == 0x11 then
            -- IMU
            local imu = root:add(p_vinllu, tvb(off, IMU_SIZE), "IMU")
            for i = 0, 3 do imu:add_le(f.imu_quat,  tvb(off + i * 4, 4)) end
            off = off + 16
            for i = 0, 2 do imu:add_le(f.imu_gyro,  tvb(off + i * 4, 4)) end
            off = off + 12
            for i = 0, 2 do imu:add_le(f.imu_accel, tvb(off + i * 4, 4)) end
            off = off + 12

            -- Batteries
            for i = 0, N_BATTERIES - 1 do
                local bt = root:add(p_vinllu, tvb(off, BATTERY_SIZE), string.format("Battery[%d]", i))
                bt:add(f.batt_idx, i):set_generated()
                bt:add_le(f.batt_type,    tvb(off, 4))
                bt:add_le(f.batt_serial,  tvb(off + 4, 4))
                bt:add_le(f.batt_voltage, tvb(off + 8, 4))
                bt:add_le(f.batt_soc,     tvb(off + 12, 4))
                bt:add_le(f.batt_soh,     tvb(off + 16, 4))
                bt:add_le(f.batt_current, tvb(off + 20, 4))
                bt:add_le(f.batt_temp,    tvb(off + 24, 4))
                bt:add_le(f.batt_err,     tvb(off + 28, 4))
                bt:add_le(f.batt_avail,   tvb(off + 32, 4))
                bt:add_le(f.batt_reserve, tvb(off + 36, 4))
                off = off + BATTERY_SIZE
            end

            -- Branches
            for i = 0, N_BRANCHES - 1 do
                local br = root:add(p_vinllu, tvb(off, BRANCH_SIZE), string.format("Branch[%d]", i))
                br:add(f.branch_idx, i):set_generated()
                br:add_le(f.branch_voltage, tvb(off, 4))
                br:add_le(f.branch_current, tvb(off + 4, 4))
                off = off + BRANCH_SIZE
            end
        end

        -- Whatever's left before the CRC trailer is not decoded by NucProtocol.cs
        -- today (fixed 1280 B packet vs. currently-mapped fields) -- shown raw so
        -- nothing is silently hidden.
        local tail = len - 4 - off
        if tail > 0 then
            root:add(f.reserved_bytes, tvb(off, tail))
        end

    elseif len == HAND_SIZE and (msg_type == 0x20 or msg_type == 0x21) then
        root:add(f.hand_side,  tvb(off, 1)); off = off + 1
        root:add(f.hand_iface, tvb(off, 1)); off = off + 1
        root:add(f.reserved_bytes, tvb(off, 2)); off = off + 2
        root:add(f.hand_data, tvb(off, 990)); off = off + 990

    elseif len == LED_SIZE and (msg_type == 0x30 or msg_type == 0x31) then
        root:add(f.led_index, tvb(off, 1)); off = off + 1
        root:add(f.led_r, tvb(off, 1)); off = off + 1
        root:add(f.led_g, tvb(off, 1)); off = off + 1
        root:add(f.led_b, tvb(off, 1)); off = off + 1
        root:add(f.led_brightness, tvb(off, 1)); off = off + 1
        root:add(f.led_mode, tvb(off, 1)); off = off + 1
        root:add_le(f.led_reserve, tvb(off, 4)); off = off + 4
        local tail = len - 4 - off
        if tail > 0 then root:add(f.reserved_bytes, tvb(off, tail)) end
    else
        root:add(f.reserved_bytes, tvb(off, len - 4 - off))
    end

    local crcOk = add_crc(root, tvb)
    if not crcOk then
        pinfo.cols.info:append("  [CRC BAD]")
        root:add_expert_info(PI_CHECKSUM, PI_ERROR, "CRC32 mismatch")
    end

    return len
end

-- ── Registration: fixed ports + heuristic (magic-based) ─────────────────
local udp_port_table = DissectorTable.get("udp.port")
for _, port in ipairs({8888, 8889, 12345, 12346}) do
    udp_port_table:add(port, p_vinllu)
end

p_vinllu:register_heuristic("udp", function(tvb, pinfo, tree)
    if tvb:len() < HDR_SIZE + 4 then return false end
    if tvb(0, 2):le_uint() ~= 0xAA55 then return false end
    p_vinllu.dissector(tvb, pinfo, tree)
    return true
end)
