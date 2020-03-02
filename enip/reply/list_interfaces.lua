local class = require 'middleclass'
local msg = require 'cip.message'

local li = class('LUA_ENIP_CIP_REPLY_LIST_INTERFACES', msg)


local function items_encode(items)
	local count = items.count and items:count() or #items
	if count=== 0 then
		return ''
	end

	local data = {}
	for i = 1, count do
		local item = items.get and item.get(i) or items[i]
		---TODO:
	end

	return table.concat(data)
end

local function items_decode(data)
	if string.len(data) <= 2 then
		return {}
	end

	local items = {}
	local count = string.unpack('<I2', data)
	local index = 2 + 1
	for i = 1, count do
		local type_code, length = string.unpack('<I2I2', data,  index)
		index = index + string.packsize('<I2I2')

		local start_index = index

		--- TODO:
	end
	return items
end

function li:initialize(session, items)
	self._items = items or {}
	local data = items_encode(self._items)

	self._msg = msg:new(session, msg.header.CMD_LIST_IDENTITY, data)
end

function li:from_hex(raw)
	msg.from_hex(raw)
	self._items = items_decode(self:data())
end

function li:items()
	return self._items
end

return li
