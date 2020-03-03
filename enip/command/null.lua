local class = require 'middleclass'
local cpf = require 'enip.cip.base'
local types = require 'enip.cip.types'

local null = class('LUA_ENIP_CIP_NULL_MSG', cpf)

function null:intialize()
	cpf:initialize(types.NULL)
end

return null
