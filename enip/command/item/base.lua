local base = require 'enip.serializable'
local pfinder = require 'enip.utils.pfinder'

local item = base:subclass('enip.command.item.base')

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

local p_finder = pfinder(item.static.TYPES, 'enip.command.item')

item.static.parse = function(raw, index)
	local item_code, item_length = string.unpack('<I2I2', raw, index)
	local p, err = p_finder(item_code)
	assert(p, err)

	local item = p:new()
	index = item:from_hex(raw, index)
	return item, index
end

item.static.build = function(type_code, ...)
	local p, err = p_finder(type_code)
	assert(p, err)

	return assert(p:new(...), "Create item failed!!")
end

function item:initialize(item_type)
	base.initialize(self)
	self._type = item_type or item.static.TYPES.NULL
end

function item:to_hex()
	local data = self.encode and self:encode() or ''
	local data_len = string.len(data)
	return string.pack('<I2I2', self._type, data_len)..data
end

function item:from_hex(raw, index)
	assert(raw, 'stream raw data is missing')
	local index = index or 1
	local data_len = 0
	self._type, data_len, index = string.unpack('<I2I2', raw, index)
	if data_len > 0 then
		assert(self.decode, "Decode function missing")
		local data_raw = string.sub(raw, index, index + data_len - 1)
		local data_index = self:decode(data_raw)
		--print(string.format('%02X', self._type), data_index, string.len(data_raw))
		-- assert(data_index == string.len(data_raw) + 1, "Item data decode error")
		assert(data_index <= string.len(data_raw) + 1, "Item data decode error")
	end
	return index + data_len
end

function item:type()
	return self._type
end

return item
