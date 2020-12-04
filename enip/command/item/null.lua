local class = require 'middleclass'
local base = require 'enip.command.item.base'

local null = class('enip.command.item.null', base)

function null:intialize()
	base.initialize(self, base.TYPES.NULL)
end

return null
