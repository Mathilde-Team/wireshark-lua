-- SPDX-License-Identifier: GPL-2.0-or-later
-- Importé de https://github.com/MarkoPaul0/WireBait,
-- commit 47e46acef0b4dff447ef18289084c9c03a075afa du 24/02/2021.
-- Licence amont : GNU GPL v2 (LICENSE.txt amont ; interprétée GPL-2.0-or-later,
-- à la Wireshark) — voir README.md.
--[[
    WireBait for wirebait is a lua package to help write Wireshark
    Dissectors in lua
    [Wirebait on Github](https://github.com/MarkoPaul0/WireBait)
    Copyright (C) 2015-2017 Markus Leballeux

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]

--TODO: this class is a work in progress

local FieldInfoClass = {};

function FieldInfoClass.new(protofield)
    assert(protofield);
    local field_info = {
        m_protofield = protofield;
    }

    ------------------------------------------------ metamethods -------------------------------------------------------

    function field_info:__len()
        error("FieldInfo:__len() is not supported yet!");
    end

    function field_info:__unm()
        error("FieldInfo:__unm() is not supported yet!");
    end

    function field_info:__call()
        return self.m_protofield:getValueFromBuffer(self.m_protofield.m_last_buffer);
    end

    function field_info:__tostring()
        return self.m_protofield:getDisplayValueFromBuffer(self.m_protofield.m_last_buffer);
    end

    function field_info.__le()
        error("FieldInfo.__le() is not supported yet");
    end

    function field_info.__lt()
        error("FieldInfo.__lt() is not supported yet");
    end

    function field_info.__eq()
        error("FieldInfo.__eq() is not supported yet");
    end

    setmetatable(field_info, field_info)

    return field_info;
end



return FieldInfoClass;