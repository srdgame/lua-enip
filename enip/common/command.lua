
local class = require 'middleclass'
local header = require 'enip.command.header'

local base = class('enip.command.base')

base.static.header = header

function base:initialize(session, command, length, status)
	self._header = header:new(session, command, length, status)
	assert(session == self._header:session())
end

function base:__tostring()
	return string.format('ENIP Comamnd Object:\nHDR:\t%s\n', tostring(self._header))
end

function base:from_hex(raw, index)
	index = self._header:from_hex(raw, index)

	local hdr_len = self._header:len()
	local data_len = self._header:length()

	if self.decode then
		--[[
		local basexx = require 'basexx'
		print(index, basexx.to_hex(string.sub(raw, index)))
		]]--
		index = self:decode(raw, index)
	end

	return index
end

function base:to_hex()
	if self.encode then
		local data = self:encode()
		self._header:set_length(string.len(data))
		return self._header:to_hex()..data
	else
		return self._header:to_hex()
	end
end

function base:header()
	return self._header
end

function base:command()
	return self._header:command()
end

function base:status()
	return self._header:status()
end

function base:session()
	return self._header:session()
end

return base
