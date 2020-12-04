local types = require 'enip.command.item.types'
local base = require 'enip.command.item.base'

local item = base:subclass('enip.command.item.sequenced_addr')

function item:initialize(identifier, sequence)
	base.initialize(self, types.CONNECTED_ADDR)
	self._identifier = tonumber(identifier) or 0
	self._sequence = tonumber(sequence) or 0
end

function item:encode()
	return string.pack('<I4I4', self._identifier, self._sequence)
end

function item:decode(raw, index)
	self._identifier, self._sequence, index = string.unpack('<I4I4', raw, index)
	return index
end

function item:identifier()
	return self._identifier
end

function item:sequence()
	return self._sequence
end

return item
