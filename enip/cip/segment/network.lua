local base		= require 'enip.cip.segment.base'

local network = base:subclass('enip.cip.segment.network')

network.static.FORMATS = {
	RESERVED = 0x00, -- Reserved
	SCHEDULE = 0x01, -- Schedule Segment
	FIXED_TAG = 0x02, -- Fixed Tag Segment
	PRODUCTION_INHIBIT_TIME	= 0x03, -- Production Inhibit Time
	SAFETY = 0x10, -- Safety Segment
	EXTENDED = 0x1F, -- Extented Netowrk Segment
}

function network:initialize(format, val)
	base.initialize(self, base.TYPES.NETWORK, format)
	self._val = val
end

function network:value()
	return self._val
end

function network:encode()
	if self:format() < 0x10 then
		return string.pack('<I1', self._val)
	else
		if type(self._val) == 'table' then
			assert(self._val.to_hex, 'to_hex is missing!')
			return string.pack('<s1', self._val:to_hex())
		else
			return string.pack('<s1', tostring(self._val))
		end
	end
end

function network:decode(raw, index)
	local fmt = self:format()
	if fmt < 0x10 then
		self._val, index = string.unpack('<I1', raw, index)
	else
		self._val, index = string.unpack('<s1', raw, index)
		if fmt == network.static.FORMATS.EXTENDED then
			local extended = require 'enip.cip.segment.network.extended'
			local raw = self._val
			self._val = extended:new()
			self._val:from_hex(raw)
		end
	end
	return index
end

return network
