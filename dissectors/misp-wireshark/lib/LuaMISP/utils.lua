-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/MISP/LuaMISP (sous-module `lib/LuaMISP` de
-- https://github.com/MISP/misp-wireshark, commit
-- be6d89df62503465d9b92e6839612111ea8fc068),
-- commit bd80c85bf22c5117b3946fd1b29ceb51fa26677e du 21/02/2022.
-- Licence amont : MIT (texte complet dans `LICENSE` de ce dossier) — voir README.md.

local newdecoder = require 'utils.lunajson.decoder'
local newencoder = require 'utils.lunajson.encoder'
local sax = require 'utils.lunajson.sax'
local uuid = require 'utils.uuid'
local base64 = require 'utils.base64'

uuid.randomseed(os.time())

return {
    jsonDecode = newdecoder(),
    jsonEncode = newencoder(),
    jsonNewparser = sax.newparser,
    jsonNewfileparser = sax.newfileparser,
    uuid = uuid,
    base64 = base64,
}
