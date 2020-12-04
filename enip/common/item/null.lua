local class = require 'middleclass'
local item_base = require 'enip.command.item.base'
local types = require 'enip.command.item.types'

local null = class('enip.command.item.null', item_base)

function null:intialize()
	item_base.initialize(self, types.NULL)
end

return null
