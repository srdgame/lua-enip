local class = require 'middleclass'
local types = require 'enip.command.item.types'
local item_base = require 'enip.command.item.base'

local item = class('LUA_ENIP_COMMAND_ITEM_CONNECTED_ADDRESS', item_base)

function item:initialize(identifier, sequence)
	item_base:initialize(types.CONNECTED_ADDR)
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
