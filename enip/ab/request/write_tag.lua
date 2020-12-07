local types = require 'enip.ab.types'
local segment = require 'enip.cip.segment.base'
local data_simple = require 'enip.cip.segment.data_simple'
local base = require 'enip.cip.request.base'

local req = base:subclass('enip.ab.request.write_tag')

function req:initialize(path, data_type, data)
	base.initialize(self, types.SERVICES.WRITE_TAG, path)
	if type(data_type) == 'number' then
		data_type = data_simple:new(data_type)
	end
	self._segment = data_type
	self._data = data
end

function req:encode()
	assert(self._segment, 'Data type is missing')
	assert(self._data, 'Value is missing')

	local raw = {}
	local seg_raw = self._segment:to_hex()
	raw[#raw + 1] = seg_raw
	if string.len(seg_raw) % 2 == 1 then
		raw[#raw + 1] = '\0' -- PAD
	end

	if self._data then
		local parser = self._segment.parser()
		assert(parser, 'Segment needs to have parser if data exists')

		raw[#raw + 1] = string.pack('<I1I1', 1, 0) -- Number of element to write (has to be 1???)

		local data_raw = parser.encode(self._data)
		raw[#raw + 1] = data_raw
		if string.len(data_raw) % 2 == 1 then
			raw[#raw + 1] = '\0' -- PAD
		end
	end

	return table.concat(raw)
end

function req:decode(raw, index)
	local start = index or 1
	self._segment, index = segment.parse(raw, index)

	--- PAD
	if (index - start) % 2 == 1 then
		local pad, index = string.unpack('I1', raw, index)
		assert(pad == 0, 'PAD has to be zero')
	end

	if self._segment.parser then
		local count, pad = string.unpack('<I1I1', raw, index)
		assert(count == 1, pad == 0)

		local parser = self._segment.parser()
		self._data, index = parser.decode(raw, index)
	end

	--- PAD
	if (index - start) % 2 == 1 then
		local pad, index = string.unpack('I1', raw, index)
		assert(pad == 0, 'PAD has to be zero')
	end

	return index
end

return req
