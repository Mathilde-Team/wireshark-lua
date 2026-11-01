-- SPDX-License-Identifier: GPL-2.0-or-later
-- Importé de https://github.com/MarkoBursic/SMITH-meter-Wireshark-dissector (smith-dissector.lua),
-- commit e9964f7d82e98c9fd15b50284532ab47788df145 du 17/04/2024.
-- Licence amont : « GPL according to Wireshark Foundation ToS » (en-tête du fichier) — voir README.md.
--[[
	13.2.2023
	SMITH-dissector.lua V0.0.1
	Wireshark Lua SMITH protocol dissector

	Source code by Marko Bursic, GPL according to Wireshark Foundation ToS
	https://www.robotina.com
	Use at your own risk

	History:
		13.2.2023: start
--]]


function string.endswith(sString, sEnd)
	return sEnd == '' or sString:sub(-sEnd:len()) == sEnd
end



local function NilToQuestionmark(value)
	if value == nil then
		return '?'
	else
		return value
	end
end

local function CmdToQuestionmark(value)

	if value == 'AB' then
		return 'Allocate Blend Recipes'
	elseif value == 'AP' then
		return 'Autorize Transaction To Preset'		
	elseif value == 'AR' then
		return 'Alarm Reset'		
	elseif value == 'AT' then
		return 'Request Additive Volumes by Transaction'		
	elseif value == 'AU' then
		return 'Authorize Transaction'		
	elseif value == 'AV' then
		return 'Request Additive Volumes by Batch'		
	elseif value == 'DY' then
		return 'Request Dynamic Display Values'				
	elseif value == 'EA' then
		return 'Enquire Alarms'
	elseif value == 'EB' then
		return 'End Batch'
	elseif value == 'EE' then
		return 'Enquire Status Extended'
	elseif value == 'EQ' then
		return 'Enquire Status'		
	elseif value == 'ET' then
		return 'End Transaction'		
	elseif value == 'FL' then
		return 'Read Flow Count'		
	elseif value == 'GD' then
		return 'Get Date and Time'
	elseif value == 'PC' then
		return 'Change Program Code Values'
	elseif value == 'PF' then
		return 'Request Time of Power-Fail'		
	elseif value == 'PV' then
		return 'Request Program Code Values'		
	elseif value == 'RA' then
		return 'Request Alarm Status'
	elseif value == 'RB' then
		return 'Request Batch Totals'
	elseif value == 'RC' then
		return 'Request Recipe Composition'
	elseif value == 'RD' then
		return 'Request Current Transducer Value'		
	elseif value == 'RE' then
		return 'Reset Status Conditions'
	elseif value == 'RK' then
		return 'Read Keypad'					
	elseif value == 'RL' then
		return 'Show Recipes Loaded'
	elseif value == 'RQ' then
		return 'Request Current Flow Rate'		
	elseif value == 'RR' then
		return 'Request Recipe'
	elseif value == 'RS' then
		return 'Request Status'						
	elseif value == 'RT' then
		return 'Request Transaction Totals'
	elseif value == 'SA' then
		return 'Remote Start'
	elseif value == 'SB' then
		return 'Set Batch'
	elseif value == 'SD' then
		return 'Set Date and Time'
	elseif value == 'SF' then
		return 'Authorize and Set Batch without Override'
	elseif value == 'SP' then
		return 'Remote Stop'
	elseif value == 'SR' then
		return 'Show Recipes Currently Allocated'
	elseif value == 'ST' then
		return 'Remote Stop on Arm'
	elseif value == 'TA' then
		return 'Set Transaction'	
	elseif value == 'TI' then
		return 'Show Prompt Data Entry'			
	elseif value == 'TN' then
		return 'Show Transaction Stop Date and Time'
	elseif value == 'VT' then
		return 'Request Meter Totalizer'
	elseif value == 'WA' then
		return 'Write Second Line of Message to Appear on Display'	
	elseif value == 'WB' then
		return 'Write Third Line of Message to Appear on Display'			
	elseif value == 'WC' then
		return 'Write Fourth Line of Message to Appear on Display'	
	elseif value == 'WD' then
		return 'Write to Display'			
	else
		return '?'
	end
end

local function DefineAndRegisterSMITHdissector()
	local sProtocol = 'SMITH'

	local oProtoSMITH = Proto(sProtocol, sProtocol:upper() .. ' Protocol')

	local NULL = 0
	local STX = 2
	local ETX = 3	
	local PAD = 1	

    local QUERY = 2
	local RESPONSE = 0
	local dirType = {[NULL]='Resp', [STX]='Query'}
	local eType = {[ETX]='ETX'}
	local tResult = {[0]='Fail', [1]='Success'}
	local tBoolean = {[0]='False', [1]='True'}
	local tcmd = {['GD']='Get Date'}

	oProtoSMITH.fields.start = ProtoField.uint8(sProtocol .. '.start', 'Dir', base.DEC, dirType, nil, 'Direction of comm')
	oProtoSMITH.fields.data = ProtoField.string(sProtocol .. '.data', 'Text', 'The data of the command')	
	oProtoSMITH.fields.Address = ProtoField.uint8(sProtocol .. '.Addr', 'Address', base.DEC, nil, nil,'Address of the device')	
	oProtoSMITH.fields.Cmd = ProtoField.string(sProtocol .. '.cmd', 'CMD', 'The command of the query')


	function oProtoSMITH.dissector(oTvbProtocolData, oPinfo, oTreeItemRoot)
		local sProtocolName = oProtoSMITH.name

		local iProtocolDataLength = oTvbProtocolData:len()

		-- We expect at least 6 bytes, otherwise we don't dissect
		if iProtocolDataLength < 6 then
			return
		end
	
		local oTvbDirection    = oTvbProtocolData(0, 1)		
		local uiDirection      = oTvbDirection:uint()

--[[		local uiCommand   = oTvbCommand:uint()

		-- We expect protocol version 1, otherwise we don't dissect
		if uiVersion ~= 1 then
			return
		end
--]]
		-- We expect a valid command type, otherwise we don't dissect
		if dirType[uiDirection] == nil then
			return
		end

		oPinfo.cols.protocol = sProtocolName



		if uiDirection == QUERY then	
			
			local A1 = oTvbProtocolData(1,1):uint()
			local A2 = oTvbProtocolData(2,1):uint()
			local oTvbAddress = (A1-48)*10 + (A2-48)
			local oTvbCommand = oTvbProtocolData(3, 2)		
			local uiCommand = oTvbCommand:string()
			
			oPinfo.cols.info = 'Addr '..oTvbAddress..','..dirType[uiDirection]
			local oTreeItemSMITH = oTreeItemRoot:add(oProtoSMITH, oTvbProtocolData(), sProtocolName .. ' Protocol Data')
			local oTreeItemMessage = oTreeItemSMITH:add(oTvbProtocolData(1), 'Message')
			oTreeItemMessage:add(oProtoSMITH.fields.start, oTvbDirection)				

			oTreeItemMessage:add(oProtoSMITH.fields.Address, oTvbAddress)
			local oTvbData = oTvbProtocolData(3, iProtocolDataLength-5)
			oTreeItemMessage:add(oProtoSMITH.fields.data, oTvbData)
			oPinfo.cols.info:append(': ' .. oTvbData:string())
			local CommandInfo = CmdToQuestionmark(uiCommand)
			oTreeItemMessage:add(oProtoSMITH.fields.Cmd, CommandInfo)
--			oPinfo.cols.info:append('   CMD: ' .. CommandInfo)		
		end
		
		if uiDirection == RESPONSE then
		
			local A1 = oTvbProtocolData(2,1):uint()
			local A2 = oTvbProtocolData(3,1):uint()
			local oTvbAddress = (A1-48)*10 + (A2-48)
				
			oPinfo.cols.info = 'Addr '..oTvbAddress..','..dirType[uiDirection]
			local oTreeItemSMITH = oTreeItemRoot:add(oProtoSMITH, oTvbProtocolData(), sProtocolName .. ' Protocol Data')
			local oTreeItemMessage = oTreeItemSMITH:add(oTvbProtocolData(1), 'Message')
			oTreeItemMessage:add(oProtoSMITH.fields.start, oTvbDirection)				

			oTreeItemMessage:add(oProtoSMITH.fields.Address, oTvbAddress)
			local oTvbData = oTvbProtocolData(4, iProtocolDataLength-7)
			oTreeItemMessage:add(oProtoSMITH.fields.data, oTvbData)
			oPinfo.cols.info:append(': ' .. oTvbData:string())		
				
		end		
	end
	DissectorTable.get('tcp.port'):add(7734, oProtoSMITH)
end

local function Main()
	DefineAndRegisterSMITHdissector()
end

Main()
