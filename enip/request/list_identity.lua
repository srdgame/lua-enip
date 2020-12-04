local base = require 'enip.command.base'

--- UDP Only? List Identity
local li = base:subclass('enip.request.list_identity')

function li:initialize(session)
	base.initialize(self, session, base.COMMAND.LIST_IDENTITY)
end

return li
