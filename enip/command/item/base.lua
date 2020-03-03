local class = require 'middleclass'

local item = class('LUA_ENIP_COMMAND_ITEM_BASE')

function item:initialize(type_id)
	self._type = type_id or 0x0000 --- NULL
end

function item:to_hex()
	local data = self.decode and self:decode() or ''
	return string.pack('<I2I2', self._type, string.len(data))..data
end

function item:from_hex(raw, index)
	local index = index or 1
	local data_len = 0
	self._type, data_len, index = string.unpack('<I2I2', raw, index)
	if data_len > 0 then
		assert(self.decode, "Decode function missing")
		index = self:decode(raw, index)
	end
	return index
end

return item
