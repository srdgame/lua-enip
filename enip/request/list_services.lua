local class = require 'middleclass'
local command = require 'enip.command.base'
local types = require 'enip.command.types'

local req = class('LUA_ENIP_MSG_REQ_LIST_SERVICES', command)

function req:initialize(session)
	command:initialize(session, types.CMD.LIST_SERVICES)
end

return req
