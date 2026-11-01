-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://gitlab.com/busshark/busshark.dissectors.mvb (plugins/busshark.dissectors/wtb/wtb-analyse.lua),
-- commit 25f5ee6987539bf25c7e3f7c32a2075c8a2ae26c du 11/07/2025.
-- Licence amont : GPL-2.0-only (LICENSE amont) — voir README.md.
local analyse = {}


function analyse.run(meta_analyse_result, config)
    local analyse_api = meta_analyse_result.analyse
    local tree = meta_analyse_result.tree

    local status_codes = config.post_status_codes().value
    local is_valid = not analyse_api.contains_errors(status_codes)

    if is_valid then
        tree:add(config.ana_protocol.fields.is_valid, true)
    end
end

return analyse
