local base = require 'enip.command.item.base'

local null = base:subclass('enip.command.item.null')

function null:intialize()
	base.initialize(self, base.TYPES.NULL)
end

return null
