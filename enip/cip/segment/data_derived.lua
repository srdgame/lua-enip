local pfinder = require 'enip.utils.pfinder'
local base = require 'enip.cip.segment.base'

local seg = base:subclass('enip.cip.segment.data_derived')

seg.static.FORMATS = {
	ABB_STRUCT	= 0x00,
	ABB_ARRAY	= 0x01,
	STRUCT		= 0x02,
	ARRAY		= 0x03,
}

local finder = pfinder(seg.static.FORMATS, 'enip.cip.segment.typedef')

seg.static.parse = function(raw, index)
	local seg_type, seg_fmt, index = base.static.parse_segment_type(raw, index)
	assert(seg_type == base.TYPES.DATA_DERIVED, "Invalid segment type!")

	local m, err = finder(tonumber(seg_fmt))
	assert(m, err)

	local o = m:new()
	index = o:from_hex(raw, index - 1)
	return o, index
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
