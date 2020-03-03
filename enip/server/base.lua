local class = require 'middleclass'

local server = class('LUA_ENIP_SERVER')

function server:initialize(addr)
	self._addr = addr
end

function server:start()
	
end

function server:stop()
end

function server:register()
end

return server
