
local commands = {
	NOP					= 0x00 --- TCP
	LIST_SERVICES		= 0x04 --- UDP or TCP
	LIST_IDENTITY		= 0x63 --- UDP or TCP
	LIST_INTERFACES		= 0x64
	REG_SESSION			= 0x65
	UNREG_SESSION		= 0x66
	SEND_RR_DATA		= 0x6f
	SEND_UNIT_DATA		= 0x70
	INDICATE_STATUS		= 0x72
	CANCEL				= 0x73
}

local command_strings = {
	[0x00] = 'NOP',
	[0x04] = 'ListServices',
	[0x63] = 'ListIdentity',
	[0x64] = 'ListInterfaces',
	[0x65] = 'RegisterSession',
	[0x66] = 'UnRegisterSession'
	[0x6f] = 'SendRRData',
	[0x70] = 'SendUnitData',
	[0x72] = 'IndicateStatus',
	[0x73] = 'Cancel',
}

local function command_to_string(command)
	return command_strings[command] or 'Unknown command : '..command
end


return {
	CMD = commands,
	command_to_string(command),
}
