
local base = require 'enip.command.base' 
local pfinder = require 'enip.utils.pfinder'

local finder = pfinder(base.COMMAND, 'enip.reply')

return function(command, raw, index)
	local p, err = finder(command)
	assert(p, err)

	local reply = p:new()
	index = reply:from_hex(raw, index)

	return reply, index
end
