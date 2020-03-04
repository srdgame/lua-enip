local class = require 'middleclass'
local item_parser = require 'enip.command.item.parser'

local command_data = class('ENIP_COMMAND_DATA')

function command_data:initialize(items)
	self._items = items or {}
end

function command_data:__tostring()
	return self:to_hex()
end

function command_data:to_hex()
	local data = {}
	local count = #self._items

	data[1] = string.pack('<I2', count)
	for _, v in ipairs(self._items) do
		data[#data + 1] = v.to_hex and v.to_hex() or tostring(v)
	end

	return table.concat(data)
end

function command_data:parse_command_item(raw, index)
	local item, index = item_parser.parse(raw, index)
	return item, index
end

function command_data:from_hex(raw, index)
	self._items = {}

	local count, index = string.unpack('<I2', raw, index)
	if count > 0 then
		for i = 1, count do
			local item
			item, index = self:parse_command_item(raw, index)
			self._items[#self._items + 1] = item
		end
	end
	return index
end

function command_data:items()
	return self._items
end

return command_data
