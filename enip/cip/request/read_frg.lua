local class = require 'middleclass'
local types = require 'enip.cip.types'
local logical = require 'enip.cip.segment.logical'
local obj_path = require 'enip.cip.segment.object_path'
local request_multi_pack = require 'enip.cip.request.common.multi_service_packet'

local base = require 'enip.cip.request.base'

local req = class('enip.cip.request.read_frg', base)

function req:initialize(priority, timeout_ticks, requests, route_path)
	assert(requests, 'Requests are required')
	assert(route_path, 'Route path is required')
	local path = obj_path.easy_create(types.OBJECT.CONNECTION_MANAGER, 0x01) --- Connection Manager: Instance #1

	base.initialize(self, types.SERVICES.READ_FRG, path)
	self._priority = priority or 5
	self._timeout_ticks = timeout_ticks or 157
	self._mr = request_multi_pack:new(requests)
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
		route_path = string.pack('<I1I1', 1, 0) .. self._route_path:to_hex()
	end

	return hdr..data..route_path
end

function req:decode(raw, index)
	assert(false, "not implemented")
	return index
end

function req:data()
	return self._mr
end

return req
