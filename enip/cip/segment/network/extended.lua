local class = require 'middleclass'
local serializable = require 'enip.serializable'

local extended = class('enip.cip.segment.network.extended', serializable)

function extended:initialize(ext_type, data)
	self._ext_type = ext_type
	self._data = data
end

function extended:to_hex()
	return string.pack('<I2', self._ext_type)..self._data
end

function extended:from_hex(raw, index)
	self._ext_type, index = string.unpack('<I2', raw, index)
	self._data = string.sub(raw, index)
	return index + string.len(self._data)
end

return extended
