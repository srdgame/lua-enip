local pfinder = require 'enip.utils.pfinder'
local types = require 'enip.cip.types'
local rp_error = require 'enip.cip.reply.error'
local objects_parser = require 'enip.cip.objects.reply.parser'

local common_service_finder = pfinder(types.SERVICES, 'enip.cip.reply')

return function(raw, index)
	local ext_status
	local code, _, status, ext_status_size, ext_index = string.unpack('<I1I1I1I1', raw, index)

	if status ~= types.STATUS.OK and ((code & 0x7F) ~= types.SERVICES.MULTI_SRV_PACK) then
		local err = rp_error:new(code, status)
		index = err:from_hex(raw, index)
		return err, index
	else
		--assert(status == types.STATUS.OK)
		code = code & 0x7F
		if code < types.SERVICES.MAX_COMMON_SERVICE then
			local mod, err = common_service_finder(code)
			if not mod then
				return nil, string.format('Service code [%02X] is not supported. error:', code)..err
			end

			local obj = mod:new()
			index = obj:from_hex(raw, index)
			return obj, index
		else
			return objects_parser(raw, index)
		end
	end
end
