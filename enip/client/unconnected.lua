local class = require 'middleclass'
local session = require 'enip.utils.session'
local client_base = require 'enip.client.base'
local command_data = require 'enip.command.data'
local item_types = require 'enip.command.item.types'
local item_parser = require 'enip.command.item.parser'
local cip_request = require 'enip.cip.request'
local cip_types = require 'enip.cip.types'
local buildin = require 'enip.cip.buildin'
local epath = require 'enip.cip.epath'

local client = class('LUA_ENIP_CLIENT_UNCONNECTED', client_base)

function client:gen_session()
	--- Session index is four bytes
	self._session_index = ((self._session_index or 0) + 1 ) % 0xFFFFFFFF
	local context = string.format('%08X', self._session_index)
	local new_session = session:new(self._session:session(), context)
	return new_session, self._session_index 
end

--- 0x4C READ TAG
function client:read_tag(tag_path, tag_type, reponse)
	--- make the an session for this 
	local session_obj = self:gen_session()

	local read_data = '\0\1\0\0'
	local path = epath:new(tag_path)
	local read_req = cip_request:new(cip_types.SERVICES.READ_TAG, path, read_data)

	--- Send RR Data Request
	local null = item_parser.build(item_types.NULL)
	local unconnected = item_parser.build(item_types.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(msg, err)
		print('got reply')
		--- TODO: using the tag_type to 
	end)
end

--- 0x4d WRITE_TAG
function client:write_tag(tag_path, tag_type, tag_value)
	--- make the an session for this 
	local session_obj = self:gen_session()

	local write_data = buildin:new(tag_type, tag_value)
	local path = epath:new(tag_path)
	local read_req = cip_request:new(cip_types.SERVICES.WRITE_TAG, path, write_data)

	--- Send RR Data Request
	local null = item_parser.build(item_types.NULL)
	local unconnected = item_parser.build(item_types.UNCONNECTED, read_req)

	local data = command_data:new({null, unconnected})

	return self:send_rr_data(session_obj, data, function(msg, err)
		print('got reply')
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
