-- SPDX-License-Identifier: AGPL-3.0-or-later
-- Importé de https://github.com/Avledet/AvlWireshark (zs2_constants.lua),
-- commit 8559f0ddc3ec3082081eaffcccd4bfd29f10e3a2 du 07/04/2026.
-- Licence amont : AGPLv3 ou ultérieure (LICENSE.md) — voir README.md.

return {
    NAME = "zs2",
    PORT = 2456, -- this is 2 above minecrafts so I can remember. Or set to Valheim 2456
    HEADER_SIZE = 8 -- size (in bytes) of the message header; this doesn't have to be the complete header, but should be enough to determine the length.
}
