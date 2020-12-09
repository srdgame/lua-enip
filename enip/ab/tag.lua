local class = require 'middleclass'

local tag = class('enip.ab.tag')

function tag:initialize(path, type, count)
	self._path = path
	self._type = type
	self._count = count or 1
	self._join = nil
end

function tag:path()
	return self._path
end

function tag:type()
	return self._type
end

function tag:count()
	if not self._join then
		return self._count
	end

	return self._count + self._join:count()
end

function tag:join(tag)
	assert(self._join == nil, 'Joined already')
	-- TODO: check for joinable
	local segs = self._path:segments()
	local tag_segs = tag._path:segments()
	for i, v in ipairs(segs) do
		local o = tag_segs[i]
		if v:type() ~= o:type() or v:format() ~= o:format() then
			--- If type or format are not same break
			break
		else
			if v:value ~= o:value() then 
				--- Only match the last value
				if i == #segs then
					if v:type() == v.TYPES.LOGICAL and v:sub_type() == v.SUB_TYPES.MEMBER_ID then
						self._join = tag
					end
				end
				break
			else
				-- continue
			end
		end
	end
	return self._join
end

local function value_lt(a, b)
	if type(a) ~= 'table' then
		return a < b
	else
		if a.value and b.value then
			return a:value() < b:value()
		end
		if a.symbol and b.symbol then
			return a:symbol() < b:symbol()
		end
		return false
	end
end

local function value_eq(a, b)
	if type(a) ~= 'table' then
		return a == b
	else
		if a.value and b.value then
			return a:value() == b:value()
		end
		if a.symbol and b.symbol then
			return a:symbol() == b:symbol()
		end
		return false
	end
end

local function compare_lt(a, b)
	if a:type() = b:type() then
		if a:format() == b:format() then
			return value_lt(a:value(), b:value())
		end
		return a:format() < b:format()
	end
	return a:type() < b:type()
end

local function compare_eq(a, b)
	return a:type() = b:type()
		and a:format() == b:format()
		and value_eq(a:value(), b:value())
end

function tag:__lt(other)
	local segs = self._path:segments()
	local other_segs = other._path:segments()

	for i, v in ipairs(segs) do
		if compare_eq(v, other_segs[i]) then
			-- continue
		else
			return compare_lt(v, other_segs[i])
		end
	end
end

return tag
