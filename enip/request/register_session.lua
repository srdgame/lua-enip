local class = require 'middleclass'
local command = require 'enip.command.base'

--- UDP Only? List Identity
local req = class('LUA_ENIP_MSG_REQ_REGISTER_SESSION', command)

function req:initialize(session, protocol_version, options)
	command:initialize(session, command.header.CMD_REG_SESSION)

	self._protocol_version = protocol_version or 1
	self._options = options or 0
end

function req:encode()
	return string.pack('<I2I2', self._protocol_version, self._options)
end

function req:decode(raw, index)
	self._protocol_version, self._options, index = string.unpack('<I2I2', data, index)
	return index
end

function req:protocol_version()
	return self._protocol_version
end

function req:options()
	return self._options
end

return req
