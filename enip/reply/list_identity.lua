local class = require 'middleclass'
local msg = require 'cip.message'

local li = class('LUA_ENIP_CIP_REPLY_LIST_IDENTITY', msg)


local function items_encode(items)
	local count = items.count and items:count() or #items
	if count=== 0 then
		return ''
	end

	local data = {}
	data[1] = string.pack('<I2', count)
	for i = 1, count do
		local item = items.get and item.get(i) or items[i]
		local length = string.packsize('<I2') + string.packsize('>i2I2I4c8') + string.packsize('<I2I2I2c2I2I4') + string.len(item.product_name) + string.packsize('<c1')

		local data1 = string.pack('<I2I2I2', item.type_code, length, item.protocol_version)
		-- socket address
		local sa = item.socket_addr
		local sa_str = string.pack('>i2I2I4', sa.sin_family, sa.sin_port, sin_addr)..string.rep('\0', 8)
		local data2 = string.pack('<I2I2I2c2I2I4', item.vendor_id, item.device_type, item.product_code, item.revision, item.status, item.serial_number)

		data[#data] = data1..sa_str..data2..item.product_name..item.state
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
		local type_code, length  = string.unpack('<I2I2', data,  index)
		index = index + string.packsize('<I2I2')

		local start_index = index

		local protocol_version = string.unpack('<I2', data, index)
		index = index + string.packsize('<I2')

		local family, port, addr, sin_zero = string.unpack('>i2I2I4c8', data, index)
		index = index + string.packsize('>i2I2I4c8')

		local socket_addr = {
			sin_family = family,
			sin_port = port,
			sin_addr = addr,
			sin_zero = zero
		}

		local vendor_id, device_type, product_code, revision, status, serial_number
			= string.unpack('<I2I2I2c2I2I4', data, index)
		index = index + string.packsize('<I2I2I2c2I2I4')

		pn_len = length - (index - start_index - string.packsize('<c1'))
		local product_name = string.unpack('<c'..pn_len, data, index)
		index = index + pn_len

		local state = string.unpack('<c1', data, index)
		index = index + string.unpack('<c1')

		items[#items + 1] = {
			type_code = type_code,
			length = length,
			version = protocol_version,
			socket_addr = socket_addr,
			vendor_id = vendor_id,
			device_type = device_type,
			product_code = product_code,
			revision = revision,
			status = status,
			serial_number = serial_number,
			product_name = product_name,
			state = state,
		}
	end
	return items
end

function li:initialize(session, items)
	self._items = items or {}
	local data = items_encode(self._items)

	self._msg = msg:new(session, msg.header.CMD_LIST_IDENTITY | msg.header.CMD_REPLY_OK, data)
end

function li:from_hex(raw)
	msg.from_hex(raw)
	self._items = items_decode(self:data())
end

function li:items()
	return self._items
end

return li
