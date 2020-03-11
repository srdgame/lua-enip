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

local function convert_tag_type_to_fmt(tag_type)
	local data_type = type(tag_type) == 'string' and buildin.TYPES[tag_type] or tag_type
	return data_type, buildin.type_to_fmt(data_type)	
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

	--local read_data = buildin:new(buildin.TYPES.UINT, tag_count)
	local read_data = string.pack('<I2', tag_count)
	local path = seg_path:new(tag_path)
	local read_req = cip_request:new(cip_types.SERVICES.READ_TAG, path, read_data)

	--- Send RR Data Request
	local null = item_parser.build(item_types.NULL)
	local unconnected = item_parser.build(item_types.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(reply, err)
		-- ENIP reply
		if reply:status() ~= 0 then
			return response(nil, "ERROR Status")
		end

		--- ENIP command data
		local command_data = reply:data()

		--- Find the unconnected item
		local item, err = command_data:find(item_types.UNCONNECTED)
		if not item then
			return response(nil, 'ERROR: Item not found')
		end

		--- Get the item CIP reply
		local cip_reply = item:cip()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
		end

		--- Get the CIP reply status
		if cip_reply:status() ~= 0 then
			local sts = cip_types.status_to_string(cip_reply:status())
			return response(nil, 'ERROR: '..(sts or 'STATUS ['..cip_reply:status()..']'))
		end

		--- Get the CIP data
		local cip_data = cip_reply:data()
		if not cip_data then
			return reponse(nil, 'ERROR: CIP reply has no data')
		end

		-- TODO: check about the tag_type???

		--- callback
		return response(cip_data:value())
	end)
end

--- 0x52 REAG TAG FREGMENT
function client:reag_tag_frq(tag_path, tag_count, offset, response)
	--- make the an session for identify the request
	local session_obj = self:gen_session()
	local data_type, data_type_fmt = convert_tag_type_to_fmt(tag_type)

	--local read_data = buildin:new(buildin.TYPES.UINT, tag_count)
	local read_data = string.pack('<I2I4', tag_count, offset)
	local path = seg_path:new(tag_path)
	local read_req = cip_request:new(cip_types.SERVICES.READ_TAG, path, read_data)

	--- Send RR Data Request
	local null = item_parser.build(item_types.NULL)
	local unconnected = item_parser.build(item_types.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(reply, err)
		-- ENIP reply
		if reply:status() ~= 0 then
			return response(nil, "ERROR Status")
		end

		--- ENIP command data
		local command_data = reply:data()

		--- Find the unconnected item
		local item, err = command_data:find(item_types.UNCONNECTED)
		if not item then
			return response(nil, 'ERROR: Item not found')
		end

		--- Get the item CIP reply
		local cip_reply = item:cip()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
		end

		--- Get the CIP reply status
		if cip_reply:status() ~= 0 then
			local sts = cip_types.status_to_string(cip_reply:status())
			return response(nil, 'ERROR: '..(sts or 'STATUS ['..cip_reply:status()..']'))
		end

		--- Get the CIP data
		local cip_data = cip_reply:data()
		if not cip_data then
			return reponse(nil, 'ERROR: CIP reply has no data')
		end

		-- TODO: check about the tag_type???

		--- callback
		return response(cip_data:value())
	end)
end

--- 0x4d WRITE_TAG
function client:write_tag(tag_path, tag_type, tag_value, response)
	--- make the an session for this 
	local session_obj = self:gen_session()

	local data_type, data_type_fmt = convert_tag_type_to_fmt(tag_type)

	local write_obj = buildin:new(data_type, tag_value)
	local write_data = string.pack('<I2I2', data_type_fmt, 1)..write_obj:to_hex()

	local path = seg_path:new(tag_path)
	local read_req = cip_request:new(cip_types.SERVICES.WRITE_TAG, path, write_data)

	--- Send RR Data Request
	local null = item_parser.build(item_types.NULL)
	local unconnected = item_parser.build(item_types.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(msg, err)
		-- ENIP reply
		if reply:status() ~= 0 then
			return response(nil, "ERROR Status")
		end

		--- ENIP command data
		local command_data = reply:data()

		--- Find the unconnected item
		local item, err = command_data:find(item_types.UNCONNECTED)
		if not item then
			return response(nil, 'ERROR: Item not found')
		end

		--- Get the item CIP reply
		local cip_reply = item:cip()
		if not cip_reply then
			return response(nil, 'ERROR: CIP reply not found')
		end

		--- Get the CIP reply status
		if cip_reply:status() ~= 0 then
			local sts = cip_types.status_to_string(cip_reply:status())
			return response(nil, 'ERROR: '..(sts or 'STATUS ['..cip_reply:status()..']'))
		end

		-- TODO: Will be there data???

		--- Get the CIP data
		local cip_data = cip_reply:data()
		if not cip_data then
			return reponse(nil, 'ERROR: CIP reply has no data')
		end

		--- callback
		return response(cip_data:value())
	end)
end

--- 0x52 READ_FRG
function client:read_frg(tags)
end

--- 0x53 WRITE_FRG
function client:write_frg(tags)
end

return client
