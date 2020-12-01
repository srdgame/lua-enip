local class = require 'middleclass'
local types = require 'enip.cip.types'
local logical = require 'enip.cip.segment.logical'

local mr = class('ENIP_CIP_REPLY_COMMON_MULTI_PACK')

function mr:initialize(replies)
	self._service_code = types.SERVICES.MULTI_SRV_PACK
	self._replies = replies
end

function mr:replies()
	return self._replies
end

function mr:to_hex()
	assert(self._service_code, 'Service code missing')
	assert(self._requests, 'Data is missing')

	local count = #self._requests
	local offsets = {}
	local request_data = {}
	for _, v in ipairs(self._requests) do
		local data = v:to_hex()
		request_data[#servcie_data] = data
		offsets[#offsets + 1] = string.len(data)
	end

	local data = {
		string.pack('<I2', count)
	}
	local offset = 2 * ( 1 + #offsets)
	for _, v in ipairs(offsets) do
		data[#data + 1] = string.pack('<I2', offset)
		offset = offset + v
	end

	return hdr..table.concat(data)..table.concat(request_data)
end

function mr:from_hex(raw, index)
	--[[
	local basexx = require 'basexx'
	print(basexx.to_hex(string.sub(raw, index)))
	]]--

	local parser = require 'enip.cip.reply.parser'

	local count = 0
	count, index = string.unpack('<I2', raw, index)

	local offsets = {}
	for i = 1, count do
		offsets[#offsets + 1], index = string.unpack('<I2', raw, index)
	end
	local base_index = index

	local replies = {}
	for i = 1, count do
		local offset = offsets[i] - (1 + count) * 2
		assert(offset >= index - base_index, "Offset error!!!")
		if offset > index - base_index then
			index = base_index + offset
		end

		local data = nil
		data, index = parser(raw, index)
		replies[#replies + 1] = data
	end
	self._replies = replies
end

return mr
