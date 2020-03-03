local class = require 'middleclass'
local cpf = require 'enip.cip.base'
local types = require 'enip.cip.types'

local sockaddr_info = class('LUA_ENIP_CIP_TYPS_SOCKADDR_INFO', cpf)

function sockaddr_info:intialize(from_target, info)
	cpf:intialize(from_target and types.SOCK_ADDR_S or types.SOCK_ADDR_C)
	self._info = info or {}
end

function sockaddr_info:encode()
	local info = self._info
	info.sin_zero = info.sin_zero or string.rep('\0', 8)
	return string.pack('>i2I2I4', info.sin_family, info.sin_prot, info.sin_addr)..info.sin_zero
end

function sockaddr_info:decode(raw)
	local info = self._info
	info.sin_family, info.sin_port, info.sin_addr, info.sin_zero = string.unpack('>i2I2I4c8', raw)
end


return sockaddr_info
