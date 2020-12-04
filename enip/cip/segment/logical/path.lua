local base = require 'enip.serializable'
local logical = require 'enip.cip.segment.logical'

--- TODO: Delete this as we have epath class

local path = base:subclass('ENIP_CIP_SEGMENT_LOGICAL_PATH')

function path:initialize(class_id, instance_id)
	if class_id then
		self._class_id = logical:new(logical.TYPES.CLASS_ID, logical.FORMATS.USINT, class_id)
	end
	if instance_id then
		self._instance_id = logical:new(logical.TYPES.INSTANCE_ID, logical.FORMATS.USINT, instance_id)
	end
end

function path:class_id()
	return self._class_id
end

function path:instance_id()
	return self._instance_id
end

function path:to_hex()
	assert(self._class_id and self._instance_id, 'Class or Instance ID missing')
	return self._class_id:to_hex() .. self._instance_id:to_hex()
end

function path:from_hex(raw, index)
	self._class_id = logical:new(logical.TYPES.CLASS_ID, logical.FORMATS.USINT, 0)
	self._instance_id = logical:new(logical.TYPES.INSTANCE_ID, logical.FORMATS.USINT, 0)
	index = self._class_id:from_hex(raw, index)
	index = self._instance_id:from_hex(raw, index)
	return index
end

return path 
