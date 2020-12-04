local base = require 'enip.serializable'

local data = base:subclass('enip.cpi.segment.data.simple')

function data:initialize(data, parser)
	base.initialize(self)
	self._data = data
	self._parser = parser
end

function data:to_hex()
	assert(self._data, 'Data missing')
	local data_raw = self._data.to_hex and self._data:to_hex() or tostring(self._data)

	local data_len = string.len(data_raw)
	if data_len % 2 == 1 then
		data_len = data_len // 2 + 1
		return string.pack('<I1', data_len)..data_raw..'\0'
	else
		return string.pack('<I1', data_len // 2)..data_raw
	end
end

function data:from_hex(raw, index)
	local data_len = 0
	data_len, index = string.unpack('<I1', raw, index)

	self._data = string.sub(raw, index, index + data_len)
	if self._parser then
		self._data = self._parser(self._data)
	end

	return index + data_len + 1
end

function data:data()
	return self._data
end

function data:paser()
	return self._parser
end

return data
