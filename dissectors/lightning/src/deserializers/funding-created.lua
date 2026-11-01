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

  local packed_temporary_channel_id = reader:read(32)
  local packed_funding_txid = reader:read(32)
  local packed_funding_output_index = reader:read(2)
  local packed_signature = reader:read(64)

  return OrderedDict:new(
    f.temporary_channel_id, bin.stohex(packed_temporary_channel_id),
    f.funding_txid, bin.stohex(packed_funding_txid),
    "funding_output_index", OrderedDict:new(
      f.funding_output_index.raw, bin.stohex(packed_funding_output_index),
      f.funding_output_index.deserialized, (string.unpack(">I2", packed_funding_output_index))
    ),
    "signature", OrderedDict:new(
      f.signature.raw, bin.stohex(packed_signature),
      f.signature.der, bin.stohex(convert_signature_der(packed_signature))
    )
  )
end

return {
  number = 34,
  name = "funding_created",
  deserialize = deserialize
}
