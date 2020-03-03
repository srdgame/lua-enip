local class = require 'middleclass'
local types = require 'enip.command.item.types'
local item_base = require 'enip.command.item.base'

local item = class('LUA_ENIP_COMMAND_CONNECTED_ADDRESS_ITEM', item_base)

function item:initialize(identity, sequence)
	item_base:initialize(types.CONNECTED_ADDR)
	self._identity = tonumber(identity) or 0
	self._sequence = tonumber(sequence) or 0
end

function item:encode()
	return string.pack('<I4I4', self._identity, self._sequence)
end

function item:decode(raw, index)
	self._identity, self._sequence, index = string.unpack('<I4I4', raw, index)
	return index
end

function item:identity()
	return self._identity
end

function item:sequence()
	return self._sequence
end

return item
