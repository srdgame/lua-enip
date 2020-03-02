local class = require 'middleclass'
local cpf = require 'cip.item.base'
local types = require 'cip.item.types'

local sequenced_address = class('LUA_ENIP_CIP_TYPES_CONNECTED_ADDRESS', cpf)

function sequenced_address:initialize(identity, sequence)
	cpf:initialize(TYPE_ID.CONNECTED_ADDR)
	self._identity = tonumber(identity) or 0
	self._sequence = tonumber(sequence) or 0
end

function sequenced_address:encode()
	return string.pack('<I4I4', self._identity, self._sequence)
end

function sequenced_address:decode(raw)
	self._identity, self._sequence = string.unpack('<I4I4', raw)
end

function sequenced_address:identity()
	return self._identity
end

function sequenced_address:sequence()
	return self._sequence
end

return sequenced_address
