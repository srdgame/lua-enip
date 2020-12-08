local class = require 'middleclass'

local lazy = class('enip.utils.parser.lazy')

function lazy:initialize(code, raw, index, len)
	self._code = code
	self._raw = string.sub(raw, index, index + len - 1)
	self._data = nil
end

function lazy:__call(parser, reparse)
	if self._data and not reparse then
		return true
	end	

	local obj, index = parser(self._code, self._raw)
	if not obj then
		return false
	end
	assert(index = string.len(self._raw) + 1, "Decode error!")
	self._data = obj
	return self._data
end

return lazy
