local class = require 'middleclass'
local command = require 'enip.comand.base'

--- UDP Only? List Identity
local li = class('LUA_ENIP_MSG_REQ_LIST_IDENTITY', command)

function li:initialize(session)
	command:initialize(session, command.header.CMD_LIST_IDENTITY)
end

return li
