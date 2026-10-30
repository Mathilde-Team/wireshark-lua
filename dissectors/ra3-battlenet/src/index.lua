-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://github.com/RA3BattleNet/Dissectors (index.lua),
-- commit ecc04fa452951de4607dd5884da3bbb66a3b718f du 21/10/2022.
-- Licence amont : GPL-2.0-only (fichier LICENSE, GPLv2 sans mention « or later ») — voir README.md.

return function(base_path)
    dofile(base_path .. 'gpcm.lua')
    dofile(base_path .. 'peerchat.lua')
    dofile(base_path .. 'querymaster.lua')
end
