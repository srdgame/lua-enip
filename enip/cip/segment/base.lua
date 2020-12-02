local class = require 'middleclass'
local serializable = require 'serializable'
local logger = require 'logger'

local seg = class('enip.cip.segment.base', serializable)

seg.static.TYPES = {
	PORT		= 0,
	LOGICAL		= 1,
	NETWORK		= 2,
	SYMBOLIC	= 3,
	DATA		= 4,
	DATA_STRUCT	= 5,
	DATA_SIMPLE	= 6,
	RESERVED	= 7,
}

seg.static.parse = function(segment)
	local seg_type = ((segment & 0xE0) >> 5 ) & 0x07
	local seg_fmt = segment & 0x1F

	return seg_type, seg_fmt
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

	local sn = ((self._type & 0x07) << 5) & 0xE0
	sn = sn + self._fmt
	local s = string.pack('<I1', sn)

	logger.dump(self.name..'.to_hex', s)

	return s..self:encode()
end

function seg:from_hex(raw, index)
	local sn = 0
	sn, index = string.unpack('<I1', raw, index)
	self._type = ((sn & 0xE0) >> 5 ) & 0x07
	self._fmt = sn & 0x1F

	logger.dump(self.name..'.from_hex', raw, index)

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
