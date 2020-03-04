
local class = require 'middleclass'
local basexx = require 'basexx'

local session = require 'enip.utils.session'
local types = require 'enip.command.types'

local header = class('LUA_ENIP_COMMAND_HEADER')

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
	self._command = command or types.CMD.NOP
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
	return self._command
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

