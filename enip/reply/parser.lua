
local header = require 'enip.command.header' 
local types = require 'enip.command.types' 


local function find_package_by_command(command)
	for k, v in pairs(types.CMD) do
		if tonumber(v) == tonumber(command) then
			local r, p = pcall(require, 'enip.reply.' .. string.lower(k))
			if not r then
				return nil, p
			end
			return p
		end
	end

	return nil, "Not found"
end

return function(raw, index)
	local h = header:new()
	h:from_hex(raw, index)
	local cmd = h:command()

	local p = find_package_by_command(cmd)
	assert(p, 'Package missing'..cmd)
	local reply = p:new()
	index = reply:from_hex(raw, index)

	return reply, index
end
