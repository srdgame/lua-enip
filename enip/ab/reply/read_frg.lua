local logger = require 'enip.logger'
local cip_types = require 'enip.cip.types'
local base = require 'enip.cip.reply.base'
local types = require 'enip.ab.types'
local atomic = require 'enip.ab.data.atomic'

local reply = base:subclass('enip.ab.reply.read_frg')

function reply:initialize(tag_type, values, status, ext_status)
	base.initialize(self, types.SERVICES.READ_FRG, status, ext_status)
	if type(tag_type) == 'number' then
		tag_type = atomic:new(tag_type)
	end
	self._tag_type = tag_type or atomic:new()
	if type(values) ~= 'table' then
		self._values = {values}
	else
		self._values = values or {}
	end
end

function reply:encode()
	assert(self._tag_type, 'Segment is missing')
	assert(#self._values, 'Data is missing')

	local raw = {}
	--- Encode the Data Type first
	raw[#raw + 1] = self._tag_type:to_hex()

	local parser = self._tag_type:parser()
	assert(parser, 'Tag type parser missing')

	for _, v in ipairs(self._values) do
		local data_raw = parser.encode(v)
		raw[#raw + 1] = data_raw
	end

	return table.concat(raw)
end

function reply:decode(raw, index)
	logger.dump('ab.reply.read_frg.decode', string.sub(raw, index))
	assert(self._status == cip_types.STATUS.OK)

	index = self._tag_type:from_hex(raw, index)

	local start = index
	local parser = self._tag_type:parser()
	assert(parser, 'Tag type parser missing')

	self._values = {}
	while index <= string.len(raw) do
		local data, data_index = parser.decode(raw, index)
		if data ~= nil then
			table.insert(self._values, data)
			index = data_index
		else
			print(data_index)
			-- TODO: ERROR
		end
	end

	return index
end

function reply:tag_type()
	return self._tag_type
end

function reply:value(index)
	return self._values(index)
end

function reply:values()
	return self._values
end

return reply
