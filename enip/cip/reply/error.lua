local types = require 'enip.cip.types'
local base = require 'enip.cip.reply.base'

local reply = base:subclass('enip.cip.reply.error')

function reply:encode()
	return ''
end

function reply:decode(raw, index)
	return index
end

return reply
