local class = require 'middleclass'
local cpf = require 'enip.cip.base'
local types = require 'enip.cip.types'

local item = class('LUA_ENIP_CIP_UNCONNECTED_MSG', cpf)

-- FIXME:

function item:initialize(data_item)
	cpf:initialize(types.UNCONNECTED)
	self._data_item = data_item or ''
end

function item:encode()
	local data_item = self._data_item
	return data_item.to_hex and data_item:to_hex() or tostring(data_item)
end

function item:decode(raw)
	assert(nil, "FIXME:How to decode it")
end

function item:data_item()
	return self._data_item
end

return item
