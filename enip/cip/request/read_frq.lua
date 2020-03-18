local class = require 'middleclass'
local base = require 'enip.cip.request.base'
local types = require 'enip.cip.types'
local seg_path = require 'enip.cip.segment.path'
local logical_path = require 'enip.cip.segment.logical_path'

local req = class('ENIP_CLIENT_SERVICES_READ_TAG_FRQ', base)

function req:initialize(priority, timeout_ticks, multi_request, route_path)
	local path = logical_path:new(0x06, 0x01) -- 0x06: Connection Manager Class
	base:initialize(types.SERVICES.READ_TAG, path)
	self._priority = priority or 5
	self._timeout_ticks = timeout_ticks or 157
	self._mr = multi_request
	self._route_path = route_path or nil
end

function req:encode()
	local data = self._mr.to_hex and self._mr:to_hex() or tostring(self._mr)
	local data_len = string.len(data)
	if data_len % 2 == 1 then
		data = data..'\0'
	end
	local hdr = string.pack('<I1I1I2', self._priority, self._timeout_ticks, data_len)
	local route_path = ''
	if self._route_path then
		route_path = seg_path:new(self._route_path):to_hex()
	end

	return hdr..data..route_path
end

function req:decode(raw, index)
	assert(false, "not implemented")
	return index
end

return req
