--- Element Name Parser
--
local lpeg = require 'lpeg'
local locale = lpeg.locale()
local TEST = arg and arg[0] == 'parser.lua' and arg[-1] == 'lua'

local logical
local data
local epath
local tag
if not TEST then
	logical = require 'enip.cip.segment.logical'
	data = require 'enip.cip.segment.data'
	epath = require 'enip.cip.segment.epath'
	ab_tag = require 'enip.ab.tag'
end

local to_member = function(num)
	if TEST then
		print('to_member', num)
		return num
	end

	return logical:new(logical.TYPES.MEMBER_ID, tonumber(num))
end

local data_loaded, data = pcall(require, 'enip.cip.segment.data')
local to_path = function(path)
	if TEST then
		print('to_path', path)
		return path
	end
	return data:new(data.FORMATS.ANSI, path)
end

--local name = ((lpeg.R("az", "AZ")^1 * lpeg.R("az", "AZ", "09")^0)^1)
--local member = lpeg.R("09")^1 / to_member
local name = (((locale.alpha + '_')^1 * (locale.alnum + '_')^0)^1)
local member = locale.digit^1 / to_member
local path = name / to_path

local array_list = "[" * member * ("," + member)^0 * "]"
local elem = path * array_list^0
local chain_list = elem * ("." + elem)^0

local chain = lpeg.Ct(chain_list)

--local count = lpeg.R("09")^1 / tonumber
local count = locale.digit^1 / tonumber
local data_count = "{" * count * "}"

local echain = chain * data_count^0

--[[
local chain = lpeg.Cf(array_list, function(acc, newvalue)
	if type(acc) ~= 'table' then
		acc = {acc}
	else
		table.insert(acc, newvalue)
	end
end)
]]--

local parser = function(elem_name, type)
	local segs, count = echain:match(elem_name)
	if TEST then
		return segs, count
	end

	local path = epath:new()
	for _, seg in ipairs(segs) do
		path:append(seg)
	end

	return ab_tag:new(path, type, count)
end

if TEST then
	local function test(elem_name)
		print('element', elem_name)
		local t,c = parser(elem_name)
		print(t, c)
		for k, v in pairs(t) do
			print(k, v)
		end
	end

	test('MyTag')
	test('MyTag{2}')
	test('MyTag[1]')
	test('MyTag[1]{128}')
	test('MyTag[1].Point1')
	test('MyTag[1].Point1{128}')
	test('MyTag[1].Point1_122{128}')
	test('MyTag[1].Point1_1B22{128}')
	test('MyTag[1].Point1_B1B22{128}')
	test('MyTag.Struct.Point1')
	test('MyTag.StructArray[1].Point1')
	test('MyTag[1,2,3]')
	test('MyTag[1,2]')
	test('MyTag[1,2].Struct.Point1')
	test('MyTag[1,2].StructArray[2].Point1')
end


return parser
