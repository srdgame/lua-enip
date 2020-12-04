local base = require 'enip.command.base'

local nop = base:subclass('enip.request.nop')

function nop:initialize(session, data)
	base.initialize(base.COMMAND.NOP)
	self._data = data or 'CIP_FROM_FREEEIOE'
end

function nop:encode()
	return tostring(self._data)
end

function nop:decode(raw, index)
	return string.len(raw) + 1
end

function nop:data()
	return self._data
end

return nop
