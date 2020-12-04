local class = require 'middleclass'

local item = class('enip.command.item.base')

item.static.TYPES = {
	NULL				= 0x0000,	-- NULL
	LIST_IDENTITY		= 0x000C,	-- ListIdentity
	CONNECTED_ADDR		= 0x00A1,	-- Connected Address Item
	CONNECTED			= 0x00B1,	-- Connected Transport Item
	UNCONNECTED			= 0x00B2,	-- Unconnected message
	LIST_SERVICES		= 0x0100,	-- ListServices
	SOCK_ADDR_C			= 0x8000,	-- Socketaddr Info, originator to target
	SOCK_ADDR_S			= 0x8002,	-- Socketaddr Info, target to originator
	SEQUENCED_ADDR		= 0x8002,	-- Sequenced Addresss Item
}

function item:initialize(type_id)
	self._type_id = type_id or 0x0000 --- NULL
	self._data_len = -1
end

function item:to_hex()
	local data = self.encode and self:encode() or ''
	self._data_len = string.len(data)
	return string.pack('<I2I2', self._type_id, self._data_len)..data
end

function item:from_hex(raw, index)
	assert(raw, 'stream raw data is missing')
	local index = index or 1
	self._type_id, self._data_len, index = string.unpack('<I2I2', raw, index)
	if self._data_len > 0 then
		assert(self.decode, "Decode function missing")
		index = self:decode(raw, index)
	end
	return index
end

function item:type_id()
	return self._type_id
end

function item:data_len()
	if self._data_len < 0 then
		local data = self.decode and self:decode() or ''
		self._data_len = string.len(data)
	end
	return self._data_len
end

return item
