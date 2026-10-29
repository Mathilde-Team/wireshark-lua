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
  local packed_id = reader:read(8)
  local packed_sha256_of_onion = reader:read(32)
  local packed_failure_code = reader:read(2)

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "id", OrderedDict:new(
      f.id.raw, bin.stohex(packed_id),
      f.id.deserialized, UInt64.decode(packed_id, false)
    ),
    f.sha256_of_onion, bin.stohex(packed_sha256_of_onion),
    f.failure_code, bin.stohex(packed_failure_code)
  )
end

return {
  number = 135,
  name = "update_fail_malformed_htlc",
  deserialize = deserialize
}
