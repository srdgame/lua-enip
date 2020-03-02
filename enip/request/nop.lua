local class = require 'middleclass'
local msg = require 'enip.message'

local nop = class('LUA_ENIP_MSG_REQ_NOP')

function nop:initialize(session, data)
	self._msg = msg:new(session, msg.header.CMD_NOP, data or 'CIP_FROM_FREEEIOE')
end

function nop:__tostring()
	return tostring(self._msg)
end

function nop:to_hex()
	return self._msg:to_hex()
end

function nop:from_hex()
	assert(false, 'from_hex is not supported')
end

function nop:data()
	return self._msg:data()
end

return nop
