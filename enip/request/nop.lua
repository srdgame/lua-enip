local class = require 'middleclass'
local msg = require 'enip.message'
local types = require 'enip.command.types'

local nop = class('enip.request.nop')

function nop:initialize(session, data)
	self._msg = msg:new(session, types.CMD.NOP, data or 'CIP_FROM_FREEEIOE')
end

function nop:__tostring()
	return tostring(self._msg)
end

function nop:to_hex()
	return self._msg:to_hex()
end

function nop:from_hex(raw, index)
	assert(false, 'from_hex is not supported')
end

function nop:data()
	return self._msg:data()
end

return nop
