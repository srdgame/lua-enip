local class = require 'middleclass'
local msg = require 'enip.message'
local cip_parser = require 'enip.cip.parser'

--- UDP Only? List Identity
local req = class('LUA_ENIP_MSG_REQ_SEND_UNIT_DATA', msg)

function req:initialize(session, cip, timeout)
	self._cip = cip
	self._interface_handle = 0 --- CIP over ENIP must be zero here
	self._timeout = timeout or 0

	local data = string.pack('<I4I2', self._interface_handle, self._timeout)
	local cip_data = cip.to_hex and cip:to_hex() or tostring(cip)
	self._msg = msg:new(session, msg.header.CMD_REG_SESSION, data..cip_data)
end

function req:from_hex(raw)
	msg.from_hex(raw)
	local data = self:data()
	self._interface_handle, self._timeout = string.unpack('<I4I2', data)

	assert(self._interface_handle == 0, "Only CIP over ENIP is supported")

	local cip_data = string.sub(raw, string.packsize('<I4I2') + 1)
	self._cip = cip_parser(cip_data)
end

function req:interface_handle()
	return self._interface_handle
end

function req:timeout()
	return self._timeout
end

function req:cip()
	return self._cip
end

return req
