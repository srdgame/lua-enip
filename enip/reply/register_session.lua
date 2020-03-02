local class = require 'middleclass'
local msg = require 'cip.message'

local reply = class('LUA_ENIP_CIP_REPLY_REGISTER_SESSION', msg)

--- If status is 0 means register session is ok
-- or status should be 0x69 
function reply:initialize(session, protocol_version, options, status)
	self._protocol_version = protocol_version or 1
	self._options = options or 0

	local data = string.pack('<I2I2', self._protocol_version, self._options)
	self._msg = msg:new(session, msg.header.CMD_LIST_IDENTITY, data, 0)
end

function reply:from_hex(raw)
	msg.from_hex(raw)
	self._protocol_version, self._options = string.unpack('<I2I2', self:data())
end


function reply:protocol_version()
	return self._protocol_version
end

function reply:options()
	return self._options
end

return reply
