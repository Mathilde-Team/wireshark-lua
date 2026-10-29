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

  local packed_byteslen = reader:read(2)
  local byteslen = string.unpack(">I2", packed_byteslen)
  local packed_ignored = reader:read(byteslen)

  return OrderedDict:new(
    "byteslen", OrderedDict:new(
      f.byteslen.raw, bin.stohex(packed_byteslen),
      f.byteslen.deserialized, byteslen
    ),
    f.ignored, bin.stohex(packed_ignored)
  )
end

return {
  number = 19,
  name = "pong",
  deserialize = deserialize
}
