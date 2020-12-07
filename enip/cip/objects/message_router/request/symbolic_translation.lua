local base = require 'enip.cip.objects.request.base'
local cip_tyeps = require 'enip.cip.types'
local types = require 'enip.cip.objects.message_router.types'
local object_path = require 'enip.cip.segment.object_path'

local req = base:subclass('enip.cip.objects.connection_manager.unconnected_send')

function req:initialize(instance, path)
	local instance = instance or 0
	base.initialize(self, types.SERVICE.SYMBOLIC_TRANSLATION, cip_types.OBJECT.MESSAGE_ROUTER, instance)
	self._path = path
end

function req:encode()
	assert(self._path, "Request is missing")

	return self._path:to_hex()
end

function req:decode(raw, index)
	local path = object_path:new()
	local index = path:from_hex(raw, index)
	self._path = path
	return index
end

function req:path()
	return self._path
end

return req
