local class = require 'middleclass'

local base = require 'enip.serializable'

local ansi = class('enip.cip.segment.data.ansi', base)

function ansi:initialize(symbol)
	self._symbol = symbol
end

function ansi:to_hex()
	local path_len = string.len(self.symbol)
	local data = string.pack('<I1', path_len)..self.symbol
	if path_len % 2 == 1 then
		data = data..'\0' --- Pading the string
	end
	return data
end

function ansi:from_hex(raw, index)
	local path_len = string.unpack('<I1', raw)
	self.symbol = string.sub(raw, string.packsize('<I1') + 1, path_len)

	if path_len % 2 == 1 then
		index = index + 1 -- skip the padding zero
	end
	return index
end

function ansi:symbol()
	return self.symbol
end

return ansi
