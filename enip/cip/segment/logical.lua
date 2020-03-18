local class = require 'middleclass'
local base = require 'enip.cip.segment.base'

local logical = class('ENIP_CIP_SEGMENT_LOGICAL', base)

logical.static.TYPES =  {
	CLASS_ID			= 0x0,
	INSTANCE_ID			= 0x1,
	MEMBER_ID			= 0x2,
	CONNECTION_POINT	= 0x3,
	ATTRIBUTE_ID		= 0x4,
	SPECIAL				= 0x5,
	SERVCIE_ID			= 0x6,
	RESERVED			= 0x7
}

logical.static.FORMATS = {
	USINT		= 0x0, -- 8-bit
	UINT		= 0x1, -- 16-bit
	UDINT		= 0x2, -- 32-bit
	RESERVED	= 0x3, -- Reserved
}

function logical:initialize(logical_type, logical_fmt, value)
	local fmt = (logical_type << 2) + logical_fmt
	base.initialize(self, base.TYPES.LOGICAL, fmt)
	self._value = value
end

function logical:logical_type()
	local fmt = self:segment_format()
	return fmt >> 2
end

function logical:logical_format()
	local fmt = self:segment_format()
	return fmt & 0x03
end

function logical:value()
	return self._value
end

function logical:encode()
	local fmt = self:logical_format()
	if fmt == logical.static.FORMATS.USINT then
		return string.pack('<I1', self._value)
	end
	if fmt == logical.static.FORMATS.UINT then
		return string.pack('<I2', self._value)
	end
	if fmt == logical.static.FORMATS.UDINT then
		return string.pack('<I3', self._value)
	end
end

function logical:decode(raw, index)
	local fmt = self:logical_format()
	if fmt == logical.static.FORMATS.USINT then
		self._value, index = string.unpack('<I1', raw, index)
	end
	if fmt == logical.static.FORMATS.UINT then
		self._value, index = string.unpack('<I2', raw, index)
	end
	if fmt == logical.static.FORMATS.UDINT then
		self._value, index = string.unpack('<I2', raw, index)
	end

	return index
end

return logical
