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
  local packed_signature = reader:read(64)
  local packed_num_htlcs = reader:read(2)
  local num_htlcs = string.unpack(">I2", packed_num_htlcs)

  local signatures = {}
  for i = 1, num_htlcs do
    local packed_signature = reader:read(64)
    table.insert(signatures, OrderedDict:new(
      f.htlc_signature.raw, bin.stohex(packed_signature),
      f.htlc_signature.der, bin.stohex(convert_signature_der(packed_signature))
    ))
  end

  return OrderedDict:new(
    f.channel_id, bin.stohex(packed_channel_id),
    "signature", OrderedDict:new(
      f.signature.raw, bin.stohex(packed_signature),
      f.signature.der, bin.stohex(convert_signature_der(packed_signature))
    ),
    "num_htlcs", OrderedDict:new(
      f.num_htlcs.raw, bin.stohex(packed_num_htlcs),
      f.num_htlcs.deserialized, num_htlcs
    ),
    "htlc_siganture", signatures
  )
end

return {
  number = 132,
  name = "commitment_signed",
  deserialize = deserialize
}
