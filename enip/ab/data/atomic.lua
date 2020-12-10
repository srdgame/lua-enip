local base = require 'enip.serializable'
local data_simple = require 'enip.cip.segment.data_simple'

local atomic = base:subclass('enip.ab.data.atomic')

function atomic:initialize(fmt)
	self._data_type = data_simple:new(fmt)
	self._bool_offset = 0
end

function atomic:to_hex()
	return self._data_type:to_hex()..'\0'
end

function atomic:from_hex(raw, index)
	index = self._data_type:from_hex(raw, index)
	local ex, index = string.unpack('<I1', raw, index)
	if self._data_type:format() == data_simple.FORMATS.BOOL then
		self._bool_offset = ex
	else
		assert(ex == 0, 'Atomic data type error')
	end

	return index
end

function atomic:parser()
	local data_type = self._data_type
	local bool_offset = self._bool_offset
	local parser = data_type:parser()
	return {
		encode = function(val)
			return parser.encode(val)
		end,
		decode = function(raw, index)
			if data_type:format() == data_simple.FORMATS then
				local val, index = string.unpack('<I1', raw, index)
				return val & (1 << bool_offset), index
			else
				return parser.decode(raw, index)
			end
		end,
	}
end

return atomic
