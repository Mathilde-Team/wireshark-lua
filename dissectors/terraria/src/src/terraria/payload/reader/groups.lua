-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/BeInBloom/terraria-wireshark-dissector (src/terraria/payload/reader/groups.lua),
-- commit c391a5dc8fcec9c8c603ec8cf6daa285a5d7740d du 26/10/2026.
-- Licence amont : GPL-3.0-only (fichier LICENSE, GPLv3 sans mention « or later ») — voir README.md.

local M = {}

---@param field ProtoField
---@param read fun(payload: PayloadReader)
---@return TreeItem
function M:group(field, read)
	local start = self.reader:position()
	local item = self.tree:add(field, self.reader.source:range(start, self.reader:remaining()))
	local payload = getmetatable(self).new(self.reader, item)

	local ok, err = pcall(read, payload)

	item:set_len(self.reader:position() - start)

	if not ok then
		error(err, 0)
	end

	return item
end

return M
