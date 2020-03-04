
local class = require 'middleclass'
local header = require 'enip.command.header'

local cmd = class('LUA_ENIP_COMMAND_MSG')

cmd.static.header = header

function cmd:initailize(session, command, status)
	self._header = header:new(session, command, len, status)
end

function cmd:__tostring()
	return string.format('ENIP_COMMAND:\nHDR:%s\n', tostring(self._header))
end

function cmd:from_hex(raw, index)
	local index = self._header:from_hex(raw, index)

	local hdr_len = self._header:len()
	local data_len = self._header:length()
	--local data = string.sub(raw, index + hdr_len, index + hdr_len + data_len)
	--
	local data_index = index + hdr_len
	if self.decode then
		index = self:decode(raw, idnex + hdr_len)
	end

	assert(index == data_index + data_len + 1)
	return index
end

function cmd:to_hex()
	if self.encode then
		return self._header:to_hex()..self:encode()
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
