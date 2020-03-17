local class = require 'middleclass'
local types = require 'enip.cip.types'
local logical = require 'enip.cip.segment.logical'

local mr = class('ENIP_CIP_MESSAGE_REQUEST')

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
	local count = 0
	count, index = string.unpack('<I2', raw, index)

	local offsets = {}
	for i = 1, count do
		offsets[#offset + 1], index = string.unpack('<I2', raw, index)
	end

	local data = {}
	for i = 1, count do
		data[#data], index = parser(raw, index)	
	end
end

return mr
