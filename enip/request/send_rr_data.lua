local base = require 'enip.command.base'
local command_data = require 'enip.command.data'

--- UDP Only? List Identity
local req = base:subclass('enip.request.send_rr_data')

--- For CIP over enip, the interface_handle must be 0
-- data is the packet object
function req:initialize(session, data, timeout) 
	base.initialize(self, session, base.COMMAND.SEND_RR_DATA)

	self._data = data
	self._interface_handle = 0 --- CIP 
	self._timeout = timeout or 0 --- Timeout settings (in seconds?)
end

function req:encode()
	local hdr = string.pack('<I4I2', self._interface_handle, self._timeout)
	return hdr..data:to_hex()
end

function req:decode(raw, index)
	self._interface_handle, self._timeout, index = string.unpack('<I4I2', raw, index)

	assert(self._interface_handle == 0, "Only CIP interface supported!!!")
	
	local data = command_data:new()
	index = data:from_hex(raw, index)
	self._data = data

	return index
end

function req:interface_handle()
	return self._interface_handle
end

function req:timeout()
	return self._timeout
end

function req:data()
	return self._data
end

return req
