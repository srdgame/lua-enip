local class = require 'middleclass'

local epath = class('LUA_ENIP_CIP_SEG_EPATH')

function epath:initialize(path)
	self._path = path
end

function epath:to_hex()
	--- 100 -- data seg
	--  10001 -- ANSI Extended Symbol Segment
	local seg = (0x80 | 0x11)
	local path_len = string.len(self._path)
	local data = string.pack('<I1I1', seg, path_len)..self._path
	if path_len % 2 == 1 then
		data = data..'\0' --- Pading the string
	end
	return data
end

function epath:from_hex(raw)
	local seg, path_len = string.unpack('<I1I1', raw)
	assert(seg == (0x80 | 0x11), 'Incorrect segment found!')
	self._path = string.sub(raw, string.packsize('<I1I1') + 1, path_len)
end

return epath
