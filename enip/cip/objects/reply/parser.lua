local types = require 'enip.cip.types'
local pfinder = require 'enip.utils.pfinder'
local logical = require 'enip.cip.segment.logical'
local epath = require 'enip.cip.segment.epath'

local finder = pfinder(types.OBJECT, 'enip.cip.objects')
local ofinders = {}

local function search_service_parser(service_code, object_id)
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

return function(object_id, raw, index)
	code = code & 0x7F
	assert(code > types.SERVICES.MAX_COMMON_SERVICE, "Invalid service code")

	if type(object_id) == 'string' then
		for k, v in pairs(types.OBJECT) do
			if string.lower(k) == string.lower(object_id) then
				object_id = v
				break
			end
		end
		assert(nil, "Object type error")
	end

	local mod, err = search_service_parser(code, object_id)
	if not mod then
		return nil, string.format('Service code[%02X] is not supported error:%s',  code, err)
	end

	local obj = mod:new()
	index = obj:from_hex(raw, index)

	return obj, index
end

