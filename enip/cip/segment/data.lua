local class		= require 'middleclass'
local logger	= require 'enip.logger'
local base		= require 'enip.cip.segment.base'
local ansi		= require 'enip.cip.segment.data.ansi'
local simple	= require 'enip.cip.segment.data.simple'

local seg = class('enip.cip.segment.data', base)

seg.static.FORMATS = {
	SIMPLE		= 0x00, -- Simple Data Segment
	ANSI		= 0x11, -- ANSI Extended Symbol Segment
}

function seg:initialize(format, ...)
	segment.initialize(self, segment.TYPES.DATA, data_format)
	if format == seg.static.FORMATS.SIMPLE then
		self._val = simple:new(...)
	end
	if format == seg.static.FORMATS.ANSI then
		self._val = ansi:new(...)
	end
end

function seg:value()
	return self._val
end

function seg:encode()
	return self._val:to_hex()
end

function seg:decode(raw, index)
	if fmt == seg.static.FORMATS.ANSI then
		--- ANSI Extended Symbol
		local p = ansi:new()
		index = p:from_hex(raw, index)
		return index
	end
	if fmt == seg.static.FORMATS.SIMPLE then
		-- Simple Data Segement
		local p = simple:new()
		index = p:from_hex(raw, index)
		return index
	end

	assert(nil, "FORMAT Illgel")
end

return seg
