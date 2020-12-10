local session = require 'enip.utils.session'
local base = require 'enip.client.base'
local cip_types = require 'enip.cip.types'
local command = require 'enip.command.base'
local command_data = require 'enip.command.data'
local command_item = require 'enip.command.item.base'
local cip_req_multi = require 'enip.cip.request.multi_srv_pack'
local data_simple = require 'enip.cip.segment.data_simple'
local object_path = require 'enip.cip.segment.object_path'
local timing = require 'enip.cip.objects.connection_manager.connection_timing'
local unconnected_send = require 'enip.cip.objects.connection_manager.request.unconnected_send'

local client = base:subclass('enip.client.unconnected')

function client:gen_session()
	--- Session index is four bytes
	self._session_index = ((self._session_index or 0) + 1 ) % 0xFFFFFFFF
	local context = string.format('%08X', self._session_index)
	local new_session = session:new(self._session:session(), context)
	return new_session, self._session_index 
end

function client:unconnected_request(request, response)
	--- make the an session for identify the request
	local session_obj = self:gen_session()

	--- Send RR Data Request
	local null = command_item.build(command_item.TYPES.NULL) -- NULL Address item required by Unconnected Message
	local unconnected = command_item.build(command_item.TYPES.UNCONNECTED, request)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(reply, err)
		-- ENIP reply status checking
		if reply:status() ~= command.STATUS.SUCCESS then

			print(reply:error_info())

			local skynet = require 'skynet'
			while true do
				skynet.sleep(1000)
			end

			if reply:status() == command.STATUS.INVALID_SESSION then
				self:invalid_session()
			end
			return response(nil, reply:error_info())
		end

		--- ENIP command data
		local reply_data = reply:data()

		--- Command Items
		local items = reply_data:items()
		if not items or #items < 2 then
			return response(nil, "Error command data items count")
		end

		--- The first item must be NULL Address Item
		local null_item = items[1]
		if null_item:type() ~= command_item.TYPES.NULL then
			return response(nil, "Unconnected send needs to have NULL Address Item as the first item")
		end

		--- The second item must be Unconnected Data Item
		local un_data = items[2]
		if un_data:type() ~= command_item.TYPES.UNCONNECTED then
			return response(nil, 'ERROR: The second item should be UNCONNECTED')
		end

		--- Get the item CIP reply
		local cip_reply = un_data:data()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
		end

		return response(cip_reply)
	end)
end

function client:single_request(request, response)
	return self:unconnected_request(request, response)
end

function client:multi_request(requests, response)
	--- The requests performed on Message Router #1
	local message_router = object_path.easy_create(cip_types.OBJECT.MESSAGE_ROUTER, 1)
	local read_req = cip_req_multi:new(message_router, requests)

	--- Request connection_manager #1
	local route_path = self:route_path()
	local send_obj = unconnected_send:new(1, timing:new(), read_req, route_path)

	return self:unconnected_request(read_req, function(cip_reply, err)
		if not cip_reply then
			return response(nil, err)
		end

		if cip_reply:service() ~= cip_types.SERVICES.MULTI_SRV_PACK then
			return response(nil, 'ERROR: CIP reply service code error')
		end

		--- Get the CIP data
		local replies = cip_reply:replies()
		if replies and #replies > 0 then
			--- callback
			return response(replies)
		end

		--- All errors through error_info
		return response(nil, cip_reply:error_info())
	end)
end

return client
