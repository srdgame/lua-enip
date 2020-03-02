local class = require 'middleclass'
local msg = require 'cip.message'

--- UDP Only? List Identity
local req = class('LUA_ENIP_CIP_MSG_REQ_REGISTER_SESSION', msg)

function req:initialize(session, protocol_version, options)
	self._protocol_version = protocol_version or 1
	self._options = options or 0
	local data = string.pack('<I2I2', self._protocol_version, self._options)
	self._msg = msg:new(session, msg.header.CMD_REG_SESSION, data)
end

function req:from_hex(raw)
	msg.from_hex(raw)
	local data = self:data()
	self._protocol_version, self._options = string.unpack('<I2I2', data)
end

function req:protocol_version()
	return self._protocol_version
end

function req:options()
	return self._options
end

return req
