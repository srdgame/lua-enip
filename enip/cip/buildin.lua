local class = require 'middleclass'

local buildin = class('LUA_ENIP_CIP_BUILDIN_DATA_TYPES')


local types = {
	BOOL	= {
		-- Boolean 0 - FALSE, 1 - TRUE
		encode = function(val)
			string.pack('<I1', val and 1 or 0)
		end,
		decode = function(raw, index)
			local val, index = string.unpack('<I1', raw, index)
			return val == 1, index
		end
	}
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
	}
	STRING2 = {}, -- TODO:
	STRINGN = {}, -- TODO:
	SHORT_STRING = {
		encode = function(val)
			return string.pack('<s1', val)
		end,
		decode = function(raw, index)
			return string.unpack('<s1', raw, index)
		end
	}
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
	ENGUNITS = '<I4'
}

for k, v in pairs(types) do
	buildin.static.TYPES[k] = k
end

function buildin:intialize(data_type, val)
	self._data_type = data_type
	self._val = val
end

function buildin:value()
	return self._val
end

function buildin:to_hex()
	local type_i = types[self._data_type]
	assert(type_i, 'Type is not supported!!!')
	if type(type_i) == 'string' then
		return string.pack(type_i, self._val)
	else
		return type_i.encode(self._val)
	end
end

function buildin:from_hex(raw, index)
	local type_i = types[self._data_type]
	assert(type_i, 'Type is not supported!!!')
	if type(type_i) == 'string' then
		self._val, index = string.unpack(type_i, raw, index)
	else
		self._val, index = type_i.decode(raw, index)
	end
	return index
end

return buildin

