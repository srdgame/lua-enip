local class = require 'middleclass'
local session = require 'cip.session'
local enip_conn_path = require 'enip.conn_path'

local client = class('LUA_ENIP_CLIENT')

function client:initialize(conn_path)
	self._conn_path = enip_conn_path(conn_path)
	self._session = session:new()
end

function client:conn_path()
	return self._conn_path
end

--- Start the Register Session stuff
function client:connect()
	assert(false, "Not implmented!")
end

function client:register_session()
	local rs = require 'cip.request.register_session'
	local msg = rs:new(self._session)
	return self:request(msg, function(resp, err)
		if resp then
			self._session:from_hex(resp)
			return true
		else
			return nil, err
		end
	end)
end

--- Send the unregister session message and cleanup connection
function client:close()
	assert(false, "Not implmented!")
end

function client:unregister_session()
	local us = require 'cip.request.unregister_session'
	local msg = us:new(self._session)
	--- There is no response for this unregister session request.
	return self:request(msg)
end

--[[
-- message is the ENIP message
-- response is nil when the request does not need any response replied from server
--]]
function client:request(msg, response)
end

return client
