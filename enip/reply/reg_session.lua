local base = require 'enip.command.base'

local reply = base:subclass('enip.reply.reg_session')

--- If status is 0 means register session is ok
-- or status should be 0x69 
function reply:initialize(session, protocol_version, options, status)
	base.initialize(self, session, base.COMMAND.REG_SESSION)

	self._protocol_version = protocol_version or 1
	self._options = options or 0

end

function reply:encode()
	return string.pack('<I2I2', self._protocol_version, self._options)
end

function reply:decode(raw, index)
	self._protocol_version, self._options, index = string.unpack('<I2I2', raw, index)
	return index
end


function reply:protocol_version()
	return self._protocol_version
end

function reply:options()
	return self._options
end

return reply
