local pfinder = require 'enip.utils.pfinder'
local types = require 'enip.cip.objects.message_router.types'

local finder = pfinder(types.SERVICES, 'enip.cip.objects.message_router.reply')

return function(service_code, object_path, raw, index)
	local mod, err = finder(service_code)
	if not mode then
		return nil, err
	end

	local obj = mod:new()
	index = obj:from_hex(raw, index)

	return obj, index
end

