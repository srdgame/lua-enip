--[[
local class = require 'middleclass'

local cpf = class('LUA_ENIP_CIP_TYPES_NULL')
]]--

local TYPE_ID = {
	NULL				= 0x0000,	-- NULL
	LIST_IDENTITY		= 0x000C,	-- ListIdentity
	CONNECTED_ADDR		= 0x00A1,	-- Connected Address Item
	CONNECTED			= 0x00B1,	-- Connected Transport Item
	UNCONNECTED			= 0x00B2,	-- Unconnected message
	SOCK_ADDR_C			= 0x8000,	-- Socketaddr Info, originator to target
	SOCK_ADDR_S			= 0x8002,	-- Socketaddr Info, target to originator
	SEQUENCED_ADDR		= 0x8002,	-- Sequenced Addresss Item
}

return TYPES_ID

--[[
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

local null = class('LUA_ENIP_CIP_TYPES_NULL', cpf)

function null:intialize()
	cpf:initialize(TYPE_ID.NULL)
end

local connected_address = class('LUA_ENIP_CIP_TYPES_CONNECTED_ADDRESS', cpf)

function connected_address:initialize(conn_identity)
	cpf:initialize(TYPE_ID.CONNECTED_ADDR)
	self._conn_identity = tonumber(conn_identity) or 0
end

function connected_address:encode()
	return string.pack('<I4', self._conn_identity)
end

function connected_address:decode(raw)
	self._conn_identity = string.unpack('<I4', raw)
end

function connected_address:identity()
	return self._conn_identity
end

local squenced_address = class('LUA_ENIP_CIP_TYPES_CONNECTED_ADDRESS', cpf)

function squenced_address:initialize(identity, sequence)
	cpf:initialize(TYPE_ID.CONNECTED_ADDR)
	self._identity = tonumber(identity) or 0
	self._sequence = tonumber(sequence) or 0
end

function squenced_address:encode()
	return string.pack('<I4I4', self._identity, self._sequence)
end

function squenced_address:decode(raw)
	self._identity, self._sequence = string.unpack('<I4I4', raw)
end

function squenced_address:identity()
	return self._identity
end

function squenced_address:sequence()
	return self._sequence
end

local unconnected = class('LUA_ENIP_CIP_TYPES_UNCONNECTED', cpf)

function unconnected:initialize()
	cpf:initialize(TYPE_ID.UNCONNECTED)
end

local connected = class('LUA_ENIP_CIP_TYPES.CONNECTED', cpf)

function connected:initialize()
	cpf:initialize(TYPE_ID.CONNECTED)
end


local sockaddr_info = class('LUA_ENIP_CIP_TYPS_SOCKADDR_INFO', cpf)

function sockaddr_info:intialize(from_target, info)
	cpf:intialize(from_target and TYPES_ID.SOCK_ADDR_S or TYPES_ID.SOCK_ADDR_C)
	self._info = info or {}
end

function sockaddr_info:encode()
	local info = self._info
	info.sin_zero = info.sin_zero or string.rep('\0', 8)
	return string.pack('>i2I2I4', info.sin_family, info.sin_prot, info.sin_addr)..info.sin_zero
end

function sockaddr_info:decode(raw)
	local info = self._info
	info.sin_family, info.sin_port, info.sin_addr, info.sin_zero = string.unpack('>i2I2I4c8', raw)
end

]]--
