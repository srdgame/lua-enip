local class = require 'middleclass'
local msg = require 'enip.message'

--- UDP Only? List Identity
local req = class('LUA_ENIP_MSG_REQ_SEND_RR_DATA', msg)

function req:initialize(session, interface_handle, timeout, pack)
	self._interface_handle = interface_handle or 0
	self._timeout = timeout or 0
	local data = string.pack('<I4I2', self._interface_handle, self._timeout)
	self._pack = pack.to_hex and pack:to_hex() or tostring(pack)
	self._msg = msg:new(session, msg.header.CMD_REG_SESSION, data..pack_data)
end

function req:from_hex(raw)
	msg.from_hex(raw)
	local data = self:data()
	self._interface_handle, self._timeout = string.unpack('<I4I2', data)
	self._pack = string.sub(raw, string.packsize('<I4I2') + 1)
end

function req:interface_handle()
	return self._interface_handle
end

function req:timeout()
	return self._timeout
end

function req:pack()
	return self._pack
end

return req
