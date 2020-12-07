local parser = require 'enip.cip.parser'
local base = require 'enip.command.item.base'

local item = base:subclass('enip.command.item.connected')

function item:initialize(data)
	base.initialize(self, base.TYPES.CONNECTED)

	self._data = data
end

function item:encode()
	assert(self._data, "Data packet missing")
	return self._ata:to_hex()
end

function item:decode(raw, index)
	self._data, index = parser(raw, index)
	return index
end

function item:data()
	return self._data
end

return item
