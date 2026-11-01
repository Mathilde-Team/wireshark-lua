-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/mvb/mvb-meta.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
local meta = {}

-- Extract meta information from frame
--
function meta.extract(frame, fill_header)
  meta.size = (frame:len() / 2) + 8
  meta.code_size = meta.size - 16
  meta.status_codes = frame(16, meta.code_size)

  if fill_header.payload_version > 2 then
    meta.size = meta.size + 1;
    meta.code_size = meta.size - 18
    meta.status_codes = frame(18, meta.code_size)
  end

  meta.firstCode = meta.status_codes(0, 1)
  meta.first_code_uint = meta.firstCode:uint()
  meta.frame_type = bit.band(meta.first_code_uint, 0x03)
end

return meta
