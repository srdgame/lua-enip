local class = require 'middleclass'
local session = require 'enip.session'
local client_base = require 'enip.client.base'

local client = class('LUA_ENIP_CLIENT_UNCONNECTED', client_base)


function client:gen_session()
	--- Session index is four bytes
	self._session_index = ((self._session_index or 0) + 1 ) % 0xFFFFFFFF
	local context = string.format('%08X', self._session_index)
	local new_session = session:new(self._session:session(), context)
	return self._session_index, new_session
end

--- 0x4C READ TAG
function client:read_tag(tag_path, tag_type, reponse)
	--- make the an session for this 
	local session_index, session_obj = self:gen_session()
	self._session_map[session_index] = {
		session = session_obj,
		request = msg,
		response = response
	}

	--- Send RR Data Request
	return self:send_rr_data(session_obj, cip, response)
end

--- 0x4d WRITE_TAG
function client:write_tag(tag_path, tag_type, tag_value)
end

--- 0x52 READ_FRG
function client:read_frg(tags)
end

--- 0x53 WRITE_FRG
function client:write_frg(tags)
end

return client
