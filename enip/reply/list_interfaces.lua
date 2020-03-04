local class = require 'middleclass'
local types = require 'enip.command.types'
local command = require 'enip.command.base'

local li = class('LUA_ENIP_MSG_REPLY_LIST_INTERFACES', command)

function li:initialize(session, data)
	command:initialize(session, types.CMD.LIST_INTERFACES)

	self._data = data
end

function li:encode()
	lcoal data = self._data

	return data.to_hex() and data:to_hex() or tostring(data)
end

function li:deocode(raw, index)
	self._data = command_data:new()
	index = self._data:from_hex(raw, index)
	return index
end

function li:data()
	return self._data
end

return li
