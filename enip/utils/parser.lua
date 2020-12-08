local class = require 'middleclass'
local pfinder = require 'enip.utils.pfinder'

local parser = class('enip.utils.parser')

function parser:initialize(codes, base, appendix)
	assert(codes ~= nil and base ~= nil)
	assert(type(codes) == 'table')
	self._codes = codes
	self._hash = {}
	for k, v in pairs(codes) do
		self._hash[v] = string.lower(k)
	end
	self._base = base
	self._appendix = appendix
end

function parser:__call(code, raw, index)
	assert(code ~= nil and raw ~= nil)
	local m, err = self:find(code)
	if not m then
		return nil, err
	end
	local obj = m:new()
	index = obj:from_hex(raw, index)
	return obj, index
end

function parser:codes()
	return self._codes
end

function parser:hash()
	return self._hash
end

function parser:base()
	return self._base
end

function parser:find(code, appendix)
	local appendix = appendix or self._appendix
	local key = self._hash[code]
	if not key then
		return nil, "No package found:"..code
	end

	local p_name = base_pn..'.'..key
	p_name = appendix and p_name..'.'..appendix or p_name
	local r, p = pcall(require, p_name)
	if not r then
		return nil, p
	end
	return p
end

return parser
