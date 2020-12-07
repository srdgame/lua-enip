local base = require 'enip.command.item.sockaddr'

local addr = base:subclass('enip.command.item.sock_addr_c')


function addr:initialize(info)
	base.initialize(base.TYPES.SOCK_ADDR_C, info)
end

return addr
