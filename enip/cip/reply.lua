local class = require 'middleclass'

local types = require 'enip.cip.types'
local seg_parser = require 'enip.cip.segment.parser'

local reply = class('LUA_ENIP_CIP_REPLY')

function reply:initialize(service_code, status, data)
	self._code = service_code | types.SERVICES.REPLY
	self._status = status or -1
	self._data = data
end

function reply:service_code()
	return self._code & ( ~ types.SERVICES.REPLY)
end

function reply:status()
	return self._status
end

function reply:data()
	return self._data
end

function reply:to_hex()
	assert(self._status, 'status is missing')
	assert(self._data, 'data is missing')

	local data = self._data.to_hex and self._data:to_hex() or tostring(self._data)
	return string.pack('<I1I1I1I1', self._code, 0, self._status, 0)..data
end

function reply:from_hex(raw, index)
	local status_ex_size
	self._code, _, self._status, status_ex_size, index = string.unpack('<I1I1I1I1', raw, index)

	if status_ex_size == 0 then
		if self._status == types.STATUS.OK then
			self._data, index = seg_parser(raw, index)
		end
	else
		assert(nil, "Not support")
	end

	return index
end

return reply
