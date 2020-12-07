local logger = require 'enip.logger'
local pfinder = require 'enip.utils.pfinder'
local types = require 'enip.cip.types'
local objects_parser = require 'enip.cip.objects.request.parser'

local common_service_finder = pfinder(types.SERVCIES, 'enip.cip.request')

return function(raw, index)
	logger.dump('enip.cip.request.parser', raw, index)

	local code, path_len, path_index = string.unpack('<I1I1', raw, index)

	local code = code & 0x7F
	if code <= types.SERVCIES.MAX_COMMON_SERVICE then
		local mod, err = common_service_finder(code)
		if not mode then
			return nil, string.format('Common Service:[%02X] is not supported',  code, err)
		end
		--- Common services requests
		local obj = mod:new()
		index = obj:from_hex(raw, index)
		return obj, index
	end
	--- Additional Common Services

	return objects_parser(raw, index)
end
