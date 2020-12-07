local types = require 'enip.cip.types'
local pfinder = require 'enip.utils.pfinder'
local logical = require 'enip.cip.segment.logical'
local epath = require 'enip.cip.segment.epath'

local finder = pfinder(types.OBJECT, 'enip.cip.objects')
local ofinders = {}

local function search_service_parser(service_code, object_path)
	--- Try type object path
	local seg = object_path:segment(1)
	if not seg then
		return nil, "Path segment empty!"
	end
	if not seg:isInstanceOf(logical) then
		return nil, "Object path is not logical"
	end
	if seg:sub_type() ~= logical.SUB_TYPES.CLASS_ID then
		return nil, "Logical node is an CLASS_ID type"
	end

	local object_id = seg:value()
	local otypes, err = finder(object_id, 'types')
	if not otypes then
		return nil, err
	end

	if not ofinders[object_id] then
		for k, v in pairs(types.OBJECT) do
			if v == object_id then
				ofinders[object_id] = pfinder(otypes.SERVICES, 'enip.cip.objects.'..string.lower(k)..'.reply')
			end
		end
		return nil, "Cannot find object class for id:"..object_id
	end

	local ofinder = ofinders[object_id]

	local mod, err = ofinder(service_code)
	if not mod then
		return nil, err
	end

	return mod
end

return function(raw, index)
	-- TODO: there is no path in response data, so we have to use request object
	local code, path_len, path_index = string.unpack('<I1I1', raw, index)

	code = code & 0x7F
	assert(code > types.SERVICES.MAX_COMMON_SERVICE, "Invalid service code")

	local path = epath:new()
	local path_raw = string.sub(raw, path_index, path_index + path_len * 2 - 1)
	path_index = path:from_hex(path_raw)
	assert(path_index == string.len(path_raw) + 1, "parser: EPATH decode error")

	local mod, err = search_service_parser(code, path)
	if not mod then
		return string.format('Service code[%02X] is not supported error:%s',  code, err)
	end

	local obj = mod:new()
	index = obj:from_hex(raw, index)

	return obj, index
end

