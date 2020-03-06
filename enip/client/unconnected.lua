local class = require 'middleclass'
local session = require 'enip.utils.session'
local client_base = require 'enip.client.base'
local command_data = require 'enip.command.data'
local item_types = require 'enip.command.item.types'
local item_parser = require 'enip.command.item.parser'
local cip_request = require 'enip.cip.request'
local cip_types = require 'enip.cip.types'
local buildin = require 'enip.cip.segment.buildin'
local seg_path = require 'enip.cip.segment.path'

local client = class('LUA_ENIP_CLIENT_UNCONNECTED', client_base)

function client:gen_session()
	--- Session index is four bytes
	self._session_index = ((self._session_index or 0) + 1 ) % 0xFFFFFFFF
	local context = string.format('%08X', self._session_index)
	local new_session = session:new(self._session:session(), context)
	return new_session, self._session_index 
end

--- 0x4C READ TAG
function client:read_tag(tag_path, tag_type, response)
	--- make the an session for this 
	local session_obj = self:gen_session()

	local read_data = '\1\0'
	local path = seg_path:new(tag_path)
	local read_req = cip_request:new(cip_types.SERVICES.READ_TAG, path, read_data)

	--- Send RR Data Request
	local null = item_parser.build(item_types.NULL)
	local unconnected = item_parser.build(item_types.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(reply, err)
		if reply:status() ~= 0 then
			return response(nil, "ERROR Status")
		end

		local command_data = reply:data()

		local item, err = command_data:find(item_types.UNCONNECTED)
		if not item then
			return response(nil, 'ERROR: Item not found')
		end

		local cip_reply = item:cip()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
		end

		if cip_reply:status() ~= 0 then
			local sts = cip_types.status_to_string(cip_reply:status())
			return response(nil, 'ERROR: CIP reply status error:', sts or cip_reply:status())
		end

		local cip_data = cip_reply:data()
		if not cip_data then
			return reponse(nil, 'ERROR: CIP reply has no data')
		end

		return response(cip_data:value())
	end)
end

--- 0x4d WRITE_TAG
function client:write_tag(tag_path, tag_type, tag_value, response)
	--- make the an session for this 
	local session_obj = self:gen_session()

	local write_data = buildin:new(tag_type, tag_value)
	local path = seg_path:new(tag_path)
	local read_req = cip_request:new(cip_types.SERVICES.WRITE_TAG, path, write_data)

	--- Send RR Data Request
	local null = item_parser.build(item_types.NULL)
	local unconnected = item_parser.build(item_types.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(msg, err)
		-- print('got reply')
		--- TODO: Parse the result
	end)
end

--- 0x52 READ_FRG
function client:read_frg(tags)
end

--- 0x53 WRITE_FRG
function client:write_frg(tags)
end

return client
