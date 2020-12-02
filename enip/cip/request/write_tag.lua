local class = require 'middleclass'
local base = require 'enip.cip.request.base'
local types = require 'enip.cip.types'
local data_elem = require 'enip.cip.segment.data_elem'

local req = class('enip.cip.request.write_tag', base)

function req:initialize(path, data_type, value)
	base.initialize(self, types.SERVICES.WRITE_TAG, path)
	self._data_type = data_type
	self._value = value
end

function req:encode()
	assert(self._data_type, 'Data type is missing')
	assert(self._value, 'Value is missing')
	
	local write_obj = data_elem:new(self._data_type, self._value)
	local write_obj_hex = write_obj:to_hex()

	return string.pack('<I2I2', write_obj:type_num(), 1)..string.sub(write_obj_hex, 3) -- skip the type_number
end

function req:decode(raw, index)
	local index = index or 1
	local obj = data_elem:new()
	local data = string.sub(raw, index, index + 1) .. string.sub(raw, index + 3)
	local offset = obj:from_hex(data)

	self._data_type = obj:data_type()
	self._value = obj:value()

	index = index + 2 + offset
	return index
end

return req
