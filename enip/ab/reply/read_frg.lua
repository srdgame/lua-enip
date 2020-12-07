local cip_types = require 'enip.cip.types'
local types = require 'enip.ab.types'
local segment = require 'enip.cip.segment.base'
local data_simple = require 'enip.cip.segment.data_simple'
local base = require 'enip.cip.reply.base'

local reply = base:subclass('enip.ab.reply.read_frg')

function reply:initialize(data_type, data, status, ext_status)
	base.initialize(self, types.SERVICES.READ_FRG, status, ext_status)
	if type(data_type) == 'number' then
		data_type = data_simple:new(data_type)
	end
	self._data_type = data_type
	self._data = data
end

local function encode_data(parser, data)
	local raw = {}
	for _, v in ipairs(data) do
		raw[#raw + 1] = parser.encode(v)
	end

	return table.concat(raw)
end

function reply:encode()
	assert(self._data_type, 'Segment is missing')

	local raw = {}
	local seg_raw = self._data_type:to_hex()
	raw[#raw + 1] = seg_raw
	if string.len(seg_raw) % 2 == 1 then
		raw[#raw + 1] = '\0' -- PAD
	end

	if self._data then
		local parser = self._data_type.parser()
		assert(parser, 'Data type needs to have parser if data exists')

		local data_raw = encode_data(parser, self._data)
		raw[#raw + 1] = data_raw

		if string.len(data_raw) % 2 == 1 then
			raw[#raw + 1] = '\0' -- PAD
		end
	end

	return table.concat(raw)
end

local function decode_data(parser, raw, index)
	local data = {}
	while index <= string.len(raw) do
		data[#data + 1], index = parser.decode(raw, index)
	end
	return data, index
end

function reply:decode(raw, index)
	assert(self._status == cip_types.STATUS.OK)
	local start = index or 1
	local pad
	self._data_type, index = segment.parse(raw, index)

	--- PAD
	if (index - start) % 2 == 1 then
		pad, index = string.unpack('I1', raw, index)
		assert(pad == 0, 'PAD has to be zero')
	end

	if self._data_type.parser then
		self._data, index = decode_data(raw, index)
	else
		assert(nil, "Data parser not found")
	end

	--- PAD
	if (index - start) % 2 == 1 then
		pad, index = string.unpack('I1', raw, index)
		assert(pad == 0, 'PAD has to be zero')
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
