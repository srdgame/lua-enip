local class = require 'middleclass'

local lazy = class('enip.utils.lazy_parser')

function lazy:initialize(parser_func)
	self._parser = parser_func
end

function lazy:__call(raw, index)
	local obj, index = self._parser(raw, index)
	if not obj 
end

function lazy:try_parse()
end

function lazy:append(parser)
end

return lazy
