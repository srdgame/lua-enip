local base = require 'enip.cip.reply.base'
local types = require 'enip.cip.types'

local reply = base:subclass('enip.cip.reply.write_tag')

function reply:initialize(status, ext_status)
	base.initialize(self, types.SERVICES.WRITE_TAG, status or 0, ext_status)
end

function reply:encode()
	return ''
end

function reply:decode(raw, index)
	return index
end

return reply
