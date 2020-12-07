local base = require 'enip.serializable'

local ansi = base:subclass('enip.cip.segment.data.ansi')

function ansi:initialize(symbol)
	base.initialize(self)
	self._symbol = symbol
end

function ansi:to_hex()
	local data = string.pack('s1', self._symbol)
	if string.len(self._symbol) % 2 == 1 then
		data = data..'\0' --- Pading the string
	end
	return data
end

function ansi:from_hex(raw, index)
	self._symbol, index = string.unpack('<s1', raw, index)

	if string.len(self._symbol) % 2 == 1 then
		index = index + 1 -- skip the padding zero
	end
	return index
end

function ansi:symbol()
	return self._symbol
end

return ansi
