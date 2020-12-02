--- Segment Definition Hierarchy
--

--- TODO: Encoded Path Shortcut Rules is not supported yet

local class = require 'middleclass'
local logger = require 'enip.logger'
local base = require 'enip.serializable'
local seg_base = require 'enip.cip.segment.base'
local logical = require 'enip.cip.segment.logical'
local symbolic = require 'enip.cip.segment.symbolic'
local data = require 'enip.cip.segment.data'
local parser = require 'enip.cip.segment.parser'

local chain = class('enip.cip.segment.chain', base)

---
-- pad: whether the logical segment in Pad or Packed format
--		default is packed
function chain:initialize(pad)
	self._pad = pad
	self._segments = {}
end

function chain:pad()
	return self._pad
end

function chain:segments()
	return self._segments
end

local ltypes = logical.SUB_TYPES
local logical_type_level = {
	[ltypes.CLASS_ID] = {19},
	[ltypes.INSTANCE_ID] = {29},
	[ltypes.ATTRIBUTE_ID] = {39},
	[ltypes.MEMBER_ID] = {30,40},
	[ltypes.CONNECTION_POINT] = {29,30},
}

local symbolic_type_level = {
	[ltypes.MEMBER_ID] = [19],
	[ltypes.CONNECTION_POINT] = [19],
}

function chain:append(seg)
	if seg:type() == seg_base.TYPES.SYMBOLIC then
		assert(#self._segments == 0, "Symbolic ID must be the first segment")
	else
		local level = logical_type_level[seg:sub_type()]
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

function chain:append_symbolic(val, ext_format, numeric_type)
	local seg = symbolic:new(val, ext_format, numeric_type)
	return self:append(seg)
end

function chain:append_logical(logical_type, logical_fmt, value)
	local seg = logical:new(logical_type, logical_fmt, value, self._pad)
	return self:append(seg)
end

function chain:segments()
	return self._segments
end

function chain:to_hex()
	assert(self._path)

	local raw = {}
	for _, seg in ipairs(self._segments) do
		raw[#raw + 1] = seg:to_hex()
	end
	raw = table.concat(raw)

	logger.dump(self.name..'.to_hex', raw)
	return raw
end


function chain:from_hex(raw, index)
	logger.dump(self.name..'.from_hex', raw, index)
	--- Clear the segments
	self._segments = {}

	local new_index = index
	while index < string.len(raw) do
		local seg, new_index = parser(raw, index)
		if seg:type() == seg_base.TYPES.SYMBOLIC or
			seg:type() == seg_base.TYPES.LOGICAL then
			table.insert(self._segments, seg)
			index = new_index
		else
			break
		end
	end

	return index
end

return chain
