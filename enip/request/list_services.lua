local class = require 'middleclass'
local msg = require 'cip.message'

local req = class('LUA_ENIP_CIP_MSG_REQ_LIST_SERVICES', msg)

function req:initialize(session)
	self._msg = msg:new(session, msg.header.CMD_LIST_SERVICES, '')
end

return req
