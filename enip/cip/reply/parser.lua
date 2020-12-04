local types = require 'enip.cip.types'
local rp_error = require 'enip.cip.reply.error'

local service_class_map = {
	[types.SERVICES.MULTI_SRV_PACK] = require 'enip.cip.reply.multi_srv_pack',
	[types.SERVICES.READ_TAG] = require 'enip.cip.reply.read_tag',
	[types.SERVICES.WRITE_TAG] = require 'enip.cip.reply.write_tag',
	[types.SERVICES.READ_FRG] = require 'enip.cip.reply.read_frg',
	--[types.SERVICES.WRITE_FRG] = require 'enip.cip.reply.write_frg',
}

return function(raw, index)
	--[[
	local basexx = require 'basexx'
	print(basexx.to_hex(string.sub(raw, index)))
	]]--

	local obj = nil
	local code, _, status, additional_status_size = string.unpack('<I1I1I1I1', raw, index)
	if status ~= types.STATUS.OK and (code & 0x7F) ~= types.SERVICES.MULTI_SRV_PACK then
		obj = rp_error:new()
	else
		local mod = service_class_map[code & 0x7F]
		assert(mod, 'Service code is not supported. ['..string.format('%02X', code)..']')
		obj = mod:new()
	end

	index = obj:from_hex(raw, index)
	return obj, index
end
