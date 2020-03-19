local types = require 'enip.cip.types'
--local request = require 'enip.cip.request'
--local reply = require 'enip.cip.reply'
local reply_parser = require 'enip.cip.reply.parser'

local services_req_map = {
	[types.SERVICES.READ_TAG] = require 'enip.cip.request.read_tag',
	[types.SERVICES.WRITE_TAG] = require 'enip.cip.request.write_tag',
}

---- Parser the cip message from raw to object
return function(raw, index)
	assert(raw, 'raw data is missing')

	--[[
	local basexx = require 'basexx'
	print(basexx.to_hex(string.sub(raw, index)))
	]]--

	local service_code = 0
	service_code = string.unpack('<I1', raw, index)
	if service_code & types.SERVICES.REPLY then
		return reply_parser(raw, index)
	else
		--local req = request:new(service_code)
		local req_class = services_req_map[service_code]
		assert(req_class, 'Service code is not supported')
		local req = req_class:new()
		index = req:from_hex(raw, index)
		return req, index
	end
end
