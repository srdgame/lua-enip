local segments = {
	'PORT',
	'LOGICAL',
	'NETWORK',
	'SYMBOLIC',
	'DATA',
	'DATA_TYPE_C',
	'DATA_TYPE_E',
	'RESERVED',
}

local function get_segment(seg)
	local sn = string.byte(seg)
	sn = (sn & 0xE0) >> 5

	return segs[sn]
end

local parser_map = {}

parser_map.PORT = function(raw, index)
end

paser_map.LOGICAL = function(raw, index)
end

paser_map.NETWORK = function(raw, index)
end

paser_map.SYMBOLIC = function(raw, index)
end

paser_map.DATA = function(raw, index)
end

paser_map.DATA_TYPE_C = function(raw, index)
end

paser_map.DATA_TYPE_E = function(raw, index)
end

paser_map.RESERVED = function(raw, index)
	assert(nil, 'RESERVED!!!!')
end

---- Parser the cip message from raw to object
return function(raw, index)
	local index = index or 1
	local seg = string.sub(raw, index, index + 1)
	local seg_type = get_segment(seg)
	local parser = parser_map[seg_type]
	assert(parser, 'Unknown segment type found!')

	return parser(raw, index + 1)
end
