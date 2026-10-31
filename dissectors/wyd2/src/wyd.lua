-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/jhonatanruelo/wyd-decrypt-plugin (wyd.lua),
-- commit 7aba0a8a8315ac1d533059a15a60670ef6006570 du 05/08/2026.
-- Licence amont : MIT (LICENSE) — voir README.md.

-- wyd.lua — Wireshark dissector for the WYD (With Your Destiny) TCP protocol.
-- Stateless per-packet crypto; mid-stream captures work. See README.md.

----- MODULES -----

local ok, KT = pcall(require, "key_table")
if not ok then
  error("wyd.lua: could not load 'key_table.lua' — copy it next to wyd.lua in the plugins folder.")
end

----- CONSTANTS -----

local INIT_CODE   = 0x1f11f311 -- first 4 C->S bytes of a connection (Int32LE, cleartext)
local HEADER_LEN  = 12         -- smaller packets are not encrypted
local MIN_SIZE    = 4          -- smallest plausible frame (guards against infinite loop)

----- OPCODE NAMES -----

-- Unknown opcodes display as "Unknown". See README for how to add names.
local OPCODE_NAMES = {
  -- Incoming (Server -> Client)
  [0x101] = "CLIENT_MESSAGE_TEXT",
  [0x105] = "SERVER_MESSAGE",
  [0x106] = "GAME_MESSAGE_UNKNOWN",
  [0x10a] = "LOGIN_SUCCESSFUL",
  [0x110] = "RESEND_CHAR_LIST",
  [0x114] = "CHAR_TO_WORLD",
  [0x116] = "CHAR_LOGOUT_SIGNAL",
  [0x165] = "MOB_DEATH_STATE",
  [0x16f] = "DESPAWN_BY_OBJECT_ID",
  [0x181] = "COMPACT_HP_MP_SYNC",
  [0x182] = "SLOT_DELTA_UPDATE",
  [0x18a] = "DAMAGE_EVENT",
  [0x36a] = "MOB_STATE_DELTA",
  [0x292] = "SERVER_MULTI_SIGNAL",
  [0x36b] = "MOB_RESYNC",
  [0x1c1] = "NPC_TELEPORT_COMMAND",
  [0x1c6] = "NPC_MENU_DATA",
  [0x3b9] = "SERVER_SYNC",
  [0xbbf] = "CHALLENGE",

  -- Bidirectional
  [0x20d] = "ACCOUNT_LOGIN",
  [0x333] = "CHAT_MESSAGE",
  [0xd1d] = "CHAT_BROADCAST",
  [0x334] = "WHISPER_MESSAGE",
  [0x336] = "REFRESH_SCORE",
  [0x338] = "MOB_DEATH",
  [0x363] = "CREATE_MOB_NAMED",
  [0x364] = "CREATE_MOB",
  [0x366] = "MOVE_RESPONSE",
  [0x36c] = "MOVE",
  [0x39d] = "SINGLE_ATTACK",
  [0x39e] = "AOE_ATTACK",
  [0x367] = "SKILL_ATTACK",

  -- Outgoing (Client -> Server)
  [0x213] = "REQUEST_MOB_LOGIN",
  [0x215] = "CHAR_LOGOUT",
  [0x289] = "RESPAWN_EXECUTE",
  [0x3a0] = "KEEPALIVE",
  [0x376] = "ITEM_MOVE",
  [0x2e4] = "ITEM_DESTROY",
  [0x373] = "USE_ITEM",
  [0x3ae] = "USE_ITEM_ARM",
  [0x388] = "BANK_GOLD_DEPOSIT",
  [0x387] = "BANK_GOLD_WITHDRAW",
  [0x339] = "BANK_GOLD_BALANCE",
  [0x171] = "TRADE_ITEM_ADD",
  [0x37a] = "SELL_RESULT",
  [0x1bf] = "TRADE_RESULT",
  [0x3af] = "HAND_GOLD_UPDATE",
  [0x2e7] = "COMPOSE_SUBMIT",
  [0x37f] = "PARTY_INVITE",
  [0x3ab] = "PARTY_ACCEPT",
  [0x37e] = "PARTY_LEAVE",
  [0x37d] = "PARTY_ROSTER_MEMBER",
  [0x3ea] = "PARTY_ROSTER_FINALIZE",
  [0x28b] = "NPC_CLICK",
  [0x27b] = "DIALOG_CLICK",
  [0x290] = "ZONE_PORTAL",
  [0x17c] = "SHOP_INVENTORY",
  [0x379] = "SHOP_BUY",
  [0x2c2] = "TELEPORT_CONFIRM",
  [0x2c7] = "MINIPOPUP_CLICK",
  [0x378] = "MINIPOPUP_SELECTION",
  [0x384] = "DIALOG_CLOSE",
  [0xfde] = "TOKEN",
  [0xfdf] = "TOKEN_INCORRECT",
}

----- PROTOCOL & FIELDS -----

local wyd = Proto("wyd", "WYD Protocol")

local f = {
  init       = ProtoField.uint32("wyd.init", "Init Code", base.HEX),
  size       = ProtoField.uint16("wyd.size", "Size", base.DEC),
  key        = ProtoField.uint8("wyd.key", "Key", base.HEX),
  checksum   = ProtoField.uint8("wyd.checksum", "Checksum", base.HEX),
  opcode     = ProtoField.uint16("wyd.opcode", "Opcode", base.HEX),
  opcode_nm  = ProtoField.string("wyd.opcode.name", "Opcode Name"),
  client_id  = ProtoField.uint16("wyd.client_id", "Client ID", base.DEC),
  timestamp  = ProtoField.int32("wyd.timestamp", "Timestamp", base.DEC),
  cksum_stat = ProtoField.string("wyd.checksum.status", "Checksum Status"),
  decrypted  = ProtoField.bytes("wyd.decrypted", "Decrypted Packet"),
  payload    = ProtoField.bytes("wyd.payload", "Decrypted Payload"),
  payload_tx = ProtoField.string("wyd.payload.text", "Decrypted Payload (text)"),
}
wyd.fields = f

wyd.prefs.tcp_port = Pref.uint("TCP port", 8281, "TCP port of the WYD server")

----- CRYPTO -----

-- Decrypts one full packet in place. Returns ByteArray, ok (nil if < 12 bytes).
-- Only bytes from offset 4 are ciphered; size/key/checksum stay cleartext.
local function decrypt_packet(ba)
  local size = ba:get_index(0) + ba:get_index(1) * 256
  if size < HEADER_LEN then return ba, nil end

  local ki = KT[ba:get_index(2) * 2]
  local cenc, cdec = 0, 0
  for i = 4, size - 1 do
    local b = ba:get_index(i)
    cenc = (cenc + b) & 0xff
    local kr = KT[((ki & 0xff) << 1) + 1]
    ki = ki + 1
    local op = i & 3
    if op == 0 then
      b = (b - ((kr << 1) & 0xff)) & 0xff
    elseif op == 1 then
      b = (b + (kr >> 3)) & 0xff
    elseif op == 2 then
      b = (b - ((kr << 2) & 0xff)) & 0xff
    else
      b = (b + (kr >> 5)) & 0xff
    end
    ba:set_index(i, b)
    cdec = (cdec + b) & 0xff
  end
  return ba, ba:get_index(3) == ((cenc - cdec) & 0xff)
end

----- UTILS -----

-- Extracts printable ASCII runs (3+ chars) from a ByteArray, joined by ' | '.
local function to_text(ba, first, last)
  local parts, cur = {}, {}
  for i = first, last do
    local b = ba:get_index(i)
    if b >= 32 and b <= 126 then
      cur[#cur + 1] = string.char(b)
    else
      if #cur >= 3 then parts[#parts + 1] = table.concat(cur) end
      cur = {}
    end
  end
  if #cur >= 3 then parts[#parts + 1] = table.concat(cur) end
  return #parts > 0 and table.concat(parts, " | ") or "(no text)"
end

local function set_info(pinfo, infos)
  if #infos > 0 then
    pinfo.cols.info = "WYD " .. table.concat(infos, " ")
  end
end

----- STREAM STATE -----

-- Per stream+direction: frame where the INIT_CODE was consumed.
local tcp_stream_field = Field.new("tcp.stream")
local streams = {}

local function stream_key(pinfo)
  local s = tcp_stream_field()
  local idx = s and tostring(s.value) or "?"
  return idx .. "|" .. tostring(pinfo.src) .. ":" .. tostring(pinfo.src_port)
end

----- DISSECTOR -----

function wyd.dissector(tvb, pinfo, tree)
  pinfo.cols.protocol = "WYD"

  local key = stream_key(pinfo)
  local st = streams[key]
  if st == nil then st = {}; streams[key] = st end

  -- A new capture reuses tcp.stream indexes; drop stale state from an old one.
  if st.init_frame ~= nil and pinfo.number < st.init_frame and not pinfo.visited then
    st.init_frame = nil
  end

  local offset = 0
  local infos = {}

  -- Consume the INIT_CODE at the start of the C->S direction.
  if st.init_frame == nil then
    if tvb:len() < 4 then
      pinfo.desegment_offset = 0
      pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
      return
    end
    if tvb(0, 4):le_uint() == INIT_CODE then
      if tree then
        local htree = tree:add(wyd, tvb(0, 4), "WYD Handshake")
        htree:add_le(f.init, tvb(0, 4))
      end
      st.init_frame = pinfo.number
      offset = 4
      infos[#infos + 1] = "INIT"
    end
  elseif st.init_frame == pinfo.number and tvb:len() >= 4 then
    -- re-dissection of the frame that carried the INIT_CODE
    if tree then
      local htree = tree:add(wyd, tvb(0, 4), "WYD Handshake")
      htree:add_le(f.init, tvb(0, 4))
    end
    offset = 4
    infos[#infos + 1] = "INIT"
  end

  while offset < tvb:len() do
    local remaining = tvb:len() - offset
    if remaining < 2 then
      pinfo.desegment_offset = offset
      pinfo.desegment_len = DESEGMENT_ONE_MORE_SEGMENT
      set_info(pinfo, infos)
      return
    end

    local size = tvb(offset, 2):le_uint()
    if size < MIN_SIZE then
      if tree then
        local bad = tree:add(wyd, tvb(offset), "WYD Packet (out of sync)")
        bad:add_expert_info(PI_MALFORMED, PI_ERROR,
          string.format("Invalid packet size %d — stream out of sync", size))
      end
      set_info(pinfo, infos)
      return
    end
    if remaining < size then
      pinfo.desegment_offset = offset
      pinfo.desegment_len = size - remaining
      set_info(pinfo, infos)
      return
    end

    local pkt = tvb(offset, size)
    -- opcode/clientId/timestamp (offset >= 4) are ciphered: read decrypted bytes.
    local opcode, opcode_name, dec, cksum_ok
    if size >= HEADER_LEN then
      dec, cksum_ok = decrypt_packet(pkt:bytes())
      opcode = dec:get_index(4) + dec:get_index(5) * 256
      opcode_name = OPCODE_NAMES[opcode] or "Unknown"
    elseif size >= 6 then
      opcode = pkt(4, 2):le_uint()
      opcode_name = OPCODE_NAMES[opcode] or "Unknown"
    end

    if tree then
      local label = opcode
        and string.format("WYD Packet opcode=0x%04X (%s) len=%d", opcode, opcode_name, size)
        or  string.format("WYD Packet len=%d (not encrypted)", size)
      local ptree = tree:add(wyd, pkt(), label)

      ptree:add_le(f.size, pkt(0, 2))
      ptree:add(f.key, pkt(2, 1))
      ptree:add(f.checksum, pkt(3, 1))

      if size >= HEADER_LEN then
        local dtvb = ByteArray.tvb(dec, "WYD decrypted packet")
        ptree:add_le(f.opcode, dtvb(4, 2))
        ptree:add(f.opcode_nm, opcode_name)
        ptree:add_le(f.client_id, dtvb(6, 2))
        ptree:add_le(f.timestamp, dtvb(8, 4))

        ptree:add(f.cksum_stat, cksum_ok and "OK" or "FAIL")
        if not cksum_ok then
          ptree:add_expert_info(PI_CHECKSUM, PI_WARN, "Checksum mismatch")
        end

        ptree:add(f.decrypted, dtvb())
        if size > HEADER_LEN then
          ptree:add(f.payload, dtvb(HEADER_LEN, size - HEADER_LEN))
          ptree:add(f.payload_tx, to_text(dec, HEADER_LEN, size - 1))
        end
      else
        if opcode then
          ptree:add_le(f.opcode, pkt(4, 2))
          ptree:add(f.opcode_nm, opcode_name)
        end
        ptree:add(f.cksum_stat, "not encrypted (size < 12)")
      end
    end

    infos[#infos + 1] = opcode
      and string.format("opcode=0x%04X (%s) len=%d", opcode, opcode_name, size)
      or  string.format("len=%d", size)
    offset = offset + size
  end

  set_info(pinfo, infos)
end

----- HEURISTIC -----

-- Accept a stream by INIT_CODE, or by a first packet with a valid checksum.
local function looks_like_wyd(tvb)
  if tvb:len() >= 4 and tvb(0, 4):le_uint() == INIT_CODE then
    return true
  end
  if tvb:len() >= HEADER_LEN then
    local size = tvb(0, 2):le_uint()
    if size >= HEADER_LEN and size <= tvb:len() then
      local _, cksum_ok = decrypt_packet(tvb(0, size):bytes())
      return cksum_ok == true
    end
  end
  return false
end

local function wyd_heuristic(tvb, pinfo, tree)
  if not looks_like_wyd(tvb) then return false end
  pinfo.conversation = wyd
  wyd.dissector(tvb, pinfo, tree)
  return true
end

wyd:register_heuristic("tcp", wyd_heuristic)

----- REGISTRATION -----

local tcp_port_table = DissectorTable.get("tcp.port")
local current_port = wyd.prefs.tcp_port
tcp_port_table:add(current_port, wyd)

function wyd.prefs_changed()
  if current_port ~= wyd.prefs.tcp_port then
    tcp_port_table:remove(current_port, wyd)
    current_port = wyd.prefs.tcp_port
    tcp_port_table:add(current_port, wyd)
  end
end
