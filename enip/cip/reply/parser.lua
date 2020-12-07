local pfinder = require 'enip.utils.pfinder'
local types = require 'enip.cip.types'
local epath = require 'enip.cip.segment.epath'
local logical = require 'enip.cip.segment.logical'
local rp_error = require 'enip.cip.reply.error'

local common_service_finder = pfinder(types.SERVCIES, 'enip.cip.request')
local objects_finder = pfinder(types.OBJECT, 'enip.cip.objects')

local function search_service_parser(service_code, object_path)
	--- Try type object path
	local seg = object_path:segment(1)
	if not seg then
		return err
	end
	if not seg:isInstanceOf(logical) then
		return nil, "Object path is not logical"
	end
	if seg:sub_type() ~= logical.SUB_TYPES.CLASS_ID then
		return nil, "Logical node is an CLASS_ID type"
	end
	--- Loading types from objects.class_id.types
	local cparser, mpath = objects_finder(seg:value(), 'reply.parser')

	assert(type(cparser) == 'function')

	return cparser
end

return function(raw, index)

	local obj = nil
	local code, _, status, additional_status_size = string.unpack('<I1I1I1I1', raw, index)
	if status ~= types.STATUS.OK then
		obj = rp_error:new()
	else
		local mod = service_class_map[code & 0x7F]
		assert(mod, 'Service code is not supported. ['..string.format('%02X', code)..']')
		obj = mod:new()
	end

	index = obj:from_hex(raw, index)
	return obj, index
end
