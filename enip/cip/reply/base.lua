--- Message Router Reply format
--
local base = require 'enip.serializable'
local basexx = require 'basexx'

local types = require 'enip.cip.types'

local reply = base:subclass('enip.cip.reply.base')

function reply:initialize(service_code, status, ext_status)
	base.initialize(self)
	self._service = (service_code or 0) | types.SERVICES.REPLY
	self._status = status or 0
	self._ext_status = ext_status or {}
end

function reply:encode()
	assert(nil, "Not implemented")
end

function reply:decode(raw, index)
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
	if #self._ext_status > 0 then
		sts = sts..'. Additional status: '
		for _, v in ipairs(self._ext_status) do
			sts = sts..string.format('0x%02X', v)
		end
	end

	return sts
end

function reply:to_hex()
	assert(self._status, 'status is missing')

	local ext_size = #self._ext_status
	local hdr = string.pack('<I1I1I1I1', self._service, 0, self._status, ext_size)
	if ext_size > 0 then
		local ext = {}
		for _, v in ipairs(self._ext_status) do
			ext[#ext + 1] = string.pack('<I2', v)
		end
		hdr = hdr .. table.concat(ext)
	end

	return hdr..self:encode()
end

function reply:from_hex(raw, index)
	local ex_size, _
	self._service, _, self._status, ex_size, index = string.unpack('<I1I1I1I1', raw, index)

	self._ext_status = {}
	if ex_size > 0 then
		local ext = {}
		for i = 1, ex_size do
			ext[#ext + 1], index = string.unpack('<I2', raw, index)
		end
		self._ext_status = ext
	end

	return self:decode(raw, index)
end

return reply
