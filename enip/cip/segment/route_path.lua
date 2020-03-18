local class = require 'middleclass'

local segment = require 'enip.cip.segment.base'

local path = class('LUA_ENIP_CIP_SEG_ROUTE_PATH', segment)

function path:initialize(port, link)
	segment.initialize(self.segment.TYPES.DATA, segment.FORMATS.PATH)
	self._link = link
	self._port = port
end

function path:encode()
	local path_len = string.len(self._path)
	local data = string.pack('<I1', path_len)..self._path
	if path_len % 2 == 1 then
		data = data..'\0' --- Pading the string
	end
	return data
end

function path:decode(raw, index)
	local path_len = string.unpack('<I1', raw)
	self._path = string.sub(raw, string.packsize('<I1') + 1, path_len)

	if path_len % 2 == 1 then
		index = index + 1 -- the padding zero
	end
	return index
end

function path:value()
	return self._path
end

function path:path()
	return self._path
end

return path
