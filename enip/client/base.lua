local class = require 'middleclass'
local cip_types = require 'enip.cip.types'
local cip_port = require 'enip.cip.segment.port'

local command = require 'enip.command.base'
local session = require 'enip.utils.session'
local enip_conn_path = require 'enip.utils.conn_path'
local enip_route_path = require 'enip.utils.route_path'

local client = class('enip.client.base')

local default_route_path = '1,0' -- port 1 link 0

function client:initialize(conn_path, route_path)
	self._conn_path = enip_conn_path(conn_path)
	self._route_path = enip_route_path(route_path or default_route_path)
	self._route_path_o = nil
	self._session = session:new()
end

function client:conn_path()
	return self._conn_path
end

function client:route_path()
	if self._route_path_o then
		return self._route_path_o
	end
	local path = self._route_path
	local obj = cip_port:new(path:port(), path:link())
	self._route_path_o = obj
	return obj
end

--- Start the Register Session stuff
function client:connect()
	assert(false, "Not implmented!")
end

function client:register_session()
	local rs = require 'enip.request.reg_session'
	local req = rs:new(session:new())
	return self:request(req, function(resp, err)
		if resp then
			if resp:status() ~= command.STATUS.SUCCESS then
				return nil, resp:error_info()
			end
			self._session = resp:session()
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

function client:invalid_session()
	--- The server replies invalid session enip command status
	self:register_session()
end

function client:unregister_session()
	local us = require 'enip.request.unreg_session'
	local req = us:new(self._session)
	--- There is no response for this unregister session request.
	return self:request(req)
end

--[[
-- message is the ENIP message
-- response is nil when the request does not need any response replied from server
--  function(reply, err) end
--]]
function client:request(request, response)
	assert(false, "Not implemented")
end

function client:send_rr_data(session, data, response)
	local send_rr_data = require 'enip.request.send_rr_data'

	local req = send_rr_data(session, data)
	return self:request(req, response)
end

function client:send_unit_data(session, data, response)
	local send_unit_data = require 'enip.request.send_unit_data'
	local req = send_unit_data(session, data)
	return self:request(req, response)
end

return client
