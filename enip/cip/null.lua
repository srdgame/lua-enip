local class = require 'middleclass'
local cpf = require 'cip.item.base'
local types = require 'cip.item.types'

local null = class('LUA_ENIP_CIP_TYPES_NULL', cpf)

function null:intialize()
	cpf:initialize(types.NULL)
end

return null
