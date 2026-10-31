-- SPDX-License-Identifier: GPL-2.0-only
-- Importé de https://github.com/diarmuidcwc/LuaDissectors,
-- commit 78bf79c9cb5634036b152baa51091c4f3c8de577 du 29/05/2026.
-- Licence amont : GPLv2 (fichier LICENSE) — voir README.md.

-- 
-- This dissects the temperature reported from the BCU

counter_proto = Proto("counter","Incrementing Counters")
-- Declare a few fields that we are in
f_counterror = ProtoField.bool("counter.error","Error",base.NONE)

counter_proto.fields = {f_counterror}

-- create a function to dissect it
function counter_proto.dissector(buffer,pinfo,tree)

	pinfo.cols.protocol = "counter"
    
    parameter_instances = {2,256}
    
    offset = 0
    f_counterror = false
    for i , instancecnt in ipairs(parameter_instances) do
        all_good = true
        local param_tree = tree:add(buffer(offset,2*instancecnt),"Parameter " .. i)
        value =  buffer(offset,2):uint()
        for off=2,instancecnt*2-2,2 do
            if (value + 1) % 65536 ~= buffer(offset+off,2):uint() then
                param_tree:add(buffer(off+offset,2),"ERROR: Not incrementing offset=".. off)
                all_good = false
            end 
            value = buffer(off+offset,2):uint()
        end
        if all_good == true then
            param_tree:set_text("Parameter ".. i .." GOOD")
        else
            param_tree:set_text("Parameter ".. i .." ERROR")
            f_counterror = true
        end
        offset = offset + instancecnt*2
    end
	
end