local segs = {
	'PORT',
	'LOGICAL',
	'NETWORK',
	'SYMBOLIC',
	'DATA',
	'DATA_TYPE_C',
	'DATA_TYPE_E',
	'RESERVED',
}

return function(seg)
	local sn = string.byte(seg)
	sn = (sn & 0xE0) >> 5

	return segs[sn]
end
