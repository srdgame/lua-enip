local class = require 'middleclass'
local types = require 'enip.cip.types'
local object_path = require 'enip.cip.segment.object_path'
local base = require 'enip.cip.request.base'

local mr = class('enip.cip.request.common.multi_service_packet', base)

function mr:initialize(object_path, requests)
	base.initialize(self, types.SERVICES.MULTI_SRV_PACK, object_path)
	self._requests = requests
end

function mr:requests()
	return self._requests
end

function mr:encode()
	assert(self._requests, 'Data is missing')

	local count = #self._requests -- Request Ojbect count
	local offsets = {}		-- Offset map
	local request_data = {}		-- Request Object data

	for _, v in ipairs(self._requests) do
		local data = v:to_hex()
		request_data[#request_data + 1] = data
		offsets[#offsets + 1] = string.len(data)
	end

	--- Create offset data map
	local data = {
		string.pack('<I2', count)
	}

	-- Base offset
	local offset = 2 * ( 1 + count)

	-- Update offsets
	for _, v in ipairs(offsets) do
		data[#data + 1] = string.pack('<I2', offset)
		offset = offset + v
	end

	return table.concat(data)..table.concat(request_data)
end

function mr:decode(raw, index)
	local start = index
	local count, index = string.unpack('<I2', raw, index)

	local offsets = {}
	for i = 1, count do
		local offset, index = string.unpack('<I2', raw, index)
		offsets[#offsets + 1] = offset
	end

	local requests = {}
	for i = 1, count do
		assert(offsets[i] >= index - start, 'Offset error!')

		if offsets[i] > index - start then
			logger.log('INFO', "Correct offset. i:%d index:%d start:%d offset[i]:%d",
				i, index, start, offset[i])
			index = start + offsets[i]
		end

		local req, index = parser(raw, index)
		requests[#requests + 1] = req
	end
	assert(offsets[count] >= index - start, 'Offset error!')

	return index
end

return mr
