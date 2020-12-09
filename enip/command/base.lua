local base = require 'enip.serializable'
local logger = require 'enip.logger'
local session = require 'enip.utils.session'

local command = base:subclass('enip.command.base')

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

command.static.STATUS = {
	SUCCESS				= 0x00,
	INVALID_COMMAND		= 0x01,
	MEMORY_ISSUE		= 0x02,
	POOR_FORMED_DATA	= 0x03,
	INVALID_SESSION		= 0x64,
	INVALID_LENGTH		= 0x65,
	UNSUPPORT_VERSION	= 0x69,
}

status_strings = {
	[0x00] = 'Sucess',
	[0x01] = 'The sender issued an invalid or unsupported encapsulation command.',
	[0x02] = 'Insufficient memory resources in the receiver to handle the command',
	[0x03] = 'Poorly formed or incorrect data in the data portion of the encapsulation message.',
	[0x64] = 'An originator used an invalid session handle when sending an encapsulation message to the target',
	[0x65] = 'The target received a message of invalid length',
	[0x69] = 'Unsupported encapsulation protocol revision.',
}

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
	base.initialize(self)
	self._command = command or command.static.COMMAND.NOP
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

local hdr_fmt = 'C:0x%02X S:%04X S:%04X C:%s O:%04X'

function command:__tostring()
	local basexx = require 'basexx'
	if not self._session then
		return 'COMMAND not initialized'
	end
	return string.format(hdr_fmt, self._command, self._session:session(), 
		self._status, basexx.to_hex(self._session:context()), self._options)
end

function command:to_hex()
	assert(self._session, 'Session missing')
	local data_raw = self:encode()
	logger.dump('command.base.to_hex', data_raw)
	local data_len = string.len(data_raw)
	return string.pack(header_fmt, self._command, data_len, self._session:session(), 
		self._status, tostring(self._session:context()), self._options)..data_raw
end

function command:from_hex(raw, index)
	local session_, context, data_len
	self._command, data_len, session_, self._status, context, self._options, index
		= string.unpack(header_fmt, raw, index)
	self._session = session:new(session_, context)

	if data_len > 0 then
		local data_raw = string.sub(raw, index, index + data_len - 1)

		local d_index = self:decode(data_raw)
		assert(d_index == data_len + 1, "Command data decode error!")
	end
	
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

function command:error_info()
	return status_strings[self._status] or "Unknown status:"..self._status
end

function command:set_status(status)
	self._status = status
end

function command:options()
	return self._options
end

return command

