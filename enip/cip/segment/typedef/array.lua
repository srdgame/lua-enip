local logger = require 'enip.logger'
local base = require 'enip.cip.segment.data_derived'
local simple = require 'enip.cip.segment.data_simple'

local array = base:subclass('enip.cip.segment.typedef.array')

function array:initialize(low, high, unit)
	base.initialize(self, base.FORMAT.ARRAY)
	self._dimension = {
		low = low,
		high = high,
		unit = unit
	}
end

function array:value()
	return self._dimension
end

function array:crc()
	-- TODO:
end

local function encode_dimension(tag, bound)
	assert(bound >= 0, "Dimension Bound must be bigger than zero!")
	if bound <= 0xFF then
		return string.pack('<I1I1I1', tag, 1, bound)
	end
	if bound <= 0xFFFF then
		return string.pack('<I1I1I2', tag, 2, bound)
	end
	return string.pack('<I1I1I4', tag, 4, bound)
end

function array:encode()
	local raw = {}
	raw[#raw + 1] = encode_dimension(0x80, self._dimension.low)
	raw[#raw + 1] = encode_dimension(0x81, self._dimension.high)
	if type(self._dimension.unit) == 'number' then
		raw[#raw + 1] = seg_base.static.encode_segment_type(seg_base.TYPES.DATA_SIMPLE, v)
	else
		assert(type(v) == 'table', 'Type attributes must be number or table')
		raw[#raw + 1] = v:to_hex()
	end

	raw = table.concat(raw)

	logger.dump(self.name..'.encode', string.pack('s1', raw))

	return string.pack('s1', raw)
end

local function decode_dimension(tag, raw, index)
	local t, len, index = string.unpack('<I1I1', index)
	assert(t == tag, "Bound Tag not match!")
	local bound, index = string.unpack('<I'..len, raw, index)
	return bound, index
end

function array:decode(raw, index)
	logger.dump(self.name..'.decode', raw, index)

	local org_index = index or 1
	local len, index = string.unpack('<I1', raw, index)

	local dimension = {}
	dimension.low, index = decode_dimension(0x80, raw, index)
	dimension.high, index = decode_dimension(0x81, raw, index)
	local seg = seg_base.parse(raw, index)
	if seg:type() == seg_base.TYPES.DATA_SIMPLE then
		dimension.unit = seg:format()
	elseif typ == seg_base.TYPES.DATA_STRUCT then
		dimension.unit = seg
	else
		assert(nil, "Invalid segment type!!!")
	end

	assert(index - org_index == len, "Array decode error!!")
	self._dimension = dimension

	return index
end

return array
