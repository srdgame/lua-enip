local class = require 'middleclass'
local seg_base = require 'enip.cip.segment.base'
local logical = require 'enip.cip.segment.logical'

local tag = class('enip.ab.tag')

function tag:initialize(path, type, count)
	self._path = path
	self._type = type
	self._count = count or 1
	self._join = nil
	self._upper = nil
	self._offset = nil --- Value offset
end

function tag:path()
	return self._path
end

function tag:type()
	return self._type
end

function tag:count(base)
	print('COUNT BEGIN', self._count, base, self._join)
	if not self._join then
		if not base then
			return self._count
		else
			local segs = self._path:segments()
			local last = segs[#segs]
			--- calc the array offset and count
			print('COUNT LAST', last:value(), base, self._count)
			return last:value() - base + self._count
		end
	end

	--- The last is the array offset
	local segs = self._path:segments()
	local last = segs[#segs]

	return self._join:count(base or last:value())
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
	if a:type() == b:type() then
		if a:format() == b:format() then
			return value_lt(a:value(), b:value())
		end
		return a:format() < b:format()
	end
	return a:type() < b:type()
end

local function compare_eq(a, b)
	return a:type() == b:type()
		and a:format() == b:format()
		and value_eq(a:value(), b:value())
end


function tag:join(other)
	assert(self._join == nil, 'Joined already')
	-- TODO: check for joinable
	local segs = self._path:segments()
	local tag_segs = other._path:segments()
	-- If path segement count not same.
	if #segs ~= #tag_segs then
		return
	end

	for i, v in ipairs(segs) do
		local o = tag_segs[i]
		if v:type() ~= o:type() or v:format() ~= o:format() then
			--- If type or format are not same break
			--print('type or format different')
			break
		else
			if not value_eq(v:value(), o:value()) then
				--print('value diff', v:value(), o:value())
				--- Only match the last value
				if i == #segs then
					if v:type() == seg_base.TYPES.LOGICAL and v:logical_type() == logical.TYPES.MEMBER_ID then
						assert(o:value() + other._count >=  v:value() + self._count)
						self._join = other
						self._offset = o:value() - v:value() + other:offset()
						other._upper = self
						--print('JOINED', self, other)
					else
						--print('not logical.memeber_id', v:type(), v.logical_type and v:logical_type() or 'NNNN')
					end
				end
				break
			else
				--print('seg same', i, v)
				-- continue
			end
		end
	end
	return self._join
end

function tag:join()
	return self._join
end

function tag:upper()
	return self._upper
end

function tag:offset()
	return self._offset or 1
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
