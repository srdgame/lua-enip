local class = require 'middleclass'

local chain = class('enip.utils.parser.chain')

function chain:initialize(conflict_check)
	self._parsers = {}
	self._hash = {}
	self._conflict_check = conflict_check
	self._lazy_list = {}
end

function chain:add_lazy(code, lazy, callback)
	assert(code ~= nil, "Code missing")
	assert(lazy ~= nil, "Parser.lazy object missing")
	local list = self._lazy_list[code] or {}

	table.insert(list, {lazy = lazy, callback = callback})

	self._lazy_list[code] = list
end

function chain:pre_check(parser)
	if not self._conflict_check then
		return true
	end

	local hash = parser:hash()
	local err = 'Parser code conflicted. codes:'
	local ok = true

	for k,v in pairs(hash) do
		if self._hash[k] then
			err = err .. string.format(' key:%s value:%02X', k, v)
			ok = false
		end
	end

	return ok, ok and err or nil
end

function chain:build_hash(parser, overwrite)
	local hash = parser:hash()
	local lazy_list = self._lazy_list
	for k, v in pairs(hash) do
		if not self._hash[k] or overwrite then
			self._hash[k] = parser

			--- Parse the lazy object
			local list = lazy_list[k]
			if list then
				for i, v in ipairs(list) do
					local data = v.lazy(parser, true) -- reparse again
					if v.callback then
						if v.callback(data) then
							table.remove(i) -- remove the lazy
						end
					end
				end
				--- resign the list
				if #list ~= 0 then
					lazy_list[k] = list
				end
			end
		end
	end
	return true
end

function chain:append(parser)
	assert(parser ~= nil)
	local r, err = self:pre_check(parser)
	if not r then
		return r, err
	end
	table.insert(self._parsers, parser)
	return self:build_hash(parser)
end

function chain:insert(pos, parser)
	assert(pos ~= nil and parser ~= nil)
	local r, err = self:pre_check(parser)
	if not r then
		return r, err
	end
	table.insert(self._parsers, pos, parser)
	return self:build_hash(parser)
end

function chain:__call(code, raw, index)
	for _, v in ipairs(self._parsers) do
		local obj, obj_index = v(code, raw, index)
		if obj then
			return obj, obj_index
		end
	end

	return false, index
end

return chain
