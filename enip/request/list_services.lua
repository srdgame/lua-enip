local base = require 'enip.command.base'

local req = base:subclass('enip.request.list_services')

function req:initialize(session)
	base.initialize(self, session, base.COMMEND.LIST_SERVICES)
end

return req
