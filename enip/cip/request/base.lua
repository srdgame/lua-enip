--- Message Router Request format
--
local base = require 'enip.serializable'
local epath = require 'enip.cip.segment.epath'

local req = base:subclass('enip.cip.request.base')

function req:initialize(service_code, request_path)
	base.initialize(self)
	self._service = service_code
	if not request_path then
		return
	end

	if type(request_path) == 'string' then
		request_path = epath:new(request_path)
	end
	self._path = request_path
end

function req:service()
	return self._service
end

function req:path()
	return self._path
end

function req:__tostring()
	return string.format('Service: %02X\tPath: %s',
		self._service, tostring(self._path or "NIL"))
end

function req:data()
	assert(nil, "Not Implemented")
end

function req:encode()
	assert(nil, "Not Implemented")
end

function req:decode(raw, index)
	assert(nil, "Not Implemented")
end

function req:to_hex()
	assert(self._service, "Service code is missing")
	assert(self._path, "Path is missing")

	local path_raw = self._path:to_hex()
	assert(string.len(path_raw) % 2 == 0)
	local path_len = string.len(path_raw) // 2

	local hdr = string.pack('<I1I1', self._service, path_len)

	local data_raw = self:encode()

	return hdr..path_raw..data_raw
end

function req:from_hex(raw, index)
	local path_len = 0
	self._service, path_len, index = string.unpack('<I1I1', raw, index)

	local path = epath:new()

	local path_raw = string.sub(raw, index, index + path_len * 2)
	index = index + path_len * 2
	local path_index = path:from_hex(path_raw)
	assert(path_index == index, "EPATH decode error")

	self._path = path

	return self:decode(raw, index)
end

return req
