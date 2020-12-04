local base = require 'enip.serializable'

local extended = base:subclass('enip.cip.segment.network.extended')

function extended:initialize(ext_type, data)
	base.initialize(self)
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
