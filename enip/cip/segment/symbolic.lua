local class = require 'middleclass'

local base = require 'enip.cip.segment.base'

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

function buildin:data_type()
	return self._data_type
end

function buildin:data_type_fmt()
	return segment_fmt_map[self._data_type]
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
	self._data_type = type_from_segment_fmt(self:segment_format())

	local pre = 0
	pre, index = string.unpack('<I1', raw, index)
	assert(pre == 0, 'following must be zeor in buildin types')

	local type_i = types[self._data_type]
	assert(type_i, 'Type is not supported!!!')
	if type(type_i) == 'string' then
		self._val, index = string.unpack(type_i, raw, index)
	else
		self._val, index = type_i.decode(raw, index)
	end

	-- print('DATA_E', self._val)

	return index
end

return buildin
