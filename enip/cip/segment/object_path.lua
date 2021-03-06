--- Segment Definition Hierarchy
--

--- TODO: Encoded Path Shortcut Rules is not supported yet

local logger = require 'enip.logger'
local base = require 'enip.serializable'
local seg_base = require 'enip.cip.segment.base'
local logical = require 'enip.cip.segment.logical'
local symbolic = require 'enip.cip.segment.symbolic'
local data = require 'enip.cip.segment.data'

local object_path = base:subclass('enip.cip.segment.object_path')

object_path.static.easy_create = function(class, instance, attribute, member)
	local o = object_path:new()
	o:append_logical(logical.TYPES.CLASS_ID, class)
	if instance ~= nil then
		o:append_logical(logical.TYPES.INSTANCE_ID, instance)
	end
	if attribute ~= nil then
		o:append_logical(logical.TYPES.ATTRIBUTE_ID, attribute)
	end
	if member ~= nil then
		o:append_logical(logical.TYPES.MEMBER_ID, member)
	end
	return o
end

---
-- pad: whether the logical segment in Pad or Packed format
--		default is packed
function object_path:initialize(pad)
	base.initialize(self)
	self._pad = pad
	self._segments = {}
end

function object_path:pad()
	return self._pad
end

function object_path:segments()
	return self._segments
end

local ltypes = logical.TYPES

local logical_type_level = {
	[ltypes.CLASS_ID] = {19},
	[ltypes.INSTANCE_ID] = {29},
	[ltypes.CONNECTION_POINT] = {29,30},
	[ltypes.ATTRIBUTE_ID] = {39},
	[ltypes.MEMBER_ID] = {30,40},
}

local symbolic_type_level = {
	[ltypes.MEMBER_ID] = {19},
	[ltypes.CONNECTION_POINT] = {19},
}

function object_path:append(seg)
	if seg:type() == seg_base.TYPES.SYMBOLIC then
		assert(#self._segments == 0, "Symbolic ID must be the first segment")
	else
		local level = logical_type_level[seg:logical_type()]
		local counts = #self._segments
		local ok = false
		for _, v in ipairs(level) do
			if (v // 10) - counts == 1 then
				ok = true
			end
		end
		assert(ok, "Invalid segment squence")
	end

	table.insert(self._segments, seg)
end

function object_path:append_symbolic(val, ext_format, numeric_type)
	local seg = symbolic:new(val, ext_format, numeric_type)
	return self:append(seg)
end

function object_path:append_logical(logical_type, logical_fmt, value)
	local seg = logical:new(logical_type, logical_fmt, value, self._pad)
	return self:append(seg)
end

function object_path:segments()
	return self._segments
end

function object_path:segment(index)
	return self._segments[index]
end

function object_path:to_hex()
	local raw = {}
	for _, seg in ipairs(self._segments) do
		raw[#raw + 1] = seg:to_hex()
	end
	raw = table.concat(raw)

	--logger.dump('to_hex', raw)
	return raw
end


function object_path:from_hex(raw, index)
	--logger.dump('from_hex', raw, index)
	--- Clear the segments
	self._segments = {}

	while index < string.len(raw) do
		local seg, new_index = seg_base.parse(raw, index)
		if seg:type() == seg_base.TYPES.SYMBOLIC or
			seg:type() == seg_base.TYPES.LOGICAL then
			table.insert(self._segments, seg)
		else
			break
		end
		index = new_index
	end

	return index
end

return object_path
