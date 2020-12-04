local class = require 'middleclass'
local base = require 'enip.serializable'

local session = require 'enip.utils.session'
local types = require 'enip.command.types'

local command = class('enip.command.base', base)

command.static.COMMAND = {
	NOP					= 0x00, --- TCP
	LIST_SERVICES		= 0x04, --- UDP or TCP
	LIST_IDENTITY		= 0x63, --- UDP or TCP
	LIST_INTERFACES		= 0x64,
	REG_SESSION			= 0x65,
	UNREG_SESSION		= 0x66,
	SEND_RR_DATA		= 0x6f,
	SEND_UNIT_DATA		= 0x70,
	INDICATE_STATUS		= 0x72,
	CANCEL				= 0x73,
}

local command_strings = {
	[0x00] = 'NOP',
	[0x04] = 'ListServices',
	[0x63] = 'ListIdentity',
	[0x64] = 'ListInterfaces',
	[0x65] = 'RegisterSession',
	[0x66] = 'UnRegisterSession',
	[0x6f] = 'SendRRData',
	[0x70] = 'SendUnitData',
	[0x72] = 'IndicateStatus',
	[0x73] = 'Cancel',
}

local function command_to_string(command)
	return command_strings[command] or 'Unknown command : '..command
end

command.static.command_name = command_to_string

local header_fmt = '<I2I2I4I4c8I4'

command.static.min_size = function()
	return string.packsize(header_fmt)
end

command.static.parse_header = function(raw, index)
	local command, len = string.unpack(header_fmt, raw, index)	
	return command, len
end

--[[
-- Length is the data length. and the total message will be the length + 24 (header size)
-- Session handle: is returned from target to originator in reponse of a RegisterSession request
-- Status field: If receive the status none zero request, ignore it and no reply shell be genereated
-- Options: Sender shall set the optiosn field to zero. The receiver shall verify this zeror field. the reciever shall discard the message with non-zero option field
--]]

function command:initialize(session, command, status)
	self._command = command or types.CMD.NOP
	self._status = status or 0
	self._options = 0 -- Must be zero
	self._session = session
end

function command:encode()
	assert(nil, "Not Implemented!")
end

function command:decode(raw, index)
	assert(nil, "Not Implemented!")
end

--[[
-- The header is little-endian encoded structure
-- Command: UINT (unsigned short)
-- Length:	UINT (unsigned short)
-- Session:	UDINT (unsigned int)
-- Status:	UDINT (unsigned int)
-- Context: BYTE[8] 
-- Options: UDINT (unsigned int)
--]]

local hdr_fmt = 'CMD:%02X\tLEN:%d]\tSESSION:%04X\tSTATUS:%04X\tCTX:%s\tOPTS:%04X'

function command:__tostring()
	return string.format(hdr_fmt, self._command, self._length, self._session:session(), 
		self._status, basexx.to_hex(self._session:context()), self._options)
end

function command:to_hex()
	assert(self._session, 'Session missing')
	local data_raw = self:encode()
	local data_len = string.len(data_raw)
	return string.pack(header_fmt, self._command, data_len, self._session:session(), 
		self._status, tostring(self._session:context()), self._options)
end

function command:from_hex(raw, index)
	local session_, context, data_len
	self._command, data_len, session_, self._status, context, self._options, index
		= string.unpack(header_fmt, raw, index)
	self._session = session:new(session_, context)
	local data_raw = string.sub(raw, index, index + data_len)

	local d_len = self:decode(raw, index)
	assert(d_len == data_len + 1, "Command data decode error!")
	
	return index + data_len
end

function command:command()
	return self._command
end

function command:session()
	return self._session
end

function command:status()
	return self._status
end

function command:set_status(status)
	self._status = status
end

function command:options()
	return self._options
end

return command

