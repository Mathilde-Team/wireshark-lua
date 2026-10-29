-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/MISP/LuaMISP (sous-module `lib/LuaMISP` de
-- https://github.com/MISP/misp-wireshark, commit
-- be6d89df62503465d9b92e6839612111ea8fc068),
-- commit bd80c85bf22c5117b3946fd1b29ceb51fa26677e du 21/02/2022.
-- Licence amont : MIT — bibliothèque lunajson (projet rxi/grafi-tt) ; les
-- fichiers amont ne portent pas d'en-tête de licence — voir README.md.

local newdecoder = require 'lunajson.decoder'
local newencoder = require 'lunajson.encoder'
local sax = require 'lunajson.sax'
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	newparser = sax.newparser,
	newfileparser = sax.newfileparser,
}
