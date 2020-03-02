local class = require 'middleclass'

local cpf = class('LUA_ENIP_CIP_TYPES_NULL')

function cpf:initialize(type_id)
	self._type = type_id or 0x0000 --- NULL
end

function cpf:to_hex()
	local data = self.decode and self:decode() or ''
	string.pack('<I2I2', self._type, string.len(data))..data
end

function cpf:from_hex(raw)
	local len = 0
	self._type, len = string.unpack('<I2I2', raw)
	if len > 0 then
		assert(self.decode, "Decode function missing")
		self:decode(string.sub(raw, string.packsize('<I2I2') + 1))
	end
end

return cpf
