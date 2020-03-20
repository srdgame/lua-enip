local class = require 'middleclass'
local session = require 'enip.utils.session'
local enip_conn_path = require 'enip.utils.conn_path'
local route_path = require 'enip.cip.segment.route_path'
local cip_types = require 'enip.cip.types'

local client = class('LUA_ENIP_CLIENT')

local default_route_path = '1/0'

function client:initialize(conn_path, route_path)
	self._conn_path = enip_conn_path(conn_path)
	self._route_path = enip_route_path(route_path or default_route_path)
	self._session = session:new()
end

function client:conn_path()
	return self._conn_path
end

function client:route_path()
	return route_path:new(self._route_path:port(), self._route_path:link())
end

--- Start the Register Session stuff
function client:connect()
	assert(false, "Not implmented!")
end

function client:register_session()
	local rs = require 'enip.request.reg_session'
	local req = rs:new(self._session)
	return self:request(req, function(resp, err)
		if resp then
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

function client:get_reply_value(cip_reply, data_type)
	--- Get the CIP reply status
	if cip_reply:status() ~= cip_types.STATUS.OK then
		return nil, cip_reply:error_info()
	end

	--- Get the CIP data
	local cip_data = cip_reply:data()
	if not cip_data then
		return nil, 'ERROR: CIP reply has no data'
	end

	-- TODO: check about the data_type???

	--- callback
	return cip_data:value()
end

return client
