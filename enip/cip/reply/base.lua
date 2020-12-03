local class = require 'middleclass'

local types = require 'enip.cip.types'
local seg_parser = require 'enip.cip.segment.parser'

local reply = class('enip.cip.reply.base')

function reply:initialize(service_code, status, ext_status)
	self._service = (service_code or 0) | types.SERVICES.REPLY
	self._status = status or 0
	self._ext_status = ext_status or ''
end

function reply:encode()
	assert(nil, "Not implemented")
end

function reply:decode()
	assert(nil, "Not implemented")
end

function reply:service()
	return self._service & ( ~ types.SERVICES.REPLY)
end

function reply:status()
	return self._status
end

function reply:ext_status()
	return self._ext_status
end

function reply:error_info()
	local sts = types.status_to_string(self._status)
	sts = sts or 'STATUS: 0x'..string.format('%02X', self._status)
	if self._ext_status then
		sts = sts..'. Additional status: 0x'..string.format('%04X', self._ext_status)
	end

	return sts
end

function reply:to_hex()
	assert(self._status, 'status is missing')

	local ext_size = string.len(self._ext_status) // 2
	local hdr = string.pack('<I1I1I1I1', self._service, 0, self._status, ext_size)
	if ext_size > 0 then
		hdr = hdr .. self._ext_status
	end

	return hdr..self:encode()
end

function reply:from_hex(raw, index)
	local ex_size = 0
	self._service, _, self._status, ex_size, index = string.unpack('<I1I1I1I1', raw, index)

	if ex_size > 0 then
		ex_size = ex_size * 2
		self._ext_status = string.sub(raw, index, index + ex_size )
		index = index + ex_size
	else
		self._ext_status = ''
	end

	return self:decode(raw, index)
end

return reply
