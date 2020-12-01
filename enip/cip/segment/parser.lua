local base = require 'enip.cip.segment.base'


local function seg_type_to_string(seg_type)
	for k, v in pairs(base.TYPES) do
		if v == seg_type then
			return string.upper(k)
		end
	end
	return nil, 'Not found segment type'
end

local function find_seg_type(seg_type)
	local seg_type_str = assert(seg_type_to_string(seg_type))

	local r, m = pcall(require, 'enip.cip.segment.'..string.lower(seg_type_str))
	assert(r, string.format('Segment type %s[%02X] not found!', seg_type_str, seg_type))

	return m 
end

return function (raw, index)
	if _ENV.DEBUG_RAW then
		_ENV.DEBUG_RAW('segment.parser', string.sub(raw, index))
	end

	local index = index or 1
	local seg = string.unpack('<I1', raw, index)
	local seg_type, seg_fmt = base.parse(seg)
	assert(seg_type and seg_fmt, 'Invalid segment parsing')

	local m = find_seg_type_parser(seg_type)
	local val = m:new(fmt)

	return val, val:from_hex(raw, index)
end

