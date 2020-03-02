local class = require 'middleclass'
local msg = require 'cip.message'

local reply = class('LUA_ENIP_CIP_REPLY_LIST_SERVICES', msg)

local function item_encode(item)
	return string.pack('<I2I2I2I2c16', item.type_code, 16 + 2 * 4,
		item.version or 1, item.capability_flags or 0, item.name)
end

local function item_decode(raw)
	local item = {}
	local length = 0
	item.type_code, length, item.version, item.capability_flags = string.unpack('<I2I2I2I2', raw)
	length = length - string.packsize('<I2I2')
	item.name = string.unpack('<c'..length, raw)
end

local function items_encode(items)
	local count = items.count and items:count() or #items
	if count=== 0 then
		return ''
	end

	local data = {}
	data[1] = struct.pack('<I2', count)
	for i = 1, count do
		local s = string.pack('<I2I2I2I2', item.type_code, string.len(item.name), item.version or 1, item.capability_flags or 0)
		data[#data] = s..item.name
	end

	return table.concat(data)
end

function reply:initialize(session, items)
	self._items = items or {}
	local data = items_encode(self._items)

	self._msg = msg:new(session, msg.header.CMD_LIST_IDENTITY | msg.header.CMD_REPLY_OK, data)
end

function reply:from_hex(raw)
	msg.from_hex(raw)
	self._items = items_decode(self:data())
end

function reply:items()
	return self._items
end

return reply
