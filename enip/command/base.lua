
local class = require 'middleclass'
local header = require 'enip.command.header'

local cmd = class('LUA_ENIP_COMMAND_MSG')

cmd.static.header = header

function cmd:initialize(session, command, length, status)
	self._header = header:new(session, command, length, status)
	assert(session == self._header:session())
end

function cmd:__tostring()
	return string.format('ENIP_COMMAND:\nHDR:%s\n', tostring(self._header))
end

function cmd:from_hex(raw, index)
	index = self._header:from_hex(raw, index)

	local hdr_len = self._header:len()
	local data_len = self._header:length()

	if self.decode then
		index = self:decode(raw, index)
	end

	return index
end

function cmd:to_hex()
	if self.encode then
		local data = self:encode()
		self._header:set_length(string.len(data))
		return self._header:to_hex()..data
	else
		return self._header:to_hex()
	end
end

function cmd:header()
	return self._header
end

function cmd:command()
	return self._header:command()
end

function cmd:status()
	return self._header:status()
end

function cmd:session()
	return self._header:session()
end

return cmd
