local logger = require 'enip.logger'
local base = require 'enip.cip.segment.base'

local seg = base:subclass('enip.cip.segment.symbolic')

seg.static.EXT_FORMATS = {
	DOUBLE_BYTE_STRING = 0x01,
	TRIPLE_BYTE_STRING = 0x02,
	NUMBERIC = 0x06,
}

seg.static.NUMBERIC_TYPE = {
	USINT	= 0x06, -- UINT8
	UINT	= 0x07, -- UINT16
	UDINT	= 0x06, -- UINT32
}

function seg:initialize(val, ext_format, numeric_type)
	local fmt = 0
	local val = val
	if not ext_format then
		val = tostring(val or '') or ''
		fmt = string.len(val)
		assert(fmt <= 0x1F, "Symbolic characters length limition")
	else
		if ext_format ~= seg.static.EXT_FORMATS.NUMERIC then
			assert(string.len(val or '') <= 0x1F, "Symbolic characters length limition")
		else
			assert(numeric_type, "Numeric type is missing")
			assert(type(val) == 'number', "Numeric value needed")
		end
	end
	base.initialize(self, base.TYPES.SYMBOLIC, fmt)
	self._val = val
	self._ext_format = ext_format
	self._numeric_type = numeric_type
end

function seg:value()
	return self._val
end

function seg:ext_format()
	return self._ext_format
end

function seg:numeric_type()
	return self._numeric_type
end

function seg:encode()
	local raw = nil
	if self._ext_format then
		local fmt = (self._ext_format << 5)
		if self._ext_format == seg.static.EXT_FORMATS.NUMERIC then
			fmt = fmt + self._numeric_type
			if self._numeric_type == seg.static.NUMERIC_TYPE.USINT then
				raw = string.pack('<I1I1', fmt, self._val)
			end
			if self._numeric_type == seg.static.NUMERIC_TYPE.UINT then
				raw = string.pack('<I1I2', fmt, self._val)
			end
			if self._numeric_type == seg.static.NUMERIC_TYPE.UDINT then
				raw = string.pack('<I1I4', fmt, self._val)
			end
		else
			fmt = fmt + string.len(self._val)
			raw = string.pack('<I1', fmt)..self._val
		end
	else
		raw = self._val
	end

	logger.dump(self.name..'.encode', raw)

	return raw
end

function seg:decode(raw, index)
	local fmt = self:format()
	if fmt ~= 0 then
		self._ext_format = nil
		self._numeric_type = nil
		self._val, index = string.unpack('c'..fmt, raw, index)
	else
		local fmt, index = string.unpack('I1', raw, index)
		self._ext_format = (fmt >> 5) & 0x07
		if self._ext_format == seg.static.EXT_FORMATS.NUMERIC then
			self._numeric_type = fmt & 0x1F

			if self._numeric_type == seg.static.NUMERIC_TYPE.USINT then
				self._val, index = string.upack('I1', raw, index)
			end
			if self._numeric_type == seg.static.NUMERIC_TYPE.UINT then
				self._val, index = string.upack('I2', raw, index)
			end
			if self._numeric_type == seg.static.NUMERIC_TYPE.UDINT then
				self._val, index = string.upack('I4', raw, index)
			end
		else
			self._numeric_type = nil
			self._val, index = string.unpack('c'..(fmt & 0x1F), raw, index)
		end
	end

	logger.dump(self.name..'.decode', raw, index)

	return index
end

return seg
