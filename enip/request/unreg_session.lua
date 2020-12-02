local class = require 'middleclass'
local types = require 'enip.command.types'
local command = require 'enip.command.base'

--- UDP Only? List Identity
local req = class('enip.request.unreg_session', command)

function req:initialize(session)
	command.initialize(self, session, types.CMD.UNREG_SESSION)
end

return req
