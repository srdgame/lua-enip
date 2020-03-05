local types = require 'enip.cip.types'
local request = require 'enip.cip.request'
local reply = require 'enip.cip.reply'

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
		local rep = reply:new(service_code)
		index = rep:from_hex(raw, index)
		return rep, index
	else
		local req = request:new(service_code)
		index = req:from_hex(raw, index)
		return req, index
	end
end
