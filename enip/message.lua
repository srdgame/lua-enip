
local class = require 'middleclass'
local header = require 'enip.header'

local msg = class('LUA_ENIP_MESSAGE')

msg.static.header = header

function msg:initailize(session, command, data, status)
	local data = data or ''
	local len = data.len and data:len() or string.len(data)
	self._data = data.to_hex and data:to_hex() or tostring(data)

	self._header = header:new(session, command, len, status)
end

function msg:__tostring()
	local basexx = require 'basexx'

	local hdr_str = tostring(self._header)
	return string.format('HDR:%s\nDATA:%s', hdr_str, basexx.to_hex(self._data))
end

function msg:from_hex(raw)
	self._header:from_hex(raw)
	local hdr_len = self._header:len()
	local data_len = self._header:length()
	self._data = string.sub(raw, hdr_len, hdr_len + data_len)
end

function msg:to_hex()
	return self._header:to_hex()..self._data
end

function msg:len()
	local hdr_len = self._header:len()
	local data_len = self._header:length()
	return hdr_len + data_len
end

function msg:data()
	return self._data
end

function msg:set_data(data)
	self._data = data
end

function msg:header()
	return self._header
end


return msg
