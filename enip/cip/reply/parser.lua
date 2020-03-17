local types = require 'enip.cip.types'
local rp_error = require 'enip.cip.reply.error'

local service_class_map = {
	types.SERVICES.MULTI_SRV_PACK = require 'enip.cip.reply.common.multi_service_packet',
	types.SERVICES.READ_TAG = require 'enip.cip.reply.read_tag',
	types.SERVICES.WRITE_TAG = require 'enip.cip.reply.write_tag',
	types.SERVICES.READ_FRG = require 'enip.cip.reply.read_frg',
	types.SERVICES.WRITE_FRG = require 'enip.cip.reply.write_frg',
}

return function(raw, index)
	local obj = nil
	local code, _, status, additional_status_size = string.unpack('<I1I1I1I1', raw, index)
	if status ~= types.STATUS.OK then
		obj = rp_error:new()
	else
		local mod = service_class_map[code]
		assert(mod, 'Service code is not supported. ['..code..']')
		obj = mod:new()
	end

	return obj:from_hex(raw, index)
end
