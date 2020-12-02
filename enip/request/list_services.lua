local class = require 'middleclass'
local command = require 'enip.command.base'
local types = require 'enip.command.types'

local req = class('enip.request.list_services', command)

function req:initialize(session)
	command.initialize(self, session, types.CMD.LIST_SERVICES)
end

return req
