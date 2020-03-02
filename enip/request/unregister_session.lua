local class = require 'middleclass'
local msg = require 'enip.message'

--- UDP Only? List Identity
local req = class('LUA_ENIP_MSG_REQ_UNREGISTER_SESSION', msg)

function req:initialize(session)
	self._msg = msg:new(session, msg.header.CMD_REG_SESSION, '')
end

return req
