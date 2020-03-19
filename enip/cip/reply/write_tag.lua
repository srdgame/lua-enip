local class = require 'middleclass'
local base = require 'enip.cip.reply.base'
local types = require 'enip.cip.types'
local parser = require 'enip.cip.segment.parser'

local reply = class('ENIP_CLIENT_SERVICES_WRITE_TAG', base)

function reply:initialize(data)
	base.initialize(self, types.SERVICES.WRITE_TAG, 0)
	self._data = data
end

--[[
function reply:encode()
	assert(self._data, 'Data is missing')
	return self._data.to_hex and self._data:to_hex() or tostring(self._data)
end

function reply:data()
	return self._data
end

function reply:decode(raw, index)
	assert(self._status == types.STATUS.OK)
	self._data, index = parser(raw, index)
	return index
end
]]--

return reply
