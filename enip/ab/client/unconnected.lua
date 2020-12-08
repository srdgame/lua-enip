--- The client implemented by socketchannel of skynet
local read_tag = require 'enip.ab.request.read_tag'
local read_frg = require 'enip.ab.request.read_frg'
local write_tag = require 'enip.ab.request.write_tag'
local ab_types = require 'enip.ab.types'

local base = require 'enip.client.unconnected'

local client = base:subclass('enip.ab.client.unconnected')

--- Tags
--
function client:read_tags(tags, response)
	local requests = {}
	for _, v in ipairs(tags) do
		requests[#requests + 1] = read_tag:new(v:path(), v:count())
	end

	return self:multi_request(requests, response)
end

function client:read_tag(path, count, response)
	local read_req = read_tag:new(path, count)
	return self:single_request(read_req, response)
end

function client:write_tag(path, type, value, response)
	local write_req = cip_write_tag:new(tag_path, tag_type, tag_value)
	return self:single_request(write_req, response)
end

return client
