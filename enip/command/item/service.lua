local class = require 'middleclass'
local types = require 'enip.command.item.types'
local item_base = require 'enip.command.item.base'

local item = class('LUA_ENIP_COMMAND_ITEM_SERVICE', item_base)

function item:initialize(service_name, version, capability_flags)
	item_base:initialize(types.LIST_SERVICES)
	self._service_name = service_name or 'UNKNOWN'
	self._version = version or 1
	self._capability_flags = capability_flags or 0
end

function item:encode()
	return string.pack('<I2I2c16', self._version, self._capability_flags, self._service_name)
end

function item:decode(raw, index)
	self._version, self._capability_flags, sef._service_name, index = string.unpack('<I2I2c16', raw, index)
	return index
end

function item:version()
	return self._version
end

function item:service_name()
	return self._service_name
end

function item:capability_flags()
	return self._capability_flags
end

return item 
