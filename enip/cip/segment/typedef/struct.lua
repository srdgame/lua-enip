local logger = require 'enip.logger'
local base = require 'enip.cip.segment.base'
local base = require 'enip.cip.segment.data_derived'

local formal = base:subclass('enip.cip.segment.typedef.formal')

function formal:initialize(attrs)
	base.initialize(self, base.FORMAT.STRUCT)
	self._attrs = attrs
end

function formal:value()
	return self._attrs
end

function formal:crc()
	-- TODO:
end

function formal:encode()
	local raw = {}
	for _, v in ipairs(self._attrs) do
		if type(v) == 'number' then
			raw[#raw + 1] = base.static.encode_segment_type(base.TYPES.DATA_SIMPLE, v)
		else
			assert(type(v) == 'table', 'Type attributes must be number or table')
			raw[#raw + 1] = v:to_hex()
		end
	end
	raw = table.concat(raw)

	logger.dump('encode', string.pack('s1', raw))

	return string.pack('s1', raw)
end

function formal:decode(raw, index)
	logger.dump('decode', raw, index)

	local len, index = string.unpack('<I1', raw, index)

	local attrs = {}
	while index < len do
		local seg, new_index = base.parse(raw, index)
		if seg:type() == base.TYPES.DATA_SIMPLE then
			attrs[#attrs + 1] = seg:format()
		elseif typ == base.TYPES.DATA_STRUCT then
			attrs[#attrs + 1] = seg
		else
			assert(nil, "Invalid segment type!!!")
		end
		index = new_index
	end

	self._attrs = attrs

	return index
end

return formal
