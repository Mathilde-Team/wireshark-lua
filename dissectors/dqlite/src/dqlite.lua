-- SPDX-License-Identifier: MIT
-- Importé de https://github.com/hersteller/wireshark-dissector-dqlite,
-- commit 8eee58ee46f33adae8ef738ea69426af29133916 du 27/07/2025.
-- Licence amont : MIT — voir README.md et LICENSE.
-- Define the protocol
local dqlite_proto = Proto("dqlite", "Distributed SQLite (dqlite)")

-- Header fields
local f_len     = ProtoField.uint32("dqlite.length",     "Body length (words)",   base.DEC)
local f_type    = ProtoField.uint8 ("dqlite.msg_type",   "Message type",          base.DEC)
local f_version = ProtoField.uint8 ("dqlite.schema_ver", "Schema version",        base.DEC)

dqlite_proto.fields = { f_len, f_type, f_version }

dqlite_port_number = 9001 -- Default port for dqlite, change if needed

-- Mapping tables
local client_requests = {
    [0]  = "Get current leader",
    [1]  = "Client registration",
    [3]  = "Open database",
    [4]  = "Prepare statement",
    [5]  = "Execute prepared statement",
    [6]  = "Execute prepared statement (rows)",
    [7]  = "Finalise statement",
    [8]  = "Execute SQL text",
    [9]  = "Execute SQL text (rows)",
    [10] = "Interrupt query",
    [12] = "Add non-voting node",
    [13] = "Assign role to node",
    [14] = "Remove node",
    [15] = "Dump database",
    [16] = "List nodes",
    [17] = "Transfer leadership",
    [18] = "Get node metadata",
    [19] = "Set node weight",
    [20] = "Leader local check",
}

local server_responses = {
    [0]  = "Failure response",
    [1]  = "Leader information",
    [2]  = "Welcome",
    [3]  = "Cluster information",
    [4]  = "Database information",
    [5]  = "Prepared statement info",
    [6]  = "Statement execution result",
    [7]  = "Batch of table rows",
    [8]  = "Acknowledgement",
    [9]  = "Database files",
    [10] = "Node metadata",
    [11] = "Leader confirm",
}

local tuple_type_codes = {
    [1]  = "Integer value stored using the int64",
    [2]  = "IEEE 754 floating point number stored in a single word",
    [3]  = "A string value using the text encoding",
    [4]  = "A binary blob: the first word of the value is the length of the blob (little endian)",
    [5]  = "A SQL NULL value encoded as a zeroed word",
    [10]  = "An ISO-8601 date value using the text encoding",
    [11]  = "A Boolean value using uint64 encoding (0 for false and 1 for true)"
}

local function heuristic_checker(buffer, pinfo, tree)
    -- Example: check for a magic byte or signature
    if buffer:len() < 4 then return false end
   -- if buffer(0,4):string() ~= "DQLT" then return false end

    local src_port = pinfo.src_port
    local dst_port = pinfo.dst_port

    --print("src_port1: " .. src_port)

    if not (src_port == dqlite_port_number or dst_port == dqlite_port_number) then   
        return false -- Not the port we are interested in
    end

    -- print("src_port1: " .. src_port)

    -- Looks like our protocol, dissect it
    dqlite_proto.dissector(buffer, pinfo, tree)
    return true
end

local function read_values(buffer, offset, col_types, subtree)
    -- Read and print column values based on their types
    for i = 1, #col_types do
        local col_type = col_types[i]
        if col_type == 1 then
            -- Integer value stored using the int64
            subtree:add_le(buffer(offset,8):le_int64(), "Column " .. i .. " value (int64)")
            offset = offset + 8
        elseif col_type == 2 then
            -- IEEE 754 floating point number stored in a single word
            subtree:add_le(buffer(offset,4):le_float(), "Column " .. i .. " value (float)")
            offset = offset + 4
        elseif col_type == 3 then
            -- A string value using the text encoding
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "Column " .. i .. " value (text)")
        elseif col_type == 4 then
            -- A binary blob: the first word of the value is the length of the blob (little endian)
            local blob_length = buffer(offset,4):le_uint32()
            offset = offset + 4
            subtree:add_le(blob_length, "Column " .. i .. " value (blob length)")
            subtree:add_le(buffer(offset,blob_length), "Column " .. i .. " value (blob data)")
            offset = offset + blob_length
        elseif col_type == 5 then
            -- A SQL NULL value encoded as a zeroed word
            subtree:add_le(buffer(offset,8):le_uint64(), "Column " .. i .. " value (NULL)")
            offset = offset + 8
        elseif col_type == 10 then
            -- An ISO-8601 date value using the text encoding
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "Column " .. i .. " value (date)")
        elseif col_type == 11 then
            -- A Boolean value using uint64 encoding (0 for false and 1 for true)
            subtree:add_le(buffer(offset,8):le_uint64(), "Column " .. i .. " value (boolean)")
            offset = offset + 8
        end
    end
    return offset
end 

local function read_paramtypes(buffer, offset, subtree, col_types)

    local number_of_params = 0
    local block_start_offset = offset
    if version == 0 then
        -- tbd: params-tupple, params-32 tuple for version 0
        local number_of_params = buffer(offset,1):le_uint8()
        subtree:add_le(number_of_params, "Number of parameters")
        offset = offset + 1
    else
        -- version 1
        local number_of_params = buffer(offset,4):le_uint32()
        subtree:add_le(number_of_params, "Number of parameters")
        offset = offset + 4
    end

    -- read parameter types
    for i = 1, number_of_columns do
        local type1 = buffer(offset):le_uint8()
        offset = offset + 1
        subtree:add_le(buffer(offset-1,1), "Parameter type " .. i .. " - " .. tuple_type_codes[type1])
        col_types[i] = type1
    end

    local block_size = offset - block_start_offset
    if block_size % 2 ~= 0 then
        -- pad to word boundary
        offset = offset + 1
    end

    return offset, col_types
end


-- Main dissector function
local function dqlite_proto_dissector(buffer, pinfo, tree)
    local buf_len = buffer:len()
    print("dqlite_proto_dissector : buffer:len() : " .. buf_len)
    -- Must have at least 8 bytes for the header
    if buf_len < 8 then
        -- ask for the rest of the header
        pinfo.desegment_offset = 0
        pinfo.desegment_len    = 8 - buf_len
        print("dqlite_proto_dissector : return buffer:len() < 8")
        return
    end

    --print("Dissecting dqlite packet")
    --caclulate lengtj of the message in bytes
    
    local body_words = buffer(0,4):le_uint()
    local body_bytes = body_words * 8        -- convert words to bytes
    local total_len  = 8 + body_bytes        -- header + body
    print("dqlite_proto_dissector : total_len" .. total_len)
    if buf_len < total_len then
        pinfo.desegment_offset = 0
        pinfo.desegment_len    = total_len - buf_len
        print("dqlite_proto_dissector : return buf_len" .. buf_len)
        return
    end
    
    print("dqlite_proto_dissector : start packet dissect")

    local src_port = pinfo.src_port
    local dst_port = pinfo.dst_port

    --print("src_port: " .. src_port)

    pinfo.cols.protocol = "DQLITE"

    local subtree = tree:add(dqlite_proto, buffer(), "dqlite Protocol")

    -- Parse header
    -- byte 0 to 3: Size of the message body, expressed in words and stored using little endian representation. 
    local body_words = buffer(0,4):le_uint()
    -- byte 4: Type code identifying the schema of the message body.
    local msg_type   = buffer(4,1):uint()
    -- byte 5: Message schema version. 
    local version    = buffer(5,1):uint()

    print("msg_type: " .. msg_type .. ", body_words: " .. body_words, " buf len: ", buffer:len()) 
    

    subtree:add_le(f_len,     buffer(0,4))
    if dqlite_port_number == dst_port then
        subtree:add(f_type,    buffer(4,1)):append_text(" (" ..
        (client_requests[msg_type] or "Unknown") .. ")")
    else
        subtree:add(f_type,    buffer(4,1)):append_text(" (" ..
        (server_responses[msg_type] or "Unknown") .. ")")
    end    
        
    subtree:add_le(f_version, buffer(5,1))

    -- bytes 6 and 7: Unused, reserved for future use, should be zero.
    subtree:add_le(buffer(6,2), "Unused fields")
    local offset = 8

    -- Dispatch based on message type
    -- (Implement body parsing for each case as needed)
    -- e.g., Failure response (type 0)
    if dqlite_port_number == dst_port then

        if msg_type == 0 then
            -- it is client request "Get current leader"
            subtree:add_le(buffer(offset,8):le_uint64(), "Unused field")
            offset = offset + 8
            print("Get current leader buf_len" .. buf_len)
        elseif msg_type == 1 then
            -- it is client request "Client registration"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the client")
            offset = offset + 8
        elseif msg_type == 3 then
            -- it is client request "Open database"
            local str = buffer(offset):stringz()
            local strlen = str:len() + 1  -- +1 for the null byte
            offset = offset + strlen
            subtree:add_le(str, "The name of the database")
            subtree:add_le(buffer(offset,8):le_uint64(), "Currently unused")
            offset = offset + 8
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset + str1len
            subtree:add_le(str1, "Currently unused")
        elseif msg_type == 4 then
            -- it is client request "Prepare statement"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the open database to use")
            offset = offset + 8
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "SQL text of the statement")
        elseif msg_type == 5 then
            -- it is client request "Execute prepared statemen"
            subtree:add_le(buffer(offset,4):le_uint32(), "ID of the open database to use")
            offset = offset + 4
            subtree:add_le(buffer(offset,4):le_uint32(), "ID of the prepared statement to execute")
            offset = offset + 4

            local col_types = {}

            offset, col_types = read_paramtypes(buffer, offset, subtree, col_types)

            -- read and print parameters
            offset = read_values(buffer, offset, col_types, subtree)

            elseif msg_type == 6 then
            -- it is client request "Execute prepared statement (rows)"
            subtree:add_le(buffer(offset,4):le_uint32(), "ID of the open database to use")
            offset = offset + 4
            subtree:add_le(buffer(offset,4):le_uint32(), "ID of the prepared statement to execute")
            offset = offset + 4
            -- params-tupple, params-32 tuple for version 1
            local col_types = {}
            offset, col_types = read_paramtypes(buffer, offset, subtree, col_types)
            -- read and print parameters
            offset = read_values(buffer, offset, col_types, subtree)
        elseif msg_type == 7 then
            -- it is client request "Finalise statement"
            subtree:add_le(buffer(offset,4):le_uint32(), "ID of the open database to use")
            offset = offset + 4
            subtree:add_le(buffer(offset,4):le_uint32(), "ID of the prepared statement to execute")
            offset = offset + 4
        elseif msg_type == 8 then
            -- it is client request "Execute SQL text"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the open database to use")
            offset = offset + 8
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "SQL text to execute")
            -- params-tupple, params-32 tuple for version 1
            local col_types = {}
            offset, col_types = read_paramtypes(buffer, offset, subtree, col_types)
            -- read and print parameters
            offset = read_values(buffer, offset, col_types, subtree)
        elseif msg_type == 9 then
            -- it is client request "Execute SQL text (rows)"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the open database to use")
            offset = offset + 8
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "SQL text to execute")
            -- params-tupple, params-32 tuple for version 1
            local col_types = {}
            offset, col_types = read_paramtypes(buffer, offset, subtree, col_types)
            -- read and print parameters
            offset = read_values(buffer, offset, col_types, subtree)
        elseif msg_type == 10 then
            -- it is client request "Interrupt query"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the open database to use")
            offset = offset + 8
        elseif msg_type == 12 then
            -- it is client request "Add non-voting node"
            -- node-info0 consists of a node ID (in uint64 encoding) followed by a node address (in text encoding). node-info consists of the same two fields, followed by a role code (in uint64 encoding).
            -- node-info0
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the node to add")
            offset = offset + 8
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "Address of the node to add")
        elseif msg_type == 13 then
            -- it is client request "Assign role to node"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the node to add")
            offset = offset + 8
            subtree:add_le(buffer(offset,8):le_uint64(), "New role")
            offset = offset + 8
        elseif msg_type == 14 then
            -- it is client request "Remove node"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the node to remove")
            offset = offset + 8
        elseif msg_type == 15 then
            -- it is client request "Dump database"
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "Name of the database to dump")
        elseif msg_type == 16 then
            -- it is client request "List nodes"
            subtree:add_le(buffer(offset,8):le_uint64(), "Format - should be 1")
            offset = offset + 8
        elseif msg_type == 17 then
            -- it is client request "Transfer leadership""
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the new leader")
            offset = offset + 8
        elseif msg_type == 18 then
            -- it is client request "Get node metadata"
            subtree:add_le(buffer(offset,8):le_uint64(), "Format - should be 0")
            offset = offset + 8
        elseif msg_type == 19 then
            -- it is client request "Set node weight"
            subtree:add_le(buffer(offset,8):le_uint64(), "New weight")
            offset = offset + 8
        elseif msg_type == 20 then
            -- it is client request "Set node weight"
            subtree:add_le(buffer(offset,8):le_uint64(), "Unused field")
            offset = offset + 8
        end
    else

        if msg_type == 0 then
            -- this is server response "Failure response"
            subtree:add_le(buffer(offset,8):le_uint64(), "Error code (from client)")
            offset = offset + 8
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1:stringz(), "Error message (from client)")
        elseif msg_type == 1 then
            -- this is server response "Leader information"
            -- node-info0 consists of a node ID (in uint64 encoding) followed by a node address (in text encoding). node-info consists of the same two fields, followed by a role code (in uint64 encoding).
            -- node-info0
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of the node to add")
            offset = offset + 8
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "Address of the node to add")
        elseif msg_type == 2 then
            -- this is server response "Welcome"
            subtree:add_le(buffer(offset,8):le_uint64(), "Currently unused")
            offset = offset + 8
        elseif msg_type == 3 then
            -- this is server response "Cluster information"
            -- node-info0 consists of a node ID (in uint64 encoding) followed by a node address (in text encoding). node-info consists of the same two fields, followed by a role code (in uint64 encoding).
            local number_of_nodes = buffer(offset,8):le_uint64()
            subtree:add_le(number_of_nodes, "Number of nodes in the cluster")
            offset = offset + 8
            -- node-info
           -- number_of_nodes = tonumber(number_of_nodes)
            number_of_nodes = number_of_nodes + 1
            local counter = 1
            while counter <= number_of_nodes do
                subtree:add_le(buffer(offset,8):le_uint64(), "ID of the node " .. counter)
                offset = offset + 8
                local str1 = buffer(offset):stringz()
                local str1len = str1:len() + 1  -- +1 for the null byte
                offset = offset+str1len
                subtree:add_le(str1, "Address of the node " .. counter)
                subtree:add_le(buffer(offset,8):le_uint64(), "Role of the node " .. counter)
                offset = offset + 8
                counter = counter + 1
            end

        elseif msg_type == 4 then
            -- this is server response "Database information"
            subtree:add_le(buffer(offset,4):le_uint32(), "Database ID")
            offset = offset + 4
            subtree:add_le(buffer(offset,4):le_uint32(), "Unused")
            offset = offset + 4
        elseif msg_type == 5 then
            -- this is server response "Prepared statement info"
            subtree:add_le(buffer(offset,4):le_uint32(), "Database ID")
            offset = offset + 4
            subtree:add_le(buffer(offset,4):le_uint32(), "Statement ID")
            offset = offset + 4
            subtree:add_le(buffer(offset,8):le_uint64(), "Number of parameters")
            offset = offset + 8
        elseif msg_type == 6 then
            -- this is server response "Statement execution result"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID of last row inserted, or 0")
            offset = offset + 8
            subtree:add_le(buffer(offset,8):le_uint64(), "Number of rows affected or 0")
            offset = offset + 8
        elseif msg_type == 7 then
            -- this is server response "Batch of table rows"
            local number_of_columns = buffer(offset,8):le_uint64()
            subtree:add_le(number_of_columns, "Number of columns")
            offset = offset + 8
            -- node-info
            for counter = 1, number_of_columns do
                local str1 = buffer(offset):stringz()
                local str1len = str1:len() + 1  -- +1 for the null byte
                offset = offset+str1len
                subtree:add_le(str1, "Name of column " .. counter)
            end
            -- tbd: read row tuples until marker 0xffffffffffffffff
            -- or 0xeeeeeeeeeeeeeeee if there are more rows in another batch
            -- check if there is marker and finish if there is
            local endmarkercheck = buffer(offset,8):le_uint64()
            while endmarkercheck ~= 0xffffffffffffffff and endmarkercheck ~= 0xeeeeeeeeeeeeeeee  
            do
                local endmarkercheck = buffer(offset,8):le_uint64()
                -- read row tuple, its ok we do not need db schema for that
                -- because we have culumn number, types and encoding for each type
                
                -- first read column types
                local col_types = {}

                local current collumn = 0
                local block_start_offset = offset

                for i = 1, number_of_columns / 2 + 1 do
                    local byte = buffer(offset):le_uint8()
                    offset = offset + 1
                    local type1 = bit.rshift(byte, 4)      -- Right shift by 4 to get the upper 4 bits
                    local type2 = bit.band(byte, 0x0F)     -- Mask with 0x0F to get the lower 4 bits

                    col_types[2*(i-1)] = type1
                    current_column = current_column + 1
                    if current_column < number_of_columns then
                        col_types[2*(i-1)+1] = type2
                        current_column = current_column + 1
                        subtree:add_le(buffer(offset-1,1), "Column type " .. i .. " - " .. tuple_type_codes[type1] .. ", " .. tuple_type_codes[type2])
                    else
                        subtree:add_le(buffer(offset-1,1), "Column type " .. i .. " - " .. tuple_type_codes[type1])
                    end
                    -- local upper_nibble = bit.rshift(byte, 4)      -- Right shift by 4 to get the upper 4 bits
                    -- local lower_nibble = bit.band(byte, 0x0F)     -- Mask with 0x0F to get the lower 4 bits
                end
                -- get to word bundary and read and print column values
                local block_size = offset - block_start_offset
                if block_size % 2 ~= 0 then
                    -- pad to word boundary
                    offset = offset + 1
                end

                offset = read_values(buffer, offset, col_types, subtree)

                
            end

        elseif msg_type == 8 then
            -- this is server response "Acknowledgement"
            subtree:add_le(buffer(offset,8):le_uint64(), "Unused")
            offset = offset + 8
        elseif msg_type == 9 then
            -- this is server response "Database files"
            subtree:add_le(buffer(offset,8):le_uint64(), "Number of files = 2")
            offset = offset + 8
            -- read files: A single database file. It consists of the file name (in text encoding), followed by the file size (in uint64 encoding) and finally a blob with the file content.

            
            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "Main database file name")
            subtree:add_le(buffer(offset,8):le_uint64(), "Main database file size")
            offset = offset + 8
            subtree:add_le(buffer(offset,buffer:len()-offset):bytes(), "Main database file content")
            offset = offset + (buffer:len() - offset)

            local str1 = buffer(offset):stringz()
            local str1len = str1:len() + 1  -- +1 for the null byte
            offset = offset+str1len
            subtree:add_le(str1, "Write-ahead log file name")
            subtree:add_le(buffer(offset,8):le_uint64(), "Write-ahead log file size")
            offset = offset + 8
            subtree:add_le(buffer(offset,buffer:len()-offset):bytes(), "Write-ahead log file content")
            offset = offset + (buffer:len() - offset)

        elseif msg_type == 10 then
            -- this is server response "Node metadata"
            subtree:add_le(buffer(offset,8):le_uint64(), "Failure domain")
            offset = offset + 8
            subtree:add_le(buffer(offset,8):le_uint64(), "Weight")
            offset = offset + 8

        elseif msg_type == 11 then
            -- this is server response "Leader confirm"
            subtree:add_le(buffer(offset,8):le_uint64(), "ID")
            offset = offset + 8
            subtree:add_le(buffer(offset,8):le_uint64(), "Is leader")
            offset = offset + 8

        end



        
    end

    return total_len -- Return the number of bytes processed

end

function dqlite_proto.dissector(tvbuf, pinfo, tree)
    dqlite_proto_dissector(tvbuf, pinfo, tree)
    return tvbuf:len() -- Return the number of bytes processed
end

-- register for packets to and from port 9001
-- DissectorTable.get("tcp.port"):add(dqlite_port_number, dqlite_proto)
dqlite_proto:register_heuristic("tcp", heuristic_checker)
