-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/crazicrafter1/Valheim-Wireshark-zsocket2,
-- commit 2a639fae5158a5bd4083388621a7208089b78ef7 du 07/04/2026 (zsocket2/zsocket2_constants.lua).
-- Licence amont : GPL-3.0 (LICENSE amont) — voir README.md.

return {
    NAME = "valheimzs2",
    PORT = 2456, -- this is 2 above minecrafts so I can remember. Or set to Valheim 2456
    HEADER_SIZE = 8, -- size (in bytes) of the message header; this doesn't have to be the complete header, but should be enough to determine the length.
}