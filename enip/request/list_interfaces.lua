local class = require 'middleclass'
local command = require 'enip.comand.base'
local types = require 'enip.command.types'

local li = class('LUA_ENIP_MSG_REQ_LIST_INTERFACES', command)

function li:initialize(session)
	command.initialize(self, session, types.CMD.LIST_INTERFACES)
end

return li
