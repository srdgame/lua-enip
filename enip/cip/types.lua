
---[[
-- DATA
--]]

local SERVICES = {}
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

local function status_to_string(status)
	return status_strings[status] or 'Unknown status code : '..status
end


return {
	SERVICES = SERVICES,
	STATUS = STATUS,
	status_to_string = status_to_string,
}
