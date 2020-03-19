local class = require 'middleclass'

local types = require 'enip.cip.types'
local seg_parser = require 'enip.cip.segment.parser'

local reply = class('LUA_ENIP_CIP_REPLY')

function reply:initialize(service_code, status, additional_status_size)
	self._code = (service_code or 0) | types.SERVICES.REPLY
	self._status = status or -1
	self._additional_status_size = additional_status_size or 0
end

function reply:service_code()
	return self._code & ( ~ types.SERVICES.REPLY)
end

function reply:status()
	return self._status
end

function reply:additional_status_size()
	return self._additional_status_size
end

function reply:error_info()
	local sts = types.status_to_string(self._status)
	sts = sts or 'STATUS: 0x'..string.format('%02X', self._status)
	if self._additional_status then
		sts = sts..'. Additional status: 0x'..string.format('%04X', self._additional_status)
	end

	return sts
end

function reply:to_hex()
	assert(self._status, 'status is missing')

	local data = ''
	if self.encode then
		data = self:encode()
	end
	local ad_sts_size = self._additional_status_size
	return string.pack('<I1I1I1I1', self._code, 0, self._status, ad_sts_size)..data
end

function reply:from_hex(raw, index)
	local status_ex_size
	self._code, _, self._status, self._additional_status_size, index = string.unpack('<I1I1I1I1', raw, index)

	if self.decode then
		index = self:decode(raw, index)
	end

	return index
end

return reply
