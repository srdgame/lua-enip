local parser = require 'enip.cip.parser'
local base = require 'enip.command.item.base'

local item = base:subclass('enip.command.item.unconnected')

function item:initialize(data)
	base.initialize(self, base.TYPES.UNCONNECTED)
	self._data = data 
end

function item:encode()
	assert(self._data, "Data missing")
	return self._data:to_hex()
end

function item:decode(raw, index)
	assert(raw, 'stream raw data is missing')
	self._data, index = parser(raw, index)
	return index
end

function item:data()
	return self._data
end

return item
