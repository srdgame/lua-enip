local class = require 'middleclass'
local base = require 'enip.cip.request.base'
local types = require 'enip.cip.types'

local req = class('ENIP_CLIENT_SERVICES_READ_TAG', base)

function req:initialize(path, count, offset)
	base.initialize(self, types.SERVICES.READ_FRG, path)
	self._count = count
	self._offset = offset
end

function req:encode()
	assert(self._count, 'Count is missing')
	return string.pack('<I2I4', self._count, self._offset)
end

function req:decode(raw, index)
	self._count, self._offset, index = string.unpack('<I2I4', raw, index)
	return index
end

return req
