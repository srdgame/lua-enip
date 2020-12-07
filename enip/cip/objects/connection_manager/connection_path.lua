local base = require 'enip.serializable'

local obj = base:subclass('enip.cip.objects.connection_mananager.connection_path')

---
-- V1Ch1: 3-5.5.1.10
--
-- routing is segment.port
-- info is segment.logical.special
-- paths is segment.object_path or segment.epath
-- TODO: Need implement this
--
function obj:initialize(routing, info, paths)
	base.initialize(self)
	self._routing = routing
	self._info = info
	self._paths = paths
end

function obj:to_hex()
	return self._routing:to_hex()..self._info:to_hex()..self._paths:to_hex()
end

function obj:from_hex(raw, index)
	assert(nil, "Not implemented")
	return index
end

return obj
