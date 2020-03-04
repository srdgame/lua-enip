local class = require 'middleclass'
local command = require 'enip.command.base'
local command_parser = require 'enip.commmand.parser'

local li = class('LUA_ENIP_MSG_REPLY_LIST_IDENTITY', command)

function li:initialize(session, data)
	command:initialize(session, command.header.CMD_LIST_IDENTITY)

	self._data = data or ''
end

function li:encode()
	lcoal data = self._data

	return data.to_hex() and data:to_hex() or tostring(data)
end

function li:deocode(raw, index)
	self._data, index = command_parser.parse(command_data)
	return index
end

function li:data()
	return self._data
end

return li
