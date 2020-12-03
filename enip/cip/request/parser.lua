local types = require 'enip.cip.types'
local logger = require 'enip.logger'

local service_class_map = {
	[types.SERVICES.MULTI_SRV_PACK] = require 'enip.cip.request.common.multi_service_packet',
	[types.SERVICES.READ_TAG] = require 'enip.cip.request.read_tag',
	[types.SERVICES.WRITE_TAG] = require 'enip.cip.request.write_tag',
	[types.SERVICES.READ_FRG] = require 'enip.cip.request.read_frg',
	--[types.SERVICES.WRITE_FRG] = require 'enip.cip.request.write_frg',
}

return function(raw, index)
	logger.dump('enip.cip.request.parser', raw, index)

	local code = string.unpack('<I1', raw, index)
	local mod = service_class_map[code & 0x7F]
	assert(mod, 'Service code is not supported. ['..string.format('%02X', code)..']')

	local obj = mod:new()
	index = obj:from_hex(raw, index)

	return obj, index
end
