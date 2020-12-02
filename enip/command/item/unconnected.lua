local class = require 'middleclass'
local cip_parser = require 'enip.cip.parser'
local types = require 'enip.command.item.types'
local item_base = require 'enip.command.item.base'

local item = class('enip.command.item.unconnected', item_base)

function item:initialize(cip)
	item_base.initialize(self, types.UNCONNECTED)
	self._cip = cip or ''
end

function item:encode()
	return self._cip.to_hex and self._cip:to_hex() or tostring(self._cip)
end

function item:decode(raw, index)
	assert(raw, 'stream raw data is missing')
	self._cip, index = cip_parser(raw, index)
	return index
end

function item:cip()
	return self._cip
end

return item
