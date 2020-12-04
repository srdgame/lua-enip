local class = require 'middleclass'
local logger = require 'enip.logger'
local types = require 'enip.cip.types'
local parser = require 'enip.cip.reply.parser'
local base = require 'enip.cip.reply.base'

local mr = class('enip.cip.reply.multi_srv_pack', base)

function mr:initialize(replies, status, ext_status)
	base.initialize(self, types.SERVICES.MULTI_SRV_PACK, status, ext_status)
	self._replies = replies
end

function mr:replies()
	return self._replies
end

function mr:encode()
	assert(self._requests, 'Data is missing')

	local count = #self._requests

	local offsets = {}
	local reply_data = {}
	for _, v in ipairs(self._requests) do
		local data = v:to_hex()
		reply_data[#servcie_data] = data
		offsets[#offsets + 1] = string.len(data)
	end

	local data = {
		string.pack('<I2', count)
	}

	local offset = 2 * ( 1 + count)
	for _, v in ipairs(offsets) do
		data[#data + 1] = string.pack('<I2', offset)
		offset = offset + v
	end

	return table.concat(data)..table.concat(reply_data)
end

function mr:from_hex(raw, index)
	local start = index
	local count = 0
	count, index = string.unpack('<I2', raw, index)

	local offsets = {}
	for i = 1, count do
		offsets[#offsets + 1], index = string.unpack('<I2', raw, index)
	end

	local replies = {}
	for i = 1, count do
		local offset = offsets[i] - (1 + count) * 2

		assert(offsets[i] >= index - start, "Offset error!!!")
		if offsets[i] > index - start then
			logger.log('INFO', "Correct offset. i:%d index:%d start:%d offset[i]:%d",
				i, index, start, offset[i])
			index = start + offsets[i]
		end

		local data, index = parser(raw, index)
		replies[#replies + 1] = data
	end
	assert(offsets[count] >= index - start, "Offset error!!!")

	self._replies = replies
end

return mr
