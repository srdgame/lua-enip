local types = require 'enip.cip.types'
local rp_error = require 'enip.cip.reply.error'

local service_to_object = {
	types.SERVICES.
}

return function(raw, index)
	local obj = nil
	local code, _, status, additional_status_size = string.unpack('<I1I1I1I1', raw, index)
	if status ~= types.STATUS.OK then
		obj = rp_error:new()
	else

	end

	return obj:from_hex(raw, index)
end
