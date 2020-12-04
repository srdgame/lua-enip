local base = require 'enip.command.base'

local li = base:subclass('enip.request.list_interfaces')

function li:initialize(session)
	base.initialize(self, session, base.COMMAND.LIST_INTERFACES)
end

return li
