local class = require 'middleclass'
local cip_parser = require 'enip.cip.parser'
local types = require 'enip.command.item.types'
local item_base = require 'enip.command.item.base'

local item = class('LUA_ENIP_COMMAND_ITEM_CONNECTED', item_base)

function item:initialize(identifier)
	item_base:initialize(types.CONNECTED)

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
