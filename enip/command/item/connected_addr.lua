local class = require 'middleclass'
local types = require 'enip.command.item.types'
local item_base = require 'enip.command.item.base'

local item = class('LUA_ENIP_COMMAND_CONNECTED_ADDRESS_ITEM', item_base)

function item:initialize(conn_identity)
	item_base.initialize(self, types.CONNECTED_ADDR)
	self._conn_identity = tonumber(conn_identity) or 0
end

function item:encode()
	return string.pack('<I4', self._conn_identity)
end

function item:decode(raw, index)
	self._conn_identity, index = string.unpack('<I4', raw, index)
	return index
end

function item:identity()
	return self._conn_identity
end
