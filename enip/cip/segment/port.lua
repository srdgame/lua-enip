local logger = require 'enip.logger'
local base = require 'enip.cip.segment.base'

local port = base:subclass('enip.cip.segment.port')

function port:initialize(port, link)
	local port, port_ext = self:get_port_value(port)
	local link, link_ext_size = self:get_link_value(port, link)

	-- Generrate Port Segment Format
	local fmt = ((link_ext_size > 0) and 0x10 or 0x00) + port & 0x0F

	base.initialize(self, base.TYPES.PORT, fmt)
	self._port = port
	self._port_ext = port_ext
	self._link = link
	self._link_ext_size = link_ext_size
end

function port:get_port_value(port)
	local port = port or 0
	if port < 0x0F then
		return port, nil
	end
	return 0x0F, port
end

function port:get_link_value(link)
	if type(link) == 'number' and link <= 0xFF then
		return link, 0
	end
	return tostring(link), string.len(link)
end

function port:encode()
	local raw = nil
	if self._link_ext_size == 0 then
		if self._port_ext then
			-- Extended Port Identifier (2 Bytes) + Link Address
			raw = string.pack('<I2I1', self._port_ext, self._link)
		else
			-- No Extended Port, just Link Address
			raw = string.pack('<I1', self._link)
		end
	else
		if self._port_ext then
			-- Link Address Size (1 Byte) + Extended Port Identifier (2 Bytes) + Link Address
			raw = string.pack('<I1I2', self._link_ext_size, self._port_ext)..self._link
		else
			raw = string.pack('<I1', self._link_ext_size, self._port)..self._link
		end
		--- Pad byte
		if self._link_ext_size % 2 == 1 then
			raw = raw..'\0'
		end
	end

	logger.dump(self.name..'.encode', raw)
	
	return raw
end

function port:decode(raw, index)
	local fmt = self:format()

	logger.dump(self.name..'.decode', raw, index)

	self._port = fmt & 0x0F
	self._port_ext = nil

	if (fmt < 0x10) then
		if self._port == 0x0F then
			self._port_ext, self._link, index = string.unpack('<I2I1', raw, index)
		else
			self._link, index = string.unpack('<I1', raw, index)
		end
	else
		self._link_ext_size, index = string.unpack('<I1', raw, index)
		if self._port == 0x0F then
			self._port_ext, self._link, index = string.unpack('<I2c'..self._link_ext_size, raw, index)
		else
			self._link, index = string.unpack('<c'..self._link_ext_size, raw, index)
		end
		if self._link_ext_size % 2 == 1 then
			index = index + 1 -- Pad byte
		end
	end

	return index
end

function port:port()
	return self._port_ext and self._port_ext or self._port
end

function port:link()
	return self._link
end

return port
