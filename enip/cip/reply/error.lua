local class = require 'middleclass'

local types = require 'enip.cip.types'
local base = require 'enip.cip.reply.base'

local reply = class('enip.cip.reply.error', base)

function reply:initialize(service_code, status, error_code)
	base.initialize(self, service_code, status, 1)
	self._error_code = error_code
end

function reply:error_code()
	return self._error_code
end

function reply:encode()
	assert(self._error_code, 'Error code is missing')

	return string.pack('<I2', self._error_code)
end

function reply:decode(raw, index)
	assert(self:status() ~= types.STATUS.OK, 'Status must not be OK')
	assert(self:additional_status_size() <= 1, 'Only word status support for now')
	if self:additional_status_size() == 1 then
		self._error_code, index = string.unpack('<I2', raw, index)
	end

	return index
end

return reply
