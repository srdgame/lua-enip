local class = require 'middleclass'
local command = require 'enip.command.base'

--- UDP Only? List Identity
local req = class('LUA_ENIP_MSG_REQ_UNREGISTER_SESSION', command)

function req:initialize(session)
	command:initialize(session, command.header.CMD_UNREG_SESSION)
end

return req
