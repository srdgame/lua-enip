local class = require 'middleclass'

local req = class('LUA_ENIP_CIP_MSG_ROUTER_REQUEST')

function req:initialize(service_code, request_path, request_data)
	self._code = service_code
	self._path = request_path
	self._data = request_data
end

local function encode_path(path)

end

local function decode_path(raw)
end

function req:to_hex()
	local path = self._path.to_hex and self._path:to_hex() or tostring(self._path)
	local data = self._data.to_hex and self._data:to_hex() or tostring(data)
	return string.pack('<I1I1', self._code, string.len(path) // 2)..path..data
end

function req:from_hex(raw)
	local path_len = 0
	self._code, path_len = string.unpack('<I1I1', raw)
	
	path_len = path_len * 2
	local path_begin = string.packsize('<I1I1') + 1
	local path = string.sub(raw, path_begin, path_begin + path_len)
	self._data = string.sub(raw, path_begin + path_len + 1)
end

return cpf
