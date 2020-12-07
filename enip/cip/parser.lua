local types = require 'enip.cip.types'
local reply_parser = require 'enip.cip.reply.parser'
local request_parser = require 'enip.cip.request.parser'

---- Parser the cip message from raw to object
return function(raw, index)
	assert(raw, 'raw data is missing')

	local service_code = 0
	service_code = string.unpack('<I1', raw, index)
	if service_code & types.SERVICES.REPLY then
		return reply_parser(raw, index)
	else
		return request_parser(raw, index)
	end
end
