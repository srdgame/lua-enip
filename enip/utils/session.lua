---- CIP Session
-- Session Handle: The returned handle from reply of RegisterSession
-- Context: BYTE[8]
-- 

local class = require 'middleclass'

local session = class('enip.utils.session')

function session:initialize(session, context)
	self._session = session or 0
	self._context = context or '@FreeIOE'
end


function session:session()
	return self._session
end

function session:context()
	return self._context
end

return session

