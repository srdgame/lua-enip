local base = require 'enip.cip.segment.base'
local buildin = require 'enip.cip.segment.buildin'
local path = require 'enip.cip.segment.path'
local simple = require 'enip.cip.segment.simple'

local parser_map = {}

parser_map.PORT = function(fmt, raw, index)
end

parser_map.LOGICAL = function(fmt, raw, index)
end

parser_map.NETWORK = function(fmt, raw, index)
	assert(nil, 'NETWORK not implmented')
end

parser_map.SYMBOLIC = function(fmt, raw, index)
	assert(nil, 'SYMBOLIC not implmented')
end

parser_map.DATA = function(fmt, raw, index)
	if fmt == 0x11 then
		local p = path:new()
		index = p:from_hex(raw, index)
		return index
	end
	if fmt == 0x00 then
		-- Simple Data Segement
		local p = simple:new()
		index = p:from_hex(raw, index)
	end
	print('DATA')
end

parser_map.DATA_C = function(fmt, raw, index)
	assert(nil, 'DATA_C not implemented')
end

parser_map.DATA_E = function(fmt, raw, index)
	local val = buildin:new(fmt)
	index = val:from_hex(raw, index)
	return val, index
end

parser_map.RESERVED = function(fmt, raw, index)
	assert(nil, 'RESERVED!!!!')
end

local function seg_type_to_string(seg_type)
	for k, v in pairs(base.TYPES) do
		if v == seg_type then
			return string.upper(k)
		end
	end
	return nil, 'Not found segment type'
end

return function (raw, index)
	--[[
	local basexx = require 'basexx'
	print(basexx.to_hex(string.sub(raw, index)))
	]]--

	local index = index or 1
	local seg = string.unpack('<I1', raw, index)
	local seg_type, seg_fmt = base.parse(seg)
	assert(seg_type and seg_fmt, 'Invalid segment parsing')

	local seg_type_str = assert(seg_type_to_string(seg_type))
	local parser = parser_map[seg_type_str]

	assert(parser, string.format('Segment type %s[%02X] not found!', seg_type_str, seg_type))

	return parser(seg_fmt, raw, index)
end

