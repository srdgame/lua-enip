local logger = require 'enip.logger'
local cip_types = require 'enip.cip.types'
local types = require 'enip.ab.types'
local base = require 'enip.cip.reply.base'
local segment = require 'enip.cip.segment.base'
local data_simple = require 'enip.cip.segment.data_simple'

local reply = base:subclass('enip.ab.reply.read_tag')

function reply:initialize(data_type, data, status, ext_status)
	base.initialize(self, types.SERVICES.READ_TAG, status, ext_status)
	if type(data_type) == 'number' then
		data_type = data_simple:new(data_type)
	end
	self._data_type = data_type
	self._data = data
end

function reply:encode()
	assert(self._data_type, 'Segment is missing')
	assert(self._data, 'Data is missing')

	local raw = {}
	local parser = self._data_type.parser()
	assert(parser, 'Segment needs to have parser if data exists')
	raw[#raw + 1] = self._data_type:to_hex()
	if (string.len(raw[#raw]) % 2) == 1 then
		raw[#raw + 1] = '\0' -- PAD
	end

	local data_raw = parser.encode(self._data)
	raw[#raw + 1] = data_raw
	if string.len(data_raw) % 2 == 1 then
		raw[#raw + 1] = '\0' -- PAD
	end

	return table.concat(raw)
end

function reply:decode(raw, index)
	logger.dump('ab.reply.read_tab.decode', raw)
	assert(self._status == cip_types.STATUS.OK)

	local pad
	local start = index or 1
	self._data_type, index = segment.parse(raw, index)
	assert(self._data_type, index)
	if (index - start) % 2 == 1 then
		pad, index = string.unpack('<I1', raw, index)
		assert(pad == 0, 'PAD must be zero')
	end

	assert(self._data_type.parser)
	start = index
	local parser = self._data_type:parser()
	self._data, index = parser.decode(raw, index)
	print(self._data)

	--- PAD
	if (index - start) % 2 == 1 then
		pad, index = string.unpack('I1', raw, index)
		assert(pad == 0, 'PAD must be zero')
	end

	return index
end

function reply:data_type()
	return self._data_type
end

function reply:data()
	return self._data
end

return reply
