
local types = require 'enip.command.item.types'

local function get_package_from_type_code(code)
	for k, v in pairs(types) do
		if v == tonumber(code) then
			local pn = 'enip.command.item.'..string.lower(k)
			local r, p = pcall(require, pn)
			if not r then
				return nil, p
			end
			return p
		end
	end
	return nil, "Not found"
end

local item_parse = function(raw, index)
	local item_code, item_length = string.unpack('<I2I2', raw, index)
	local p, err = get_package_from_type_code(item_code)

	--- TODO:
	assert(p, err)

	local item = p:new()
	index = item:from_hex(raw, index)
	return item, index
end

local item_build = function(type_code, ...)
	local p, err = get_package_from_type_code(type_code)
	assert(p, err)

	return p:new(...)
end


return {
	parse = item_parse,
	build = item_build,
}
