local class = require 'middleclass'
--local seg_parser = require 'enip.cip.segment.parser'
local seg_path = require 'enip.cip.segment.path'

local req = class('LUA_ENIP_CIP_REQUEST_BASE')

function req:initialize(service_code, request_path)
	self._code = service_code
	if type(request_path) == 'string' then
		request_path = seg_path:new(request_path)
	end
	self._path = request_path
end

function req:__tostring()
	return string.format('CODE: %02X\tPATH: %s', self._code, tostring(self._path))
end

function req:to_hex()
	assert(self._path, "Path is missing")
	local path = self._path.to_hex and self._path:to_hex() or tostring(self._path)
	--local data = self._data.to_hex and self._data:to_hex() or tostring(self._data)
	local data = self.encode and self:encode() or ''
	return string.pack('<I1I1', self._code, string.len(path) // 2)..path..data
end

function req:from_hex(raw, index)
	local path_len = 0
	self._code, path_len, index = string.unpack('<I1I1', raw, index)
	
	path_len = path_len * 2
	local path = string.sub(raw, index, index + path_len)
	--local data, index = seg_parser(raw, index + path_len + 1)
	if self.decode then
		index = self:decode(raw, index + path_len + 1)
	end

	return index
end

return req
