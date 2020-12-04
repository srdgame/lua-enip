local class = require 'middleclass'
local base = require 'enip.cip.reply.base'
local types = require 'enip.cip.types'
local parser = require 'enip.cip.segment.parser'

local reply = class('enip.cip.reply.write_tag', base)

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
