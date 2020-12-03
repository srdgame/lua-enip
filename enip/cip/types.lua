
---[[
-- DATA
--]]

--- Command services
local SERVICES = {
	GET_ATTRS_ALL		= 0x01,
	SET_ATTRS_ALL		= 0x02,
	GET_ATTR_LIST		= 0x03,
	SET_ATTR_LIST		= 0x04,
	RESET				= 0x05,
	START				= 0x06,
	STOP				= 0x07,
	CREATE				= 0x08,
	DELETE				= 0x09,
	MULTI_SRV_PACK		= 0x0A,
	APPLY_ATTRS			= 0x0D,
	GET_ATTR_SINGLE		= 0x0E,
	SET_ATTR_SINGLE		= 0x10,
	FIND_NEXT_OBJ_INST	= 0x11,
	ERROR_RESP			= 0x14,
	RESTORE				= 0x15,
	SAVE				= 0x16,
	NOP					= 0x17,
	GET_MEMBER			= 0x18,
	SET_MEMBER			= 0x19,
	INSERT_MEMBER		= 0x1A,
	REMOVE_MEMBER		= 0x1B,
	--- Logix services
	READ_TAG			= 0x4C,
	WRITE_TAG			= 0x4D,
	READ_FRG			= 0x52,
	WRITE_FRG			= 0x53,

	REPLY				= 0x80,
}

local STATUS = {
	OK					= 0x00,
	ERR_NOT_SUPPORTED	= 0x01,
	ERR_MEMEORY_LIMIT	= 0x02,
	ERR_INVALID_MSG		= 0x03,
	ERR_PATH			= 0x04,
	ERR_INVALID_INST	= 0x05,
	ERR_SERVICE_ERR		= 0x08,
	ERR_CONFLICT_STATE	= 0x10,
	ERR_OBJECT_STATE	= 0x0C,
	ERR_READ_ONLY		= 0x0E,
	ERR_SESSION_HANDLE	= 0x63,
	ERR_INVLIAD_LEN		= 0x64,
	ERR_PROTOCOL_VER	= 0x69,
}

local OBJECT_ID = {
	IDENTITY				= 0x01,
	MESSAGE_ROUTER			= 0x02,
	DEVICENET				= 0x03,
	ASSEMBLY				= 0x04,
	CONNECTION				= 0x05,
	CONNECTION_MANAGER		= 0x06,
	REGISTER				= 0x07,
	DISCRETE_INPUT_POINT	= 0x08,
	DISCRETE_OUTPUT_POINT	= 0x09,
	ANALOG_INPUT_POINT		= 0x0A,
	ANALOG_OUTPUT_POINT		= 0x0B,
	PRESENCE_SENSING		= 0x0E,
	PARAMETER				= 0x0F,
	PARAMETER_GROUP			= 0x10,
	GROUP					= 0x12,
	DISCRETE_INPUT_GROUP	= 0x1D,
	DISCRETE_OUTPUT_GROUP	= 0x1E,
	DISCRETE_GROUP			= 0x1F,
	ANALOG_INPUT_GROUP		= 0x20,
	ANALOG_OUTPUT_GROUP		= 0x21,
	ANALOG_GROUP			= 0x22,
	POSITION_SENSOR			= 0x23,
	POSITION_CONTROLLER_SUPERVISOR	= 0x24,
	POSITION_CONTROLLER		= 0x25,
	BLOCK_SEQUENCER			= 0x26,
	COMMAND_BLOCK			= 0x27,
	MOTOR_DATA				= 0x28,
	CONTROL_SUPERVISOR		= 0x29,
	AC_DC_DRIVE				= 0x2A,
	ACKNOWLEDGE_HANDLER		= 0x2B,
	OVERLOAD				= 0x2C,
	SOFTSTART				= 0x2D,
	SELECTION				= 0x2E,
	S_DEVICE_SUPERVISOR		= 0x30,
	S_ANALOG_SENSOR			= 0x31,
	S_ANALOG_ACTUATOR		= 0x32,
	S_SIGNLE_STAGE_CONTROLLER	= 0x33,
	S_GAS_CALIBRATION		= 0x34,
	TRIP_POINT				= 0x35,
	-- DRIVE_DATA is not assigned,
	FILE					= 0x37,
	S_PARTIAL_PRESSURE		= 0x38,
	SAFETY_SUPERVISOR		= 0x39,
	SAFETY_VALIDATOR		= 0x3A,
	SAFETY_DISCRETE_OUTPUT_POINT	= 0x3B,
	SAFETY_DISCRETE_OUTPUT_GROUP	= 0x3C,
	SAFETY_DISCRETE_INPUT_POINT		= 0x3D,
	SAFETY_DISCRETE_INPUT_GROUP		= 0x3E,
	SAFETY_DUAL_CHANNEL_OUTPUT		= 0x3F,
	S_SENSOR_CALIBRATION	= 0x40,
	EVENT_LOG				= 0x41,
	MOTION_AXIS				= 0x42,
	TIME_SYNC				= 0x43,
	MODBUS					= 0x44,
	CONTROLNET				= 0xF0,
	CONTROLNET_KEEPER		= 0xF1,
	CONTROLNET_SCHEDULING	= 0xF2,
	CONNECTION_CONFIG		= 0xF3,
	PORT					= 0xF4,
	TCPIP_INTERFACE			= 0xF5,
	ETHERNET_LINK			= 0xF6,
	COMPONET_LINK			= 0xF7,
	COMPONET_REPEATER		= 0xF8
}

local status_strings = {
	[0x00] = 'Successs',
	[0x01] = 'The sender issued an invalid or unsupported encapsulation command.',
	[0x02] = 'Insufficient memory resources in the receiver to handle the command.',
	[0x03] = 'Poorly formed or incorrect data in the data portion of the encapsulation message.',
	[0x04] = 'Path syntax error.',
	[0x05] = 'Instance undefined.',
	[0x08] = 'Unimplemented service.',
	[0x10] = 'Device state conflict.',
	[0x0C] = 'Wrong object state.',
	[0x0E] = 'Attempt to set a read-only attribute.',
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
	[0x0A] = 'Attribute list error',
	[0x0B] = 'Already in requested mode/state',
	[0x0C] = 'Object state conflict',
	[0x0D] = 'Object already exists',
	[0x0E] = 'Attribute not settable',
	[0x0F] = 'Privilege violation',
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
	[0x1A] = 'Routing failure, request packet too large',
	[0x1B] = 'Routing failure, response packet too large',
	[0x1C] = 'Missing attribute list entry data',
	[0x1D] = 'Invalid attribute value list',
	[0x1E] = 'Embedded service error',
	[0x1F] = 'Vendor specific error',
	[0x20] = 'Invalid parameter',
	[0x21] = 'Write-once value or medium already written',
	[0x22] = 'Invalid Reply Received',
	[0x23] = 'Buffer Overflow',
	[0x24] = 'Message Format Error',
	[0x25] = 'Key Failure in path',
	[0x26] = 'Path Size Invalid',
	[0x27] = 'Unexpected attribute in list',
	[0x28] = 'Invalid Member ID',
	[0x29] = 'Member not settable',
	[0x2A] = 'Group 2 only server general failure',
	[0x2B] = 'Unknown Modbus Error',
}

local function status_to_string(status)
	return status_strings[status] or general_status_strings[status] or 'Unknown status code : '..status
end

return {
	SERVICES = SERVICES,
	STATUS = STATUS,
	OBJECT = OBJECT_ID,
	status_to_string = status_to_string,
}
