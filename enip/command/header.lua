
local class = require 'middleclass'
local basexx = require 'basexx'

local session = require 'enip.utils.session'

local header = class('LUA_ENIP_HEADER')

header.static.CMD_NOP				= 0x00 --- TCP
header.static.CMD_LIST_SERVICES		= 0x04 --- UDP or TCP
header.static.CMD_LIST_IDENTITY		= 0x63 --- UDP or TCP
header.static.CMD_LIST_INTERFACES	= 0x64
header.static.CMD_REG_SESSION		= 0x65
header.static.CMD_UNREG_SESSION		= 0x66
header.static.CMD_SEND_RR_DATA		= 0x6f
header.static.CMD_SEND_UNIT_DATA	= 0x70
header.static.CMD_INDICATE_STATUS	= 0x72
header.static.CMD_CANCEL			= 0x73


local command_strings = {
	[0x00] = 'NOP',
	[0x04] = 'ListServices',
	[0x63] = 'ListIdentity',
	[0x64] = 'ListInterfaces',
	[0x65] = 'RegisterSession',
	[0x66] = 'UnRegisterSession'
	[0x6f] = 'SendRRData',
	[0x70] = 'SendUnitData',
	[0x72] = 'IndicateStatus',
	[0x73] = 'Cancel',
}

local function command_to_string(command)
	return command_strings[command] or 'Unknown command : '..command
end

---[[
-- DATA
--]]
header.static.CMD_READ_TAG			= 0x4c
header.static.CMD_WRITE_TAG			= 0x4d
header.static.CMD_READ_FRG			= 0x52
header.static.CMD_WRITE_FRG			= 0x53

header.static.CMD_REPLY_OK			= 0x80

header.static.STATUS_OK				= 0x00
header.static.ERR_NOT_SUPPORTED		= 0x01
header.static.ERR_MEMEORY_LIMIT		= 0x02
header.static.ERR_INVALID_MSG		= 0x03
header.static.ERR_SESSION_HANDLE	= 0x63
header.static.ERR_INVLIAD_LEN		= 0x64
header.static.ERR_PROTOCOL_VER		= 0x69

local status_strings = {
	[0x00] = 'Successs',
	[0x01] = 'The sender issued an invalid or unsupported encapsulation command.',
	[0x02] = 'Insufficient memory resources in the receiver to handle the command.',
	[0x03] = 'Poorly formed or incorrect data in the data portion of the encapsulation message.',
	[0x64] = 'An originator used an invalid session handle when sending an encapsulation message to the target.',
	[0x65] = 'The target received a message of invalid length',
	[0x69] = 'Unsupported encapsulation protocol revision.',
}

local function status_to_string(status)
	return status_string[status] or 'Unknown status code : '..status
end


--[[
-- Length is the data length. and the total message will be the length + 24 (header size)
-- Session handle: is returned from target to originator in reponse of a RegisterSession request
-- Status field: If receive the status none zero request, ignore it and no reply shell be genereated
-- Options: Sender shall set the optiosn field to zero. The receiver shall verify this zeror field. the reciever shall discard the message with non-zero option field
--]]

function header:initialize(session, command, length, status)
	assert(session, "Session object missing")
	assert(command, "Command missing")
	assert(length > 0, "Length invalid")
	self._command = command or self.CMD_NOP
	self._length = length or 0
	self._status = status or 0
	self._options = 0
	self._session = session
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

local hdr_fmt = 'CMD:%02X\tLEN:%d]\tSESSION:%04X\tSTATUS:%04X\tCTX:%s\tOPTS:%04X\nDATA:%s'

function header:__tostring()
	return string.format(hdr_fmt, self._command, self._length, self._session:session(), 
		self._status, basexx.to_hex(self._session:context()), self._options)
end

local fmt = '<I2I2I4I4c8I4'
function header:to_hex()
	return string.pack(fmt, self._command, self._length, self._session:session(), 
		self._status, tostring(self._session:context()), self._options)
end

function header:from_hex(raw)
	assert(string.len(raw) >= string.packsize(fmt))
	local session_, context
	self._command, self._length, session_, self._status, context, self._options = string.unpack(fmt, raw)
	self._session = session:new(session_, context)
end

function header:len()
	return string.packsize(fmt)
end

function header:command()
	return self._command & (~header.static.CMD_REPLY_OK)
end

function header:is_reply()
	return (self._command & header.static.CMD_REPLY_OK) == header.static.CMD_REPLY_OK
end

function header:length()
	return self._length
end

function header:set_length(len)
	self._length = len
end

function header:session()
	return self._sesssion
end

function header:status()
	return self._status
end

function header:set_status(status)
	self._status = status
end

function header:options()
	return self._options
end

return header

