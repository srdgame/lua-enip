local class = require 'middleclass'
local types = require 'enip.cip.types'
local logical = require 'enip.cip.segment.logical'
local logical_path = require 'enip.cip.segment.logical_path'

local mr = class('ENIP_CIP_REQUEST_COMMON_MULTI_PACK')

function mr:initialize(requests)
	self._service_code = types.SERVICES.MULTI_SRV_PACK
	self._requests = requests
end

function mr:requests()
	return self._requests
end

function mr:to_hex()
	assert(self._service_code, 'Service code missing')
	assert(self._requests, 'Data is missing')

	local hdr_srv = string.pack('<I1I1', self._service_code, 0x02)
	local path = logical_path:new(0x02, 0x01)
	--[[
	local class_id = logical:new(logical.TYPES.CLASS_ID, logical.FORMATS.USINT, 0x02)
	local inst_id = logical:new(logical.TYPES.INSTANCE_ID, logical.FORMATS.USINT, 0x01)
	local hdr = hdr_srv..class_id:to_hex()..inst_id:to_hex()
	]]--
	local hdr = hdr_srv..path:to_hex()

	local count = #self._requests
	local offsets = {}
	local request_data = {}
	for _, v in ipairs(self._requests) do
		local data = v:to_hex()
		request_data[#request_data + 1] = data
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
	assert(nil, "Not implemented!")
end

return mr
