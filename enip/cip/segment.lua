local class = require 'middleclass'

local seg = class('LUA_ENIP_CIP_SEGMENT')

function seg:initialize(seg_type, seg_fmt)
	self._seg_type = seg_type & 0x07
	self._seg_fmt = seg_fmt & 0x1F
end

function seg:to_hex()
	local sn = ((seg_type & 0x07) << 5) & 0xE0
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

return seg
