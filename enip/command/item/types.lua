local TYPE_ID = {
	NULL				= 0x0000,	-- NULL
	LIST_IDENTITY		= 0x000C,	-- ListIdentity
	CONNECTED_ADDR		= 0x00A1,	-- Connected Address Item
	CONNECTED			= 0x00B1,	-- Connected Transport Item
	UNCONNECTED			= 0x00B2,	-- Unconnected message
	LIST_SERVICES		= 0x0100,	-- ListServices
	SOCK_ADDR_C			= 0x8000,	-- Socketaddr Info, originator to target
	SOCK_ADDR_S			= 0x8002,	-- Socketaddr Info, target to originator
	SEQUENCED_ADDR		= 0x8002,	-- Sequenced Addresss Item
}

return TYPE_ID
