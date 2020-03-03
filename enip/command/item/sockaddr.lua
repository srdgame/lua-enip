local class = require 'middleclass'
local types = require 'enip.command.item.types'
local item_base = require 'enip.command.item.base'

local item = class('LUA_ENIP_COMMAND_SOCKADDR_INFO_ITEM', item_base)

function item:intialize(from_target, info)
	item_base:intialize(from_target and types.SOCK_ADDR_S or types.SOCK_ADDR_C)
	self._info = info or {}
end

function item:encode()
	local info = self._info
	info.sin_zero = info.sin_zero or string.rep('\0', 8)
	return string.pack('>i2I2I4', info.sin_family, info.sin_prot, info.sin_addr)..info.sin_zero
end

function item:decode(raw, index)
	local info = self._info
	info.sin_family, info.sin_port, info.sin_addr, info.sin_zero, index = string.unpack('>i2I2I4c8', raw, index)
	return index
end


return item
