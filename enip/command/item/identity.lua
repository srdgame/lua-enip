local base = require 'enip.command.item.base'

local item = base:subclass('enip.command.item.identity')

function item:initialize(info)
	base.initialize(self, base.TYPES.LIST_IDENTITY)
	self._info = info or {}
end

function item:encode()
	local info = self._info
	local sockaddr = sock
	sockaddr.sin_zero = info.sin_zero or string.rep('\0', 8)

	-- socket address
	local sa_str = string.pack('>i2I2I4', sockaddr.sin_family, sockaddr.sin_port, sin_addr)..sockaddr.sin_zero
	local data2 = string.pack('<I2I2I2c2I2I4', item.vendor_id, item.device_type, item.product_code, item.revision, item.status, item.serial_number)


	local data = sa_str..data2..item.product_name..string.pack('<I1', item.state)
	local length = string.len(data)
	local data1 = string.pack('<I2I2I2', item.type_code, length, item.protocol_version)

	return data1..data
end

function item:decode(raw, index)
	local start_index = index or 1
	local length = self:data_len()

	local info = self._info

	info.protocol_version, index = string.unpack('<I2', data, index)

	local family, port, addr, sin_zero
	family, port, addr, sin_zero = string.unpack('>i2I2I4c8', data, index)

	local sockaddr = {
		sin_family = family,
		sin_port = port,
		sin_addr = addr,
		sin_zero = zero
	}
	info.sockaddr = sockaddr

	info.vendor_id, info.device_type, info.product_code, info.revision, info.status, info.serial_number, index = string.unpack('<I2I2I2c2I2I4', data, index)

	pn_len = length - (index - start_index) - string.packsize('<I1')

	info.product_name, info.state, index = string.unpack('<c'..pn_len..'I1', data, index)

	return index
end


return item
