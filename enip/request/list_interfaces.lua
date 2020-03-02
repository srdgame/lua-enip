local class = require 'middleclass'
local msg = require 'enip.message'

local li = class('LUA_ENIP_MSG_REQ_LIST_INTERFACES', msg)

function li:initialize(session)
	self._msg = msg:new(session, msg.header.CMD_LIST_INTERFACES, '')
end

return li
