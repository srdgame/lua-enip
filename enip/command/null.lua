local class = require 'middleclass'
local item_base = require 'enip.commmand.item'
local types = require 'enip.command.types'

local null = class('LUA_ENIP_COMMAND_NULL_ITEM', item_base)

function null:intialize()
	item_base:initialize(types.NULL)
end

return null
