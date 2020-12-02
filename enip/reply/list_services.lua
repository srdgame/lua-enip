local class = require 'middleclass'
local types = require 'enip.command.types'
local command = require 'enip.command.base'
local command_parser = require 'enip.command.parser'

local li = class('enip.reply.list_services', command)

function li:initialize(session, data)
	command.initialize(self, session, types.CMD.LIST_SERVICES)

	self._data = data or ''
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
