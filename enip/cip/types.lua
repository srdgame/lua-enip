
---[[
-- DATA
--]]

local SERVICES = {}
--- Command services
SERVICES.GET_ATTRS_ALL		= 0x01
SERVICES.SET_ATTRS_ALL		= 0x02
SERVICES.GET_ATTR_LIST		= 0x03
SERVICES.SET_ATTR_LIST		= 0x04
SERVICES.RESET				= 0x05
SERVICES.START				= 0x06
SERVICES.STOP				= 0x07
SERVICES.CREATE				= 0x08
SERVICES.DELETE				= 0x09
SERVICES.MULTI_SRV_PACK		= 0x0a
SERVICES.APPLY_ATTRS		= 0x0d
SERVICES.GET_ATTR_SINGLE	= 0x0e
SERVICES.SET_ATTR_SINGLE	= 0x10
SERVICES.FIND_NEXT_OBJ_INST	= 0x11
SERVICES.ERROR_RESP			= 0x14
SERVICES.RESTORE			= 0x15
SERVICES.SAVE				= 0x16
SERVICES.NOP				= 0x17
SERVICES.GET_MEMBER			= 0x18
SERVICES.SET_MEMBER			= 0x19
SERVICES.INSERT_MEMBER		= 0x1a
SERVICES.REMOVE_MEMBER		= 0x1b
--- Logix services
SERVICES.READ_TAG			= 0x4c
SERVICES.WRITE_TAG			= 0x4d
SERVICES.READ_FRG			= 0x52
SERVICES.WRITE_FRG			= 0x53

SERVICES.REPLY				= 0x80

local STATUS = {}

STATUS.OK					= 0x00
STATUS.ERR_NOT_SUPPORTED	= 0x01
STATUS.ERR_MEMEORY_LIMIT	= 0x02
STATUS.ERR_INVALID_MSG		= 0x03
STATUS.ERR_PATH				= 0x04
STATUS.ERR_INVALID_INST		= 0x05
STATUS.ERR_SERVICE_ERR		= 0x08
STATUS.ERR_CONFLICT_STATE	= 0x10
STATUS.ERR_OBJECT_STATE		= 0x0c
STATUS.ERR_READ_ONLY		= 0x0e
STATUS.ERR_SESSION_HANDLE	= 0x63
STATUS.ERR_INVLIAD_LEN		= 0x64
STATUS.ERR_PROTOCOL_VER		= 0x69

local status_strings = {
	[0x00] = 'Successs',
	[0x01] = 'The sender issued an invalid or unsupported encapsulation command.',
	[0x02] = 'Insufficient memory resources in the receiver to handle the command.',
	[0x03] = 'Poorly formed or incorrect data in the data portion of the encapsulation message.',
	[0x04] = 'Path syntax error.',
	[0x05] = 'Instance undefined.',
	[0x08] = 'Unimplemented service.',
	[0x10] = 'Device state conflict.',
	[0x0c] = 'Wrong object state.',
	[0x0e] = 'Attempt to set a read-only attribute.',
	[0x64] = 'An originator used an invalid session handle when sending an encapsulation message to the target.',
	[0x65] = 'The target received a message of invalid length.',
	[0x69] = 'Unsupported encapsulation protocol revision.',
}

local general_status_strings = {
	[0x00] = 'Success',
	[0x01] = 'Connection failure',
	[0x02] = 'Resource unavailable',
	[0x03] = 'Invalid parameter value',
	[0x04] = 'Path segment error',
	[0x05] = 'Path destination unknown',
	[0x06] = 'Partial transfer',
	[0x07] = 'Connection lost',
	[0x08] = 'Service not supported',
	[0x09] = 'Invalid attribute value',
	[0x0a] = 'Attribute list error',
	[0x0b] = 'Already in requested mode/state',
	[0x0c] = 'Object state conflict',
	[0x0d] = 'Object already exists',
	[0x0e] = 'Attribute not settable',
	[0x0f] = 'Privilege violation',
	[0x10] = 'Device state conflict',
	[0x11] = 'Reply data too large',
	[0x12] = 'Fragmentation of a primitive value',
	[0x13] = 'Not enough data',
	[0x14] = 'Attribute not supported',
	[0x15] = 'Too much data',
	[0x16] = 'Object does not exist',
	[0x17] = 'Service fragmentation sequence not in progress',
	[0x18] = 'No stored attribute data',
	[0x19] = 'Store operation failure',
	[0x1a] = 'Routing failure, request packet too large',
	[0x1b] = 'Routing failure, response packet too large',
	[0x1c] = 'Missing attribute list entry data',
	[0x1d] = 'Invalid attribute value list',
	[0x1e] = 'Embedded service error',
	[0x1f] = 'Vendor specific error',
	[0x20] = 'Invalid parameter',
	[0x21] = 'Write-once value or medium already written',
	[0x22] = 'Invalid Reply Received',
	[0x23] = 'Reserved by CIP for future extensions',
	[0x24] = 'Reserved by CIP for future extensions',
	[0x25] = 'Key Failure in path',
	[0x26] = 'Path Size Invalid',
	[0x27] = 'Unexpected attribute in list',
	[0x28] = 'Invalid Member ID',
	[0x29] = 'Member not settable',
	[0x2a] = 'Group 2 only server general failure',
}

local function status_to_string(status)
	return status_strings[status] or general_status_strings[status] or 'Unknown status code : '..status
end


return {
	SERVICES = SERVICES,
	STATUS = STATUS,
	status_to_string = status_to_string,
}
