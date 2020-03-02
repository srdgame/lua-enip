local class = require 'middleclass'
local msg = require 'cip.message'

--- UDP Only? List Identity
local li = class('LUA_ENIP_CIP_MSG_REQ_LIST_IDENTITY', msg)

function li:initialize(session)
	self._msg = msg:new(session, msg.header.CMD_LIST_IDENTITY, '')
end

return li
