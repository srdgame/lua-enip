local class = require 'middleclass'
local logger = require 'enip.logger'
local base = require 'enip.serializable'
local seg_base = require 'enip.cip.segment.base'
local logical = require 'enip.cip.segment.logical'
local data = require 'enip.cip.segment.data'
local parser = require 'enip.cip.segment.parser'

local epath = class('enip.cip.segment.epath', base)

function epath:initialize(path, packed)
	self:set_path(path)
	self._pad = packed and false or true
	self._segments = {}
end

function epath:pad()
	return self._pad
end

function epath:append(seg)
	table.insert(self._segments, seg)
end

function epath:append_logical(logical_type, logical_fmt, value)
	local seg = logical:new(logical_type, logical_fmt, value, self._pad)
	return self:append(seg)
end

function epath:set_path(path)
	self._path = data:new(data.FORMATS.ANSI, path)
end

function epath:path()
	return self._path
end

function epath:segments()
	return self._segments
end

function epath:to_hex()
	assert(self._path)

	local raw = {}
	for _, seg in ipairs(self._segments) do
		raw[#raw + 1] = seg:to_hex()
	end
	-- DATA (PATH) Segment 
	raw[#raw + 1] = self._path:to_hex()

	raw = table.concat(raw)

	logger.dump(self.name..'.to_hex', raw)
	return raw
end

function epath:from_hex(raw, index)
	logger.dump(self.name..'.from_hex', raw, index)
	--- Clear the segments
	self._segments = {}

	while index < string.len(raw) do
		local seg, index = parser(raw, index)
		if seg:type() == seg_base.TYPES.DATA then
			assert(seg:format() == data.FORMATS.ANSI, "Path must be ANSI extended symbol segment")
			self._path = seg
			break
		else
			table.insert(self._segments, seg)
		end
	end

	return index
end

return epath
