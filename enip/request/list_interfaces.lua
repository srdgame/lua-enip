local class = require 'middleclass'
local command = require 'enip.comand.base'
local types = require 'enip.command.types'

local li = class('enip.request.list_interfaces', command)

function li:initialize(session)
	command.initialize(self, session, types.CMD.LIST_INTERFACES)
end

return li
