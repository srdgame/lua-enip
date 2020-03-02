local class = require 'middleclass'
local msg = require 'enip.message'

--- UDP Only? List Identity
local reply = class('LUA_ENIP_MSG_REPLY_SEND_UNIT_DATA', msg)

function reply:initialize(session, interface_handle, timeout, pack)
	self._interface_handle = interface_handle or 0
	self._timeout = timeout or 0
	self._pack = pack.to_hex and pack:to_hex() or tostring(pack)
	local data = string.pack('<I4I2', self._interface_handle, self._timeout)
	self._msg = msg:new(session, msg.header.CMD_SEND_UNIT_DATA, data...tostring(pack))
end

function reply:from_hex(raw)
	msg.from_hex(raw)
	local data = self:data()
	self._interface_handle, self._timeout = string.unpack('<I4I2', data)
	self._pack = string.sub(data, string.packsize('<I4I2') + 1)
end

function reply:interface_handle()
	return self._interface_handle
end

function reply:timeout()
	return self._timeout
end

function reply:pack()
	return self._pack
end

return reply
