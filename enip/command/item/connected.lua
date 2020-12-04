local class = require 'middleclass'
local base = require 'enip.command.item.base'

local item = class('enip.command.item.connected', base)

function item:initialize(identifier)
	base.initialize(self, base.TYPES.CONNECTED)

	self._identifier = identifier
end

function item:encode()
	return string.pack('<I4', self._identifier)
end

function item:decode(raw, index)
	self._identifier, index = string.unpack('<I4', raw, index)
	return index
end

function item:identifier()
	return self._identifier
end

return item
