local logger = require 'enip.logger'
local types = require 'enip.cip.types'
local base = require 'enip.cip.reply.base'

local mr = base:subclass('enip.cip.reply.multi_srv_pack')

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
		reply_data[#reply_data + 1] = data
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

function mr:decode(raw, index)
	local parser = require 'enip.cip.reply.parser' -- avoid require loop

	local start = index or 1
	local count, index = string.unpack('<I2', raw, index)

	local offsets = {}
	for i = 1, count do
		offsets[i], index = string.unpack('<I2', raw, index)
	end

	local replies = {}
	for i = 1, count do
		local offset = offsets[i] - (1 + count) * 2

		--print(i, index, start, offsets[i])

		assert(offsets[i] >= index - start, "Offset error!!!")
		if offsets[i] >= index - start then
			if (offsets[i] > index - start) then
				logger.log('WARN', "Correct offset. i:%d index:%d start:%d offset[i]:%d",
					i, index, start, offsets[i])
				index = start + offsets[i]
			end
		else
			logger.log('ERROR', "Incorrect offset found")
		end

		local data_len
		if i < count then
			data_len = offsets[i + 1] - offsets[i]
		end

		--logger.log('DEBUG', "Multi Service Pack: %02X %d", string.unpack('<I1', raw, index))
		local data, data_index = parser(raw, index, data_len)
		if not data then
			logger.log('ERROR', data_index)
		else
			replies[#replies + 1] = data
			index = data_index
		end
	end
	assert(offsets[count] <= index - start, "Offset error!!!")

	self._replies = replies
	return index
end

return mr
