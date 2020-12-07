local types = require 'enip.command.item.types'
local base = require 'enip.command.item.base'

local item = base:subclass('enip.command.item.sockaddr')

function item:intialize(type, info)
	assert(type == types.SOCK_ADDR_S or type == types.SOCK_ADDR_C)
	base:intialize(type)
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

function item:info()
	return self._info
end

return item
