local class = require 'middleclass'
local base = require 'enip.cip.segment.base'

local logical = class('enip.cip.segment.logical', base)

logical.static.SUB_TYPES =  {
	CLASS_ID			= 0x0,
	INSTANCE_ID			= 0x1,
	MEMBER_ID			= 0x2,
	CONNECTION_POINT	= 0x3,
	ATTRIBUTE_ID		= 0x4,
	SPECIAL				= 0x5,
	SERVICE_ID			= 0x6,
	RESERVED			= 0x7
}

logical.static.FORMATS = {
	USINT		= 0x0, -- 8-bit
	UINT		= 0x1, -- 16-bit
	UDINT		= 0x2, -- 32-bit
	RESERVED	= 0x3, -- Reserved
}

function logical:initialize(logical_type, logical_fmt, value, pad)
	local fmt = (logical_type << 2) + logical_fmt
	--- Validation
	if logical_fmt == logical.static.FORMATS.UDINT then
		assert(logical_type == logical.static.SUB_TYPES.INSTANCE_ID
			or logical_type == logical.static.SUB_TYPES_CONNECTION_POINT)
	end
	if logical_type == logical.static.SUB_TYPES.SERVICE_ID then
		-- Only 8-Bit Service ID Segment defined in specs
		assert(logical_fmt == logical.static.FORMATS.USINT)
	end
	if logical_type == logical.static.SUB_TYPES.SERVICE_ID then
		-- Only Electronic Key Segment defined in specs
		assert(logical_fmt == logical.static.FORMATS.USINT)
	end

	base.initialize(self, base.TYPES.LOGICAL, fmt)
	self._value = value
	self._pad = pad
end

function logical:sub_type()
	local fmt = self:format()
	return fmt >> 2
end

function logical:value_format()
	local fmt = self:format()
	return fmt & 0x03
end

function logical:pad()
	return self._pad
end

function logical:set_pad(pad)
	self._pad = pad
end

function logical:value()
	return self._value
end

function logical:set_value(val)
	self._value = val
end

function logical:encode()
	local raw = nil
	local fmt = self:value_format()
	if fmt == logical.static.FORMATS.USINT then
		raw = string.pack('<I1', self._value)
	end
	if fmt == logical.static.FORMATS.UINT then
		raw = string.pack('<I2', self._value)
	end
	if fmt == logical.static.FORMATS.UDINT then
		raw = string.pack('<I4', self._value)
	end
	if self._pad then
		if string.len(raw) % 2 == 0 then
			raw = '\0'..raw
		end
	end
	return raw
end

function logical:decode(raw, index)
	local index = index or 1
	local fmt = self:value_format()
	if fmt == logical.static.FORMATS.USINT then
		self._value, index = string.unpack('<I1', raw, index)
	end
	if fmt == logical.static.FORMATS.UINT then
		index = self._pad and index + 1 or index
		self._value, index = string.unpack('<I2', raw, index)
	end
	if fmt == logical.static.FORMATS.UDINT then
		index = self._pad and index + 1 or index
		self._value, index = string.unpack('<I4', raw, index)
	end

	return index
end

return logical
