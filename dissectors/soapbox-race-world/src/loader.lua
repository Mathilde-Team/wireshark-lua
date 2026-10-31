-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/nilzao/soapbox-race-dissector (loader.lua),
-- commit 728072f5fe1c5292efa6c29e9d368b3184d3289d du 04/02/2018.
-- Licence amont : GPL-3.0 (LICENSE amont, sans mention « or later ») — voir README.md.

local debug   = require "debug"

function script_path()
  str = debug.getinfo(1, "S").source:sub(2)
  return str:match("(.*/)")
end

__DIR__ = script_path() .."src"
__DIR_SEPARATOR__ = package.path:match( "(%p)%?%." )

package.prepend_path("modules")
require "soapbox.boot"
