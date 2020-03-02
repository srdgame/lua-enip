local class = require 'middleclass'
local cpf = require 'enip.cip.base'
local types = require 'enip.cip.types'

local item = class('LUA_ENIP_CIP_CONNECTED_MSG', cpf)

-- FIXME:

function item:initialize(conn_identity)
	cpf:initialize(types.CONNECTED_ADDR)
	self._conn_identity = tonumber(conn_identity) or 0
end

function item:encode()
	return string.pack('<I4', self._conn_identity)
end

function item:decode(raw)
	self._conn_identity = string.unpack('<I4', raw)
end

function item:identity()
	return self._conn_identity
end

return item
