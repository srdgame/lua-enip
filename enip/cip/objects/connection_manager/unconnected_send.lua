local base = require 'enip.serializable'
local object_path = require 'enip.cip.segment.object_path'
local timing = require 'enip.cip.objects.connection_manager.connection_timing'

local req = base:subclass('enip.cip.objects.connection_manager.unconnected_send')

function req:initialize(connection_timing, request, route_path)
	base.initialize(self)
	self._connection_timing = connection_timing
	self._request = request
	self._route_path = route_path
end

function req:to_hex()
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

function req:from_hex(raw, index)
	self._connection_timing = timing:new()
	index = self._connection_timing:from(raw, index)

	local req_raw_len, index = string.unpack('<I2', raw, index)
	if req_raw_len % 2 == 1 then
		index = index + 1
	end
	self._request, index = parser(raw, index)

	local path_raw_size, _, index = string.unpack('I1I1', raw, index)
	self._route_path = object_path:new()

	return self._route_route:from_hex(raw, index)
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
