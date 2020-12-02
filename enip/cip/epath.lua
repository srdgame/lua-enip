local class = require 'middleclass'
local logger = require 'enip.logger'
local base = require 'enip.serializable'

local epath = class('enip.cip.epath', base)

function epath:initialize(pad)
	self._pad = pad
	self._segments = {}
end

function epath:append(seg)
	table.insert(self._segments, seg)
end

function epath:to_hex()
	local raw = {}
	for _, seg in ipairs(self._segments) do
		raw[#raw + 1] = seg:to_hex()
	end
	raw = table.concat(raw)
	logger.dump(self.name..'.to_hex', raw)
	return raw
end

function epath:from_hex(raw, index)
	logger.dump(self.name..'.from_hex', raw, index)
	-- TODO:
end

function epath:pad()
	return self._pad
end

function epath:segments()
	return self._segments
end

return epath
