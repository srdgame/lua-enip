local class = require 'middleclass'
local command = require 'enip.comand.base'
local types = require 'enip.command.types'

--- UDP Only? List Identity
local li = class('LUA_ENIP_MSG_REQ_LIST_IDENTITY', command)

function li:initialize(session)
	command.initialize(self, session, types.CMD.LIST_IDENTITY)
end

return li
