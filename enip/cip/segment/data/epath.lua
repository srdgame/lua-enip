local class = require 'middleclass'

local base = require 'enip.serializable'

local epath = class('enip.cip.segment.data.epath', base)

function epath:initialize(path)
	self._path = path
end

function epath:to_hex()
	local path_len = string.len(self._path)
	local data = string.pack('<I1', path_len)..self._path
	if path_len % 2 == 1 then
		data = data..'\0' --- Pading the string
	end
	return data
end

function epath:from_hex(raw, index)
	local path_len = string.unpack('<I1', raw)
	self._path = string.sub(raw, string.packsize('<I1') + 1, path_len)

	if path_len % 2 == 1 then
		index = index + 1 -- skip the padding zero
	end
	return index
end

function epath:path()
	return self._path
end

return epath
