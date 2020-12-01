local class		= require 'middleclass'
local base		= require 'enip.cip.segment.base'
local path		= require 'enip.cip.segment.path'
local simple	= require 'enip.cip.segment.simple'

local seg = class('LUA_ENIP_CIP_SEGMENT_DATA', base)

seg.static.FORMATS = {
	SIMPLE		= 0x00, -- DATA Segment
	PATH		= 0x11, -- DATA Segment
}

function buildin:initialize(data_type, val)
	segment.initialize(self, segment.TYPES.DATA_E, segment_fmt_map[data_type])
	self._data_type = data_type
	self._val = val
end

function buildin:value()
	return self._val
end

function buildin:encode()
	local pre = string.pack('<I1', 0)
	local type_i = types[self._data_type]
	assert(type_i, 'Type is not supported!!!')
	if type(type_i) == 'string' then
		return pre..string.pack(type_i, self._val)
	else
		return pre..type_i.encode(self._val)
	end
end

function buildin:decode(raw, index)
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
	return index
end

return buildin
