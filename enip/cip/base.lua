local class = require 'middleclass'

local cpf = class('LUA_ENIP_CIP_TYPES_NULL')

function cpf:initialize(type_id)
	self._type = type_id or 0x0000 --- NULL
	self._data_len = 0
end

function cpf:to_hex()
	local data = self.decode and self:decode() or ''
	self._data_len = string.len(data)
	return string.pack('<I2I2', self._type, self._data_len)..data
end

function cpf:from_hex(raw)
	self._type, self._data_len = string.unpack('<I2I2', raw)
	if self._data_len > 0 then
		assert(self.decode, "Decode function missing")

		---- FIXME: Using global format register parser?????
		self:decode(string.sub(raw, string.packsize('<I2I2') + 1))
	end
end

function cpf:len()
	return self._data_len + string.packsize('<I2I2')
end

return cpf
