-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/nayutaco/lightning-dissector,
-- commit 8aa07e8fa1554b371997e28d26713b5c393f797f du 11/05/2019 (branche `master`).
-- Licence amont : MIT (© 2018 Nayuta, Inc., LICENSE amont ; texte complet dans
-- `LICENSE` de ce dossier) — voir README.md.

local bin = require "plc52.bin"
local Reader = require("lightning-dissector.utils").Reader
local OrderedDict = require("lightning-dissector.utils").OrderedDict
local f = require("lightning-dissector.constants").fields.payload.deserialized

function deserialize(payload)
  local reader = Reader:new(payload)

  local packed_channel_id = reader:read(32)
  local packed_first_timestamp = reader:read(4)
  local packed_timestamp_range = reader:read(4)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "first_timestamp", OrderedDict:new(
      f.first_timestamp.raw, bin.stohex(packed_first_timestamp),
      f.first_timestamp.deserialized, (string.unpack(">I4", packed_first_timestamp))
    ),
    "timestamp_range", OrderedDict:new(
      f.timestamp_range.raw, bin.stohex(packed_timestamp_range),
      f.timestamp_range.deserialized, (string.unpack(">I4", packed_timestamp_range))
    )
  )
end

return {
  number = 265,
  name = "gossip_timestamp_filter",
  deserialize = deserialize
}
