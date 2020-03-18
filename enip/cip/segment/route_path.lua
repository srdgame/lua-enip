local class = require 'middleclass'

local segment = require 'enip.cip.segment.base'

local path = class('LUA_ENIP_CIP_SEG_ROUTE_PATH', segment)

--- Current we only support numberic link
--
function path:initialize(port, link)
	local fmt = self:get_seg_fmt(port, link)
	segment.initialize(self, segment.TYPES.PORT, fmt)
	self._port = port
	self._link = link
end

function path:get_seg_fmt(port, link)
	if link > 0xFF then
		assert(nil, 'Link larger than 0xFF is not supprt')
	else
		return (port < 0x0F) and port or 0x0F
	end

end

function path:encode()
	if self._port > 0x0F then
		return string.pack('<I2I1', self._port, self._link)
	else
		return string.pack('<I1', self._link)
	end
end

function path:decode(raw, index)
	local seg_fmt = self:segment_format()

	if seg_fmt == 0x0F then
		self._port, self._link, index = string.unpack('<I2I1', raw, index)
	else
		self._port = seg_fmt
		self._link, index = string.unpack('<I1', raw, index)
	end
	return index
end

function path:port()
	return self._port
end

function path:link()
	return self._link
end

return path
