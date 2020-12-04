local base = require 'enip.serializable'

local nc = base:subclass('enip.cip.objects.connection_mananager.network_connection')

nc.static.PRIORITY = {
	LOW			= 0x00,
	HIGH		= 0x01,
	SCHEDULED	= 0x02,
	URGENT		= 0x03,
}

nc.static.CONNECTION_TYPE = {
	NULL			= 0x00,
	MULTICAST		= 0x01,
	POINT_TO_POINT	= 0x02,
	RESERVED		= 0x03,
}

function nc:initialize(redundant_owner, connection_type, priority, fix_or_variable, connection_size, w32)
	base.initialize(self)
	self._redundant_owner = redundant_owner
	self._connection_type = connection_type
	self._priority = priority
	self._fix_or_vairable = fix_or_variable
	self._connection_size connection_size
	self._w32 = w32
end

function nc:to_hex()
	local hdr = (self._redundant_owner and 1 or 0) << 15
		+ (self._connection_type & 0x03) << 13
		+ (self._priority & 0x03) << 10
		+ (self._fix_or_variable and 0 or 1) << 9
	if self._w32 then
		return string.pack('<I4', (hdr << 16) + (self._connection_size & 0x0FF))
	else
		return string.pack('<I2', hdr + (self._connection_size & 0xF))
	end
end

function nc:from_hex(raw, index)
	local hdr, index = string.unpack('<I2', raw, index)
	self._redundant_owner = (hdr >> 16) == 1 and true or false
	self._connection_type = (hdr >> 13) & 0x03
	self._priority = (hdr >> 10) & 0x03
	self._fix_or_variable = ((hdr >> 9) & 0x01) == 0 and true or false
	self._connection_size = hdr & 0x0F
	if self._connection_size == 0 then
		self._connection_size, index = string.unpack('<I2', raw, index)
	end
	return index
end

function nc:redundant_owner()
	return self._redundant_owner
end

function nc:connection_type()
	return self._connection_type
end

function nc:priority()
	return self._priority
end

function nc:fix_or_variable()
	return self._fix_or_variable
end

function nc:connection_size()
	return self._connection_size
end

return nc
