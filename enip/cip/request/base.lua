local class = require 'middleclass'
local serializable = require 'enip.serializable'
local epath = require 'encip.cip.segment.epath'

local req = class('enip.cip.request.base', base)

function req:initialize(service_code, request_path)
	self._service = service_code or -1
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
	return string.format(self.name..'\tService: %02X\tPath: %s',
		self._service, tostring(self._path))
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
