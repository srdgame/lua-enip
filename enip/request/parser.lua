
local base = require 'enip.command.base' 
local pfinder = require 'enip.utils.pfinder'

local finder = pfinder(base.COMMAND, 'enip.request')

return function(command, raw, index)
	local p, err = finder(command)
	assert(p, err)

	local request = p:new()
	index = request:from_hex(raw, index)

	return request, index
end
