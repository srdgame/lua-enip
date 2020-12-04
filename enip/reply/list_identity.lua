local base = require 'enip.command.base'
local command_data = require 'enip.command.data'

local li = base:subclass('enip.reply.list_identity')

function li:initialize(session, data)
	base.initialize(self, session, base.COMMAND.LIST_IDENTITY)

	self._data = data or ''
end

function li:encode()
	local data = self._data
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
