local base = require 'enip.cip.request.base'
local object_path = require 'enip.cip.segment.object_path'

local obj = base:subclass('enip.cip.object.request.base')

function obj:initialize(service_code, obj_type, obj_inst)
	local request_path = object_path.easy_create(obj_type, obj_inst)
	base.initialize(self, service_code, request_path)
end

function obj:object_type()
	local seg = self._path:segment(1)
	assert(seg and seg:type() == seg.TYPES.LOGICAL)
	assert(seg:sub_type() == seg.SUB_TYPES.CLASS_ID)
	return seg:value()
end

function obj:object_instance()
	local seg = self._path:segment(2)
	assert(seg and seg:type() == seg.TYPES.LOGICAL)
	assert(seg:sub_type() == seg.SUB_TYPES.CLASS_ID)
	return seg:value()
end

return obj
