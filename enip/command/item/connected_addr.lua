local base = require 'enip.command.item.base'

local item = base:subclass('enip.command.item.connected_addr')

function item:initialize(identifier)
	base.initialize(self, base.TYPES.CONNECTED_ADDR)
	self._identifier = tonumber(identifier) or 0
end

function item:encode()
	return string.pack('<I4', self._identifier)
end

function item:decode(raw, index)
	self._identifier, index = string.unpack('<I4', raw, index)
	return index
end

function item:identity()
	return self._identifier
end
