local class = require 'middleclass'
local msg = require 'cip.message'

local li = class('LUA_ENIP_CIP_MSG_REQ_LIST_INTERFACES', msg)

function li:initialize(session)
	self._msg = msg:new(session, msg.header.CMD_LIST_INTERFACES, '')
end

return li
