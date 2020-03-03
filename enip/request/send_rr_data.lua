local class = require 'middleclass'
local msg = require 'enip.message'
local command_parser = require 'enip.commmand.parser'

--- UDP Only? List Identity
local req = class('LUA_ENIP_MSG_REQ_SEND_RR_DATA', msg)

--- For CIP over enip, the interface_handle must be 0
-- data for command specific data
function req:initialize(session, data, timeout) 
	self._data = data
	self._interface_handle = 0 --- CIP 
	self._timeout = timeout or 0 --- Timeout settings (in seconds?)

	local data_1 = string.pack('<I4I2', self._interface_handle, self._timeout)
	local data_2 = data.to_hex and data:to_hex() or tostring(data)

	self._msg = msg:new(session, msg.header.CMD_REG_SESSION, data1..data2)
end

function req:from_hex(raw, index)
	local index = msg:from_hex(raw, index)
	local data_raw = self:data()
	self._interface_handle, self._timeout = string.unpack('<I4I2', data)

	assert(self._interface_handle == 0, "Only CIP interface supported!!!")
	
	local cip_data = string.sub(raw, string.packsize('<I4I2') + 1)
	self._cip = command_parser(cip_data)
end

function req:interface_handle()
	return self._interface_handle
end

function req:timeout()
	return self._timeout
end

function req:command()
	return self._cip
end

return req
