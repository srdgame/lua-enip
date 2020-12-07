local logger = require 'enip.logger'
local pfinder = require 'enip.utils.pfinder'
local types = require 'enip.cip.types'
local epath = require 'enip.cip.segment.epath'
local logical = require 'enip.cip.segment.logical'

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
	local cparser, mpath = objects_finder(seg:value(), 'request.parser')

	assert(type(cparser) == 'function')

	return cparser
end

return function(raw, index)
	logger.dump('enip.cip.request.parser', raw, index)

	local code, path_len, path_index = string.unpack('<I1I1', raw, index)

	local code = code & 0x7F
	if code <= types.SERVCIES.MAX_COMMON_SERVICE then
		local mod, err = common_service_finder(code)
		if not mode then
			return nil, string.format('Common Service:[%02X] is not supported',  code, )
		end
		--- Common services requests
		local obj = mod:new()
		index = obj:from_hex(raw, index)
		return obj, index
	end
	--- Additional Common Services

	local path = epath:new()
	local path_raw = string.sub(raw, path_index, path_index + path_len * 2)
	path_index = path:from_hex(path_raw)
	assert(path_index == string.len(path_raw) + 1, "parser: EPATH decode error")

	local parser = search_service_parser(code & 0x7F, path)
	if not parser then
		return string.format('Service code[%02X] is not supported on path:%s',  code, tostring(path))
	end

	return parser(code, path, raw, index)
end
