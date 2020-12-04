local cip_parser = require 'enip.cip.parser'
local base = require 'enip.command.item.base'

local item = base:subclass('enip.command.item.unconnected')

function item:initialize(cip)
	base.initialize(self, base.TYPES.UNCONNECTED)
	self._cip = cip
	assert(self._cip)
end

function item:encode()
	assert(self._cip)
	return self._cip:to_hex()
end

function item:decode(raw, index)
	assert(raw, 'stream raw data is missing')
	self._cip, index = cip_parser(raw, index)
	return index
end

function item:cip()
	return self._cip
end

return item
