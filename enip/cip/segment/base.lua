local class = require 'middleclass'
local serializable = require 'serializable'
local logger = require 'logger'

local seg = class('enip.cip.segment.base', serializable)

seg.static.TYPES = {
	PORT			= 0,
	LOGICAL			= 1,
	NETWORK			= 2,
	SYMBOLIC		= 3,
	DATA			= 4,
	DATA_DERIVED	= 5,
	DATA_SIMPLE		= 6,
	RESERVED		= 7,
}

seg.static.type_name = function(typ)
	for k, v in pairs(seg.static.TYPES) do
		if v == tonumber(typ) then
			return k
		end
	end
	return 'UNKNOWN'
end

local function parse_segment_type(raw, index)
	local tf, index = string.unpack('<I1', raw, index)
	local seg_type = ((segment & 0xE0) >> 5 ) & 0x07
	local seg_fmt = segment & 0x1F

	return seg_type, seg_fmt, index
end

local function encode_segment_type(type, format)
	local val = (((self._type & 0x07) << 5) & 0xE0) + self._fmt
	return string.pack('<I1', val)
end

seg.static.parse_segment_type = parse_segment_type
seg.static.encode_segment_type = encode_segment_type

seg.static.parse = function(raw, index)
	local seg_type, seg_fmt, index = parse_segment_type(raw, index)
	local type_name = seg.static.type_name(seg_type)

	local m = require 'enip.cip.segment.'..type_name
	if not m.static.parse then
		local o = m:new(seg_type, seg_fmt)
		index = o:from_hex(raw, index - 1)
		return o, index
	else
		return m.static.parse(raw, index)
	end
end

function seg:initialize(seg_type, seg_fmt)
	self._type = seg_type and (seg_type & 0x07) or -1
	self._fmt = seg_fmt and ((seg_fmt or 0) & 0x1F) or -1
end

function seg:__tostring()
	local val_str = tostring(self:value())
	return string.format('SEGMENT:\tTYPE:%d\tFMT:%d\tVALUE:%s',
		self._type, self._fmt, val_str)
end

function seg:to_hex()
	assert(self._type ~= -1, 'Invalid segment type')
	assert(self._fmt ~= -1, 'Invalid segment format')

	local s = string.pack('<I1', self:type_num())

	logger.dump(self.name..'.to_hex', s)

	return s..self:encode()
end

function seg:from_hex(raw, index)
	logger.dump(self.name..'.from_hex', raw, index)

	self._type, self._fmt, index = seg.static.parse_segment_type(raw, index)

	return self:decode(raw, index)
end

function seg:type()
	return self._type
end

function seg:format()
	return self._fmt
end

function seg:type_num()
	return (((self._type & 0x07) << 5) & 0xE0) + self._fmt
end

function seg:value()
	assert(nil, "Not implemented")
end

return seg
