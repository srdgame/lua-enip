local logger = require 'enip.logger'
local base = require 'enip.serializable'
local seg_base = require 'enip.cip.segment.base'
local logical = require 'enip.cip.segment.logical'
local data = require 'enip.cip.segment.data'

local epath = base:subclass('enip.cip.segment.epath')

function epath:initialize(path, packed)
	self._pad = packed and false or true
	self._segments = {}
	if path then
		self:append(path)
	end
end

function epath:__tostring()
	local t = {}
	for _, seg in pairs(self._segments) do
		t[#t + 1] = tostring(seg)
	end
	return table.concat(t, '|')
end

function epath:pad()
	return self._pad
end

function epath:append(path)
	if type(path) == 'string' then
		path = self:path_from_string(path)
	end
	table.insert(self._segments, path)
end

function epath:path_from_string(path)
	return data:new(data.FORMATS.ANSI, path)
end

function epath:segments()
	return self._segments
end

function epath:segment(index)
	return self._segments[index]
end

function epath:to_hex()
	assert(#self._segments > 0)

	local raw = {}
	for _, seg in ipairs(self._segments) do
		raw[#raw + 1] = seg:to_hex()
	end

	raw = table.concat(raw)

	logger.dump('to_hex', raw)
	return raw
end

function epath:from_hex(raw, index)
	logger.dump('from_hex', raw, index)
	--- Clear the segments
	self._segments = {}

	local index = index or 1
	while index < string.len(raw) do
		local seg, new_index = seg_base.parse(raw, index)
		if seg:type() == seg_base.TYPES.DATA then
			assert(seg:format() == data.FORMATS.ANSI, "Path must be ANSI extended symbol segment")
			table.insert(self._segments, seg)
		elseif seg:type() == seg_base.TYPES.LOGICAL or
			seg:type() == seg_base.TYPES.SYMBOLIC then
			table.insert(self._segments, seg)
		else
			break
		end
		index = new_index
	end

	return index
end

return epath
