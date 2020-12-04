local base = require 'enip.command.base'

--- UDP Only? List Identity
local req = base:subclass('enip.request.unreg_session')

function req:initialize(session)
	base.initialize(self, session, base.COMMAND.UNREG_SESSION)
end

return req
