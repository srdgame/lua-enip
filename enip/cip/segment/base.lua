local class = require 'middleclass'

local seg = class('LUA_ENIP_CIP_SEGMENT')

seg.static.TYPES = {
	PORT		= 0,
	LOGICAL		= 1,
	NETWORK		= 2,
	SYMBOLIC	= 3,
	DATA		= 4,
	DATA_C		= 5,
	DATA_E		= 6,
	RESERVED	= 7,
}

seg.static.FORMATS = {
	SIMPLE		= 0x00, -- DATA Segment
	PATH		= 0x11, -- DATA Segment
}

seg.static.parse = function(segment)
	local seg_type = ((segment & 0xE0) >> 5 ) & 0x07
	local seg_fmt = segment & 0x1F

	return seg_type, seg_fmt
end

function seg:initialize(seg_type, seg_fmt)
	self._seg_type = seg_type and (seg_type & 0x07) or -1
	self._seg_fmt = seg_fmt and ((seg_fmt or 0) & 0x1F) or -1
end

function seg:__tostring()
	return string.format('DATA_E:\tTYPE:%d\tFMT:%d\tVALUE:%s', self._seg_type, self._seg_fmt, self:value())
end

function seg:to_hex()
	assert(self._seg_type ~= -1, 'Invalid segment type')
	assert(self._seg_fmt ~= -1, 'Invalid segment format')

	local sn = ((self._seg_type & 0x07) << 5) & 0xE0
	sn = sn + self._seg_fmt
	local s = string.pack('<I1', sn)

	return s..self:encode()
end

function seg:from_hex(raw, index)
	local sn = 0
	sn, index = string.unpack('<I1', raw, index)
	self._seg_type = ((sn & 0xE0) >> 5 ) & 0x07
	self._seg_fmt = sn & 0x1F

	return self:decode(raw, index)
end

function seg:segment_type()
	return self._seg_type
end

function seg:segment_format()
	return self._seg_fmt
end

function seg:type_num()
	return (((self._seg_type & 0x07) << 5) & 0xE0) + self._seg_fmt
end

function seg:value()
	assert(nil, "Not implemented")
end

return seg
