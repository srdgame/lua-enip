local class = require 'middleclass'

local segment = require 'enip.cip.segment.base'

local buildin = class('LUA_ENIP_CIP_BUILDIN_DATA_TYPES', segment)


local types = {
	UNKNOWN = '',
	BOOL	= {
		-- Boolean 0 - FALSE, 1 - TRUE
		encode = function(val)
			string.pack('<I1', val and 1 or 0)
		end,
		decode = function(raw, index)
			local val, index = string.unpack('<I1', raw, index)
			return val == 1, index
		end
	},
	SINT	= '<i1',
	INT		= '<i2', 
	DINT	= '<i4',
	LINT	= '<i8',
	USINT	= '<I1',
	UINT	= '<I2',
	UDINT	= '<I4',
	ULINT	= '<I8',
	REAL	= '<f',
	LREAL	= '<d',
	STIME	= {
		encode = function(val)
			assert(nil, "????")
		end,
		decode = function(raw, index)
			assert(nil, "?????")
		end
	},
	ITIME	= '<i2',
	TIME	= '<i4', ---- milliseconds
	FTIME	= '<i4', ---- micro-seconds
	LTIME	= '<i8',
	DATE	= '<I2',
	TOD		= '<I4', --- Time of day, milliseconds
	DT		= '',	--- TODO:
	STRING	= {
		encode = function(val)
			return val
		end,
		decode = function(raw, index)
			return string.sub(raw, index or 1), string.len(raw) - (index or 1) + 2
		end
	},
	STRING2 = {}, -- TODO:
	STRINGN = {}, -- TODO:
	SHORT_STRING = {
		encode = function(val)
			return string.pack('<s1', val)
		end,
		decode = function(raw, index)
			return string.unpack('<s1', raw, index)
		end
	},
	BYTE	= '<c1',
	WORD	= '<i2',
	DWORD	= '<i4',
	LWORD	= '<I8',
	EPATH	= {
		encode = function(val)
			local epath = require 'enip.cip.epth'
			local o = epath:new(val)
			return o:to_hex()
		end,
		decode = function(raw, index)
			local epath = require 'enip.cip.epth'
			local o = epath:new(val)
			local index = o:from_hex(raw, index)
			return o, index
		end
	},
	ENGUNITS = '<I4',
}

buildin.static.TYPES = {}
for k, v in pairs(types) do
	buildin.static.TYPES[k] = k
end

local segment_fmt_map = {
	UNKNOWN = 0,
	BOOL	= 1,
	SINT	= 2,
	INT		= 3,
	DINT	= 4,
	LINT	= 5,
	USINT	= 6,
	UINT	= 7,
	UDINT	= 8,
	ULINT	= 9,
	REAL	= 10,
	LREAL	= 11,
	STIME	= 12,
	DATE	= 13,
	TOD		= 14,
	DT		= 15,
	STRING	= 16,
	BYTE	= 17,
	WORD	= 18,
	DWORD	= 19,
	LWORD	= 20,
	STRING2 = 21,
	FTIME	= 22,
	LTIME	= 23,
	ITIME	= 24,
	EPATH	= 27,
	STRINGN = 26,
	TIME	= 27,
	EPATH	= 28,
	ENGUNITS = 29,
}

local function type_from_segment_fmt(seg_fmt)
	for k, v in pairs(segment_fmt_map) do
		if v == tonumber(seg_fmt) then
			return buildin.static.TYPES[k]
		end
	end
	return nil, "Not found type"
end

buildin.static.type_to_fmt = function(data_type)
	return segment_fmt_map[data_type]
end

function buildin:initialize(data_type, val)
	segment:initialize(segment.TYPES.DATA_E, segment_fmt_map[data_type])
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
