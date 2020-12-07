local session = require 'enip.utils.session'
local base = require 'enip.client.base'
local command_data = require 'enip.command.data'
local command_item = require 'enip.command.item.base'
local read_tag = require 'enip.ab.request.read_tag'
local read_frg = require 'enip.ab.request.read_frg'
local cip_req_multi = require 'enip.cip.request.multi_srv_pack'
local write_tag = require 'enip.ab.request.write_tag'
local cip_types = require 'enip.cip.types'
local ab_types = require 'enip.ab.types'
local data_simple = require 'enip.cip.segment.data_simple'
local object_path = require 'enip.cip.segment.object_path'
local timing = require 'enip.cip.objects.connection_manager.connection_timing'
local unconnected_send = require 'enip.cip.objects.connection_manager.request.unconnected_send'

local client = base:subclass('enip.client.unconnected')

local function convert_tag_type_to_fmt(tag_type)
	local data_type = type(tag_type) == 'string' and data_elem.TYPES[tag_type] or tag_type
	return data_type, data_elem.type_to_fmt(data_type)	
end

function client:gen_session()
	--- Session index is four bytes
	self._session_index = ((self._session_index or 0) + 1 ) % 0xFFFFFFFF
	local context = string.format('%08X', self._session_index)
	local new_session = session:new(self._session:session(), context)
	return new_session, self._session_index 
end

--- 0x4C READ TAG
function client:read_tag(tag_path, tag_type, tag_count, response)
	--- make the an session for identify the request
	local session_obj = self:gen_session()
	local data_type, data_type_fmt = convert_tag_type_to_fmt(tag_type)

	local read_req = read_tag:new(tag_path, tag_count)

	--- Send RR Data Request
	local null = command_item.build(comand_item.TYPES.NULL) -- NULL Address item required by Unconnected Message
	local unconnected = command_item.build(comand_item.TYPES.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(reply, err)
		-- ENIP reply
		if reply:status() ~= 0 then
			return response(nil, "ERROR Status")
		end

		--- ENIP command data
		local command_data = reply:data()

		--- Find the unconnected item
		local item, err = command_data:find(command_item.TYPES.UNCONNECTED)
		if not item then
			return response(nil, 'ERROR: Item not found')
		end

		--- Get the item CIP reply
		local cip_reply = item:cip()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
		end

		return response(self:get_reply_value(cip_reply, tag_type))
	end)
end

--- 0x52 REAG TAG FREGMENT
function client:read_tags(tags, response)
	--- make the an session for identify the request
	local session_obj = self:gen_session()

	local requests = {}
	for _, v in ipairs(tags) do
		requests[#requests + 1] = read_tag:new(v.path, v.count or 1)
	end

	--- The requests performed on Message Router #1
	local message_router = object_path.easy_create(cip_types.OBJECT.MESSAGE_ROUTER, 1)
	local read_req = cip_req_multi:new(message_router, requests)

	--- Request connection_manager #1
	local route_path = self:route_path()
	local send_obj = unconnected_send:new(1, timing:new(), read_req, route_path)

	--- Send RR Data Request
	local null = command_item.build(command_item.TYPES.NULL)
	local unconnected = command_item.build(command_item.TYPES.UNCONNECTED, send_obj)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(reply, err)
		-- ENIP reply
		if reply:status() ~= 0 then
			return response(nil, "ERROR Status")
		end

		--- ENIP command data
		local command_data = reply:data()

		--- Find the unconnected item
		local item, err = command_data:find(command_item.TYPES.UNCONNECTED)
		if not item then
			return response(nil, 'ERROR: Item not found')
		end

		--- Get the item CIP reply data
		local cip_reply = item:data()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
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

-- 0x52 Read the tag by offset and count
function client:read_frg(path, count, offset, response)
	-- TODO: Is this only happens with AB PLC????
end

--- 0x4d WRITE_TAG
function client:write_tag(tag_path, tag_type, tag_value, response)
	--- make the an session for this 
	local session_obj = self:gen_session()

	local data_type, data_type_fmt = convert_tag_type_to_fmt(tag_type)
	local write_req = cip_write_tag:new(tag_path, tag_type, tag_value)

	--- Send RR Data Request
	local null = item_parser.build(command_item.TYPES.NULL)
	local unconnected = item_parser.build(command_item.TYPES.UNCONNECTED, write_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(reply, err)
		-- ENIP reply
		if reply:status() ~= 0 then
			return response(nil, "ERROR Status")
		end

		--- ENIP command data
		local command_data = reply:data()
		local items = command_data:items()
		if not items or #items < 2 then
			return response(nil, "Error command data items count")
		end
		local null_item = items[1]
		if null_item:type() ~= command_item.TYPES.NULL then
			return response(nil, "Unconnected send needs to have NULL Address Item as the first item")
		end
		local unconnectd_data = items[2]
		if unconnectd_data:type() ~= command_item.TYPES.UNCONNECTED then
			return response(nil, 'ERROR: The second item should be UNCONNECTED')
		end

		--- Get the item CIP reply
		local cip_reply = item:data()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
		end

		--- Get the CIP reply status
		if cip_reply:status() ~= 0 then
			--[[
			local sts = cip_types.status_to_string(cip_reply:status())
			return response(nil, 'ERROR: '..(sts or 'STATUS ['..cip_reply:status()..']'))
			]]--
			return response(nil, cip_reply:error_info())
		end

		-- TODO: Will be there data???

		--- Get the CIP data
		local cip_data = cip_reply:data()
		if not cip_data then
			return reponse(nil, 'ERROR: CIP reply has no data')
		end

		--- callback
		return response(cip_data:replies())
	end)
end

--- 0x52 READ_FRG
function client:read_frg(tags)
end

--- 0x53 WRITE_FRG
function client:write_frg(tags)
end

return client
