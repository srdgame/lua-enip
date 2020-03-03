local class = require 'middleclass'

local cip_parser = class('ENIP_CIP_PARSER')

function cip_parser:initialize(items)
	self._items = items or {}
end

function cip_parser:__tostring()
	return self:to_hex()
end

function cip_parser:__call(raw)
	self:from_hex(raw)
	return self._items
end

function cip_parser:to_hex()
	local data = {}
	local count = #self._items

	data[1] = string.pack('<I2', count)
	for _, v in ipairs(self._items) do
		data[#data + 1] = v.to_hex and v.to_hex() or tostring(v)
	end

	return table.concat(data)
end

function cip_parser:parse_command_item(raw, index)

end

function cip_parser:from_hex(raw, index)
	self._items = {}

	local count, index = string.unpack('<I2', raw, index)
	if count > 0 then
		for i = 1, count do
			local item = self:parse_command_item(raw, index)
			self._items[#self._items + 1] = item
			index = index + item:len()
		end
	end
end

function cip_parser:items()
	return self._items
end


return cip_parser
