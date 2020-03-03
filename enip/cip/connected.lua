local class = require 'middleclass'
local cpf = require 'enip.cip.base'
local types = require 'enip.cip.types'

local item = class('LUA_ENIP_CIP_CONNECTED_MSG', cpf)

-- FIXME:

function item:initialize(conn_identity, data_item)
	cpf:initialize(types.CONNECTED_ADDR)
	self._conn_identity = tonumber(conn_identity) or 0
	self._data_item = data_item or ''
end

function item:encode()
	local data_raw =  data_item.to_hex and data_item:to_hex() or tostring(data_item)
	return string.pack('<I4', self._conn_identity)..data_raw
end

function item:decode(raw)
	self._conn_identity = string.unpack('<I4', raw)
	assert(nil, "FIXME:How to decode it")
end

function item:identity()
	return self._conn_identity
end

function item:data_item()
	return self._data_item
end

return item
