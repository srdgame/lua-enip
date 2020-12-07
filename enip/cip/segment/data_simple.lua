local base = require 'enip.cip.segment.base'

local buildin = base:subclass('enip.cip.segment.data_simple')

local date_and_time = base.easy_create('enip.cip.segment.data_simple.date_and_time', {
	{ name = 'time_of_day', fmt = '<I4' },
	{ name = 'date', fmt = '<I2' },
})


local data_fmt_map = {
	UNKNOWN = '',
	BOOL	= {
		-- Boolean 0 - FALSE, 1 - TRUE
		encode = function(val)
			string.pack('<I1', val and 1 or 0)
		end,
		decode = function(raw, index)
			local val, index = string.unpack('<I1', raw, index)
			return val ~= 0, index
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
	STIME	= '<i4',
	DATE	= '<I2',
	TIME_OF_DAY		= '<I4', --- Time of day, milliseconds
	DATE_AND_TIME	= {
		encode = function(val)
			return date_and_time.to_hex(val)
		end,
		decode = function(raw, index)
			local val = date_and_time:new()
			index = val:from_hex(raw, index)
			self._val = val
			return index
		end,
	},
	STRING	= {
		encode = function(val)
			return string.pack('<s2', val)
		end,
		decode = function(raw, index)
			return string.unpack('<s2', raw, index)
		end
	},
	BYTE	= '<I1',
	WORD	= '<I2',
	DWORD	= '<I4',
	LWORD	= '<I8',
	STRING2 = {}, -- TODO:
	FTIME	= '<i4', ---- micro-seconds
	LTIME	= '<i8',
	ITIME	= '<i2',
	STRINGN = {}, -- TODO:
	SHORT_STRING = {
		encode = function(val)
			return string.pack('<s1', val)
		end,
		decode = function(raw, index)
			return string.unpack('<s1', raw, index)
		end
	},
	TIME	= '<i4', ---- milliseconds
	EPATH	= {
		encode = function(val)
			local epath = require 'enip.cip.segment.epath'
			local o = epath:new(val)
			return o:to_hex()
		end,
		decode = function(raw, index)
			local epath = require 'enip.cip.segment.epath'
			local o = epath:new(val)
			index = o:from_hex(raw, index)
			return o, index
		end
	},
	ENGUNIT = '<I2',
	STRINGI = {}, -- TODO:
}

buildin.static.FORMATS = {
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
	TIME_OF_DAY		= 14,
	DATE_AND_TIME	= 15,
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
	ENGUNIT = 29,
	STRINGI = 30,
}

local function get_format_parser(fmt)
	for k, v in pairs(build.static.FORMATS) do
		if v == tonumber(fmt) then
			return data_fmt_map[k]
		end
	end
end

function buildin:initialize(data_fmt)
	base.initialize(self, base.TYPES.DATA_SIMPLE, data_fmt)
end

function buildin:value()
	return nil
end

function buildin:encode()
end

function buildin:decode(raw, index)
	return index
end

function buildin:parser()
	local obj = self
	return {
		encode = function(val)
			local parser = get_format_parser(obj:format())
			assert(parser, 'Type is not supported!!!')
			if type(parser) == 'string' then
				return string.pack(parser, val)
			else
				return parser.encode(val)
			end
		end,
		decode = function(raw, index)
			obj._data_type = type_from_segment_fmt(obj:segment_format())
			local parser = get_format_parser(obj:format())
			assert(parser, 'Type is not supported!!!')
			if type(parser) == 'string' then
				return string.unpack(parser, raw, index)
			else
				return parser.decode(raw, index)
			end
		end
	}
end

return buildin
