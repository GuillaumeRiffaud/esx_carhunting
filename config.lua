Config = {}
Config.Locale = 'en'
--Check client.lua lines 90 and 127 to reverse color and model names order for some languages (like french)

--Locations where a car hunter can be
Config.Coords = {
	{
		SellPoint = vector3(-771.55, -198.33, 35.24),
		NPCcoords    = vector3(-773.55, -201.33, 36.28),
		NPCheading   = 51.57,
		Rotation = {x = -10.0, y = 20.0, z = 0.0},
	},
	{
		SellPoint = vector3(295.84, -1717.38, 28.21),
		NPCcoords    = vector3(297.96, -1720.43, 28.27),
		NPCheading   = 96.55,
		Rotation = {x = 0.0, y = 0.0, z = 0.0},
	},
	{
		SellPoint = vector3(400.15, 62.77, 96.98),
		NPCcoords    = vector3(402.26, 58.89, 96.98),
		NPCheading   = 97.98,
		Rotation = {x = 0.0, y = 0.0, z = 0.0},
	},
}

--Add or remove the vehicles you want to be hunted here (needs to be display name)
Config.Primes = {
	"BANSHEE", "BULLET", "FURORE", "PENUMBRA", "RAPIDGT", "SABREGT", "SENTINEL",
}

--Whether it's a one-time only quest for each player (false), or a first-arrived first-served challenge that keeps generating new requests (true)
Config.Repeatable = true
--Do you want to check the car's body health before selling? If true, what's the minimum body health accepted?
Config.CheckHealth = true
Config.RequiredHealth = 950
--Set following value to false if you want the reward to be clean money
Config.GiveBlackMoney = true
--Reward for bringing the correct model with the correct color
Config.FullReward = 5000
--Reward for bringing the correct model with the wrong color
Config.PartialReward = 2000

--This serves to identify color hashes as a main color
Config.Colors = {
		{ 
			label = _U('black'),
			colorHashes = { 0,1,2,3,11,12,15,16,21,147,}
		},
		{
			label = _U('white'),
			colorHashes = {106,107,111,112,113,121,122,131,132,134,}
		},
		{
			label = _U('grey'),
			colorHashes = {4, 5, 6, 7, 8, 9, 10,13,14,17,18,19,20,22,23,24,25,26,66,93,144,156,}
		},
		{
			label = _U('red'),
			colorHashes = {27,29,31, 32, 33, 34, 35, 40, 43, 44, 46, 143,150,}
		},
		{
			label = _U('blue'),
			colorHashes = {54, 60, 61, 62, 63, 64, 65, 67, 68, 69, 70, 73, 74, 75, 77, 78, 79, 80, 82, 83, 84, 85, 86, 87, 127,140,141,146,157,}
		},
		{
			label = _U('yellow'),
			colorHashes = {42, 88, 89, 91, 126,}
		},
		{
			label = _U('green'),
			colorHashes = {49, 50, 51, 52, 53, 55, 56, 57, 58, 59, 92, 125,128,133,151,152,155,}
		},
		{
			label = _U('orange'),
			colorHashes = {36, 38, 41, 123,124,130,138,}
		},
		{
			label = _U('brown'),
			colorHashes = {45, 47, 48, 90, 94, 95, 96, 97, 98, 99, 100,101,102,103,104,105,108,109,110,114,115,116,129,153,154,}
		},
		{
			label = _U('purple'),
			colorHashes = {71, 72, 76, 81, 142,145,148,149,}
		},
		-- we ignore the last 3 colors for prime selection as they're probably too rare
		{
			label = _U('pink'),
			colorHashes = {135,136, 137,}
		},
		{
			label = _U('chrome'),
			colorHashes = {117, 118, 119, 120, }
		},
		{
			label = _U('gold'),
			colorHashes = {37, 158,159,160,}
		}
}
