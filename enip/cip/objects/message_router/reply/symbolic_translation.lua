local base = require 'enip.cip.reply.base'
local cip_tyeps = require 'enip.cip.types'
local types = require 'enip.cip.objects.message_router.types'
local object_path = require 'enip.cip.segment.object_path'

local resp = base:subclass('enip.cip.objects.message_router.symbolic_translation')

function resp:initialize(instance, path)
	local instance = instance or 0
	local request_path = object_path.easy_create(cip_types.OBJECT.MESSAGE_ROUTER, instance)
	base.initialize(self, types.SYMBOLIC_TRANSLATION, request_path)
	self._path = path
end

function resp:encode()
	assert(self._path, "Request is missing")

	return self._path:to_hex()
end

function resp:decode(raw, index)
	local path = object_path:new()
	local index = path:from_hex(raw, index)
	self._path = path
	return index
end

function resp:path()
	return self._path
end

return resp
