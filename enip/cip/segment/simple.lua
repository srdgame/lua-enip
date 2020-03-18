local class = require 'middleclass'

local segment = require 'enip.cip.segment.base'

local data = class('LUA_ENIP_CIP_SEG_SIMPLE_DATA', segment)

function data:initialize(data, parser)
	segment.initialize(self, segment.TYPES.DATA, segment.FORMATS.SIMPLE)
	self._data = data
	self._parser = parser
end

function data:encode()
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

function data:decode(raw, index)
	local data_len = 0
	data_len, index = string.unpack('<I1', raw, index)

	self._data = string.sub(raw, index, index + data_len)
	if self._parser then
		self._data = self._parser(self._data)
	end

	return index + data_len + 1
end

function data:value()
	return self._data
end

return data
