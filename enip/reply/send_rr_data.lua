local command = require 'enip.command.base'
local command_data = require 'enip.command.data'

--- UDP Only? List Identity
local reply = command:subclass('enip.reply.send_rr_data')

function reply:initialize(session, data, timeout)
	command.initialize(self, session, command.COMMAND.SEND_RR_DATA)

	self._data = data
	self._interface_handle = 0 --- CIP Interface
	self._timeout = timeout or 0
end

function reply:encode()
	local data = self._data

	local data_1 = string.pack('<I4I2', self._interface_handle, self._timeout)
	local data_2 = data.to_hex and data:to_hex() or tostring(data)
	return data_1..data_2
end

function reply:decode(raw, index)
	--[[
	local basexx = require 'basexx'
	print(index, basexx.to_hex(string.sub(raw, index)))
	]]--

	self._interface_handle, self._timeout, index = string.unpack('<I4I2', raw, index)
	--print(self._interface_handle, self._timeout)

	assert(self._interface_handle == 0, "Only CIP interface supported!!!")
	
	local data = command_data:new()
	index = data:from_hex(raw, index)
	self._data = data

	return index
end

function reply:interface_handle()
	return self._interface_handle
end

function reply:timeout()
	return self._timeout
end

function reply:data()
	return self._data
end

return reply
