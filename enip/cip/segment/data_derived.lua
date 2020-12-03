local class = require 'middleclass'
local base = require 'enip.cip.segment.base'

local seg = class('enip.cip.segment.data_derived', base)

seg.static.FORMATS = {
	ABB_STRUCT	= 0x00,
	ABB_ARRAY	= 0x01,
	STRUCT		= 0x02,
	ARRAY		= 0x03,
}

seg.static.parse = function(raw, index)
	local seg_type, seg_fmt, index = base.static.parse_segment_type(raw, index)
	assert(seg_type == base.TYPES.DATA_DERIVED, "Invalid segment type!")

	for k, v in pairs(seg.static.FORMATS) do
		if v == tonumber(seg_fmt) then
			local r, m = pcall(require, 'enip.cip.segment.typedef.'..string.lower(k))
			assert(r, m)
			local o = m:new()
			index = o:from_hex(raw, index - 1)
			return o, index
		end
	end

	assert(nil, "Invalid format!!!")
end

function seg:initialize(fmt)
	base.initialize(self, base.TYPES.DATA_DERIVED, fmt)
end

function seg:parse_value(raw, index)
	assert(nil, "Not implemented")
end

function seg:crc()
	assert(nil, "Not implemented")
end

return seg
