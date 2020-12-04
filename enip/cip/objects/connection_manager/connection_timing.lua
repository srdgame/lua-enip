local class = require 'middleclass'
local base = require 'enip.serializable'

local obj = class('enip.cip.objects.connection_mananager.connection_timing', base)

function obj:initialize(tick_time, timeout)
	self._priority = 0 -- Normal
	self._tick_time = tick_time or 5
	self._timeout = (timeout or 157) & 0xFF
end

function obj:to_hex()
	local val = (self._priority & 0x01 << 4) + self._tick_time & 0x0F
	return string.pack('<I1I1', val, self._timeout)
end

function obj:from_hex(raw, index)
	local pt, timeout, index = string.unpack('<I1I1', raw, index)
	self._priority = (pt >> 4) & 0x01
	self._tick_time = pt & 0x0F
	self._timeout = timeout
	return index
end

function obj:priority()
	return self._priority
end

function obj:tick_time()
	return self._tick_time
end

function obj:timeout()
	return self._timeout
end

return obj
