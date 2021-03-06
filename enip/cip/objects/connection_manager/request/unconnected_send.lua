local parser = require 'enip.cip.request.parser'
local cip_types = require 'enip.cip.types'
local object_path = require 'enip.cip.segment.object_path'
local base = require 'enip.cip.objects.request.base'
local types = require 'enip.cip.objects.connection_manager.types'
local timing = require 'enip.cip.objects.connection_manager.connection_timing'

local req = base:subclass('enip.cip.objects.connection_manager.unconnected_send')

function req:initialize(instance, connection_timing, request, route_path)
	local instance = instance or 0
	base.initialize(self, types.SERVICES.UNCONNECTED_SEND, cip_types.OBJECT.CONNECTION_MANAGER, instance)
	self._connection_timing = connection_timing
	self._request = request
	self._route_path = route_path
end

function req:encode()
	assert(self._request, "Request is missing")
	local data = {}
	-- Header
	data[#data + 1] = self._connection_timing:to_hex()

	-- Message Request
	local req_raw = self._request:to_hex()
	local req_raw_len = string.len(req_raw)
	data[#data + 1] = string.pack('<I2', req_raw_len)
	data[#data + 1] = req_raw
	if req_raw_len % 2 == 1 then
		data[#data + 1] = '\0'
	end

	-- Route Path
	local path_raw = self._route_path:to_hex()
	local path_raw_size = string.len(path_raw) // 2
	data[#data + 1] = string.pack('<I1I1', path_raw_size, 0)
	data[#data + 1] = path_raw

	return table.concat(data)
end

function req:decode(raw, index)
	self._connection_timing = timing:new()
	index = self._connection_timing:from(raw, index)

	local req_raw_len, index = string.unpack('<I2', raw, index)
	local data_raw = string.sub(raw, index, index + req_raw_len - 1)
	local request, req_index = parser(data_raw)
	assert(req_index == req_raw_len + 1, "Data decode error!")

	self._request = request
	index = index + req_raw_len
	if req_raw_len % 2 == 1 then
		index = index + 1 --- Skip PAD
	end

	local path_raw_size, _, index = string.unpack('I1I1', raw, index)
	local path_raw = string.sub(raw, index, index + path_raw_size * 2 - 1)
	self._route_path = object_path:new()
	local path_index = self._route_path:from_hex(path_raw)
	assert(path_index == path_raw_size * 2 + 1, "Route path decode error!")

	return index + path_raw_size * 2
end

function req:connection_timing()
	return self._connection_timing
end

function req:request()
	return self._request
end

function req:route_path()
	return self._route_path
end

return req
