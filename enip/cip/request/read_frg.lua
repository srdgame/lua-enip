local class = require 'middleclass'
local types = require 'enip.cip.types'

local base = require 'enip.cip.request.base'

local req = class('enip.cip.request.read_frg', base)

--- 
-- Initialize constuctor
-- path: EPATH
function req:initialize(path, count, offset)
	base.initialize(self, types.SERVICES.READ_FRG, path)
	self._count = count
	self._offset = offset
end

function req:encode()
	return string.pack('I2I4', self._count, self._offset)
end

function req:decode(raw, index)
	self._count, self._offset, index = string.unpack('I2I4', raw, index)
	return index
end

function req:count()
	return self._count
end

function req:offset()
	return self._offset
end

return req
