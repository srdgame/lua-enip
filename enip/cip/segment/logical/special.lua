local class = require 'middleclass'
local serializable = require 'enip.serializable'

return serializable.easy_create('enip.cip.segment.logical.special', {
	{ name = 'vendor_id', fmt = '<I2' },
	{ name = 'device_type', fmt = '<I2'},
	{ name = 'product_code', fmt = '<I2'},
	{ name = 'major_revision', fmt = '<c1'},
	{ name = 'minor_revision', fmt = '<I1'},
})
