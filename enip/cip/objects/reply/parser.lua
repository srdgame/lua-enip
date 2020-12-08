local types = require 'enip.cip.types'
local pfinder = require 'enip.utils.pfinder'
local parser = require 'enip.utils.parser'
local chain = require 'enip.utils.parser.chain'
local lazy = require 'enip.utils.parser.lazy'

local object_finder = pfinder(types.OBJECT, 'enip.cip.objects', 'reply')

local op = chain:subclass('enip.cip.objects.parser')

function op:initialize(code, raw, index, len)
	print('lazy parser', code, string.len(raw), index)
	chain.initialize(self, true) --- conflict checking true
	self._code = code
	self._lazy = lazy:new(code, raw, index, len)
	self:add_lazy(code, self._lazy, function(data, err)
		self._data = data
		return true
	end)
end

---
-- Parse the data with provided parser:
--	:number -- Object Class ID
--	:object -- Parser object
function op:append(oparser)
	if type(oparser) == 'number' then
		local otypes, obase = object_finder:find(oparser, 'types')
		assert(otypes, obase)
		oparser = parser:new(otypes.SERVICES, obase..'.reply')
	end

	return chain.append(self, oparser)
end

function op:is_done()
	return self._data ~= nil
end

function op:data()
	return self._data
end

return function(code, raw, index, len)
	assert(code ~= nil, "Service code is missing")
	local code = code & 0x7F
	assert(code > types.SERVICES.MAX_COMMON_SERVICE, string.format("Invalid service code:0x%02X", code))

	local parser = op:new(code, raw, index, len)

	return parser, index + (len or 0)
end

