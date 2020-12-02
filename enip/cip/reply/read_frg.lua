local class = require 'middleclass'
local base = require 'enip.cip.reply.base'
local types = require 'enip.cip.types'
local multi_pack = require 'enip.cip.reply.common.multi_service_packet'

local reply = class('enip.cip.reply.read_frg', base)

function reply:initialize(replies)
	--assert(replies, 'Replies are required')
	base.initialize(self, types.SERVICES.READ_FRG, 0)
	self._mr = multi_pack:new(replies)
end

function reply:encode()
	return self._mr.to_hex and self._mr:to_hex() or tostring(self._mr)
end

function reply:decode(raw, index)
	index = self._mr:from_hex(raw, index)
	return index
end

function reply:data()
	return self._mr
end

return reply
