local class = require 'middleclass'
local base = require 'enip.cip.reply.base'
local types = require 'enip.cip.types'
local parser = require 'enip.cip.segment.parser'

local reply = class('ENIP_CIP_REPLY_READ_TAG', base)

function reply:initialize(data_type, data)
	base.initialize(self, types.SERVICES.READ_FRG, 0)
	self._data_type = data_type
	self._data = data
end

function reply:encode()
	assert(self._data, 'Data is missing')
	local data = self._data.to_hex and self._data:to_hex() or tostring(self._data)
	return string.pack('<I1I1', self._data_type, 0)..data
end

function reply:data_type()
	return self._data_type
end

function reply:data()
	return self._data
end

function reply:decode(raw, index)
	--[[
	assert(self._status == types.STATUS.OK)
	self._data, index = parser(raw, index)
	]]--
	self._data_type, _, index = string.unpack('<I1I1', raw, index)
	self._data = string.sub(raw, index)
	return index
end

return reply
