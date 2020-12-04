local class = require 'middleclass'

local M = class('enip.serializable')

function M:initialize()
end

function M:to_hex()
	assert(nil, "Not implemented!")
end

function M:from_hex(raw, index)
	assert(nil, "Not implemented!")
end

M.static.easy_create = function(name, attrs)
	local sub = class(name, m)
	local sub_attrs = attrs or {}
	function sub:initialize(...)
		local vals = {...}
		for i, attr in ipairs(sub_attrs) do
			self['_'..attr.name] = vals[i]
		end
	end

	function sub:to_hex()
		local raw = {}
		for _, attr in ipairs(sub_attrs) do
			if type(attr.fmt) == 'string' then
				raw[#raw + 1] = string.pack(attr.fmt, self['_'..attr.name])
			elseif type(attr.fmt) == 'table' then
				raw[#raw + 1] = attr.encode(self['_'..attr.name])
			else
				assert(nil, "Invalid attributes found")
			end
		end
		return table.concat(raw)
	end

	function sub:from_hex(raw, index)
		local index = index or 1
		for _, attr in ipairs(sub_attrs) do
			if type(attr.fmt) == 'string' then
				self['_'..attr.name], index = string.unpack(attr.fmt, raw, index)
			elseif type(attr.fmt) == 'table' then
				self['_'..attr.name], index = attr.decode(raw, index)
			else
				assert(nil, "Invalid attributes found")
			end
		end
		return index
	end

	for _, attr in ipairs(sub_attrs) do
		assert(sub[attr.name] == nil, "Attributes already exists: "..attr.name)
		assert(sub['set_'..attr.name] == nil, "Attributes already exists: "..attr.name)
		sub[attr.name] = function(self)
			return self['_'..attr.name]
		end
		sub['set_'..attr.name] = function(self, val)
			self['_'..attr.name] = val
		end
	end

	return sub
end

return M
