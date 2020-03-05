local types = require 'enip.cip.types'
local buildin = require 'enip.cip.buildin'
local epath = require 'enip.cip.epath'

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
	local sn = (seg & 0xE0) >> 5
	return segments[seg], seg & 0xE0
end

local parser_map = {}

parser_map.PORT = function(fmt, raw, index)
end

parser_map.LOGICAL = function(fmt, raw, index)
end

parser_map.NETWORK = function(fmt, raw, index)
	print('NETWORK')
end

parser_map.SYMBOLIC = function(fmt, raw, index)
	print('SYMBOLIC')
end

parser_map.DATA = function(fmt, raw, index)
	if fmt == 0x11 then
		local p = epath:new()
		index = p:from_hex(raw, index)
		return index
	end
	if fmt == 0x00 then
		-- Simple Data Segement
		local 
	end
	print('DATA')
end

parser_map.DATA_TYPE_C = function(fmt, raw, index)
	local val = buildin:new(fmt)
	index = val:from_hex(raw, index)
	return val, index
end

parser_map.DATA_TYPE_E = function(fmt, raw, index)
	print('DATA_TYPE_E')
end

parser_map.RESERVED = function(fmt, raw, index)
	assert(nil, 'RESERVED!!!!')
end

return function (raw, index)
	local index = index or 1
	local seg = string.unpack('<I1', raw, index)
	local seg_type, seg_fmt = get_segment(seg)
	local parser = parser_map[seg_type]

	assert(parser, 'Unknown segment type found!')

	return parser(seg_fmt, raw, index + 1)
end

