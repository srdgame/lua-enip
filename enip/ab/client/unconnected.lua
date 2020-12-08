--- The client implemented by socketchannel of skynet
local parser = require 'enip.utils.parser'
local read_tag = require 'enip.ab.request.read_tag'
local read_frg = require 'enip.ab.request.read_frg'
local write_tag = require 'enip.ab.request.write_tag'
local ab_types = require 'enip.ab.types'

local base = require 'enip.client.unconnected'

local client = base:subclass('enip.ab.client.unconnected')

local ab_reply_parser = parser:new(ab_types.SERVICES, 'enip.ab.reply')

function client:map_response(response)
	local response = response
	return function(cip_reply, err)
		if cip_reply and cip_reply.is_done then
			if not cip_reply:is_done() then
				assert(cip_reply:append(ab_reply_parser))
				if not cip_reply:is_done() then
					return response(nil, "Parser error")
				end
			end
			return response(cip_reply:data())
		else
			return response(cip_reply, err)
		end
	end
end

function client:map_response_multi(response)
	local response = response
	return function(replies, err)
		if not replies then
			return response(nil, err)
		end
		local data = {}
		for _, cip_reply in ipairs(replies) do
			if cip_reply and cip_reply.is_done then
				if not cip_reply:is_done() then
					assert(cip_reply:append(ab_reply_parser))
					if not cip_reply:is_done() then
						return response(nil, "Parser error")
					end
				end
				table.insert(data, cip_reply:data())
			else
				table.insert(data, cip_reply)
			end
		end
		return response(data)
	end
end

--- Tags
--
function client:read_tags(tags, response)
	local requests = {}
	for _, v in ipairs(tags) do
		requests[#requests + 1] = read_tag:new(v:path(), v:count())
	end

	return self:multi_request(requests, self:map_response_multi(response))
end

function client:read_tag(path, count, response)
	local read_req = read_tag:new(path, count)
	return self:single_request(read_req, self:map_response(response))
end

function client:write_tag(path, type, value, response)
	local write_req = cip_write_tag:new(tag_path, tag_type, tag_value)
	return self:single_request(write_req, self:map_response(response))
end

return client
