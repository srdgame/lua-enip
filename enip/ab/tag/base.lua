local class = 'middleclass'

local tag = class('enip.ab.tag')

function tag:initialize(path, type)
	self._path = path
	self._type = type
end

function tag:path()
	return self._path
end

function tag:type()
	return self._type
end

function tag:count()
	return 1 --- TODO:
end

return tag
