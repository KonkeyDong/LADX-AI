local Memory = {}

local Link = {
	Stats = {
		HP = 0xDB5A, -- Each increment of 0x08 is 1 heart (0x04 is half a heart)
		HC = 0xDB5B,
		X  = 0xFF98, -- X coordinate in pixels (on current screen)
		Y  = 0xFF99  -- Y coordinate in pixels (on current screen)
	},
	
	HeldItems = {
		B = 0xDB00, -- button B
		A = 0xDB01 -- button A
	},

	Inventory = {
		slot_1 = 0xDB02,
		slot_2 = 0xDB03,
		slot_3 = 0xDB04,
		slot_4 = 0xDB05,		
		slot_5 = 0xDB06,
		
		slot_6 = 0xDB07,
		slot_7 = 0xDB08,
		slot_8 = 0xDB09,		
		slot_9 = 0xDB0A,
		slot_10 = 0xDB0B
	},
	
	ItemID = {
		sword = 0x01,
		bombs = 0x02,
		powerBracelet = 0x03,
		shield = 0x04,
		bow = 0x05,
		
		hookshot = 0x06,
		fireRod = 0x07,
		pegasusBoots = 0x08,
		ocarina = 0x09,
		feather = 0x0A,
		
		shovel = 0x0B,
		magicPowder = 0x0C,
		boomerang = 0x0D
	},
	
	ItemAmount = {
		magicPowder = 0xDB4C,
		bombs = 0xDB4D,
		arrows = 0xDB45,
		
		maxMagic = 0xDB76,
		maxBombs = 0xDB77,
		maxArrows = 0xDB78,
		
		keys = 0xDBD0, -- not dungeon keys. not sure what key. World Map Keys?
		secretShells = 0xDB0F,
		goldLeaves = 0xDB15
	},
	
	ItemLevel = {
		powerBracelet = 0xDB43,
		shield = 0xDB44,
		sword = 0xDB4E
	},
	
	MiscItems = {
		flippers = 0xDB0C, -- 0x01 = have		
		potion = 0xDB0D,   -- 0x01 = have
		currentTradingItem = 0xDB0E -- see table
	},
		
	Ocarina = {
		selectedSong = 0xDB4A, -- not sure what values would be at the moment
		acquiredSongs = 0xDB49 -- 3 bit mask, 0 = no songs, 7 = all songs
	},
		
	-- Instruments Link currently has
	-- 0x00 = no instrument, 0x03 = has instrument
	Instruments = {
		level_1 = 0xDB65,
		level_2 = 0xDB66,
		level_3 = 0xDB67,
		level_4 = 0xDB68,
		
		level_5 = 0xDB69,
		level_6 = 0xDB6A,
		level_7 = 0xDB6B,
		level_8 = 0xDB6C
	}
}

local Map = {
	-- stores both X and Y coordinate in one byte.
	-- The overworld map is 16x16. So, 0x00 - 0xFF98
	-- The right hex digit is the X position.
	-- The left hex digit is the Y position.
	-- Origin is 0x00 (top left corner)
	-- top right corner is 0x0F
	-- bot left corner is 0xF0
	-- bot right corner is 0xFF
	-- going left or right increments/decrements the value by 1,
	-- going up or down increments/decrements the value by 16
	World = {
		position = 0xDB54
	},
	
	-- Probably same as above, but 8x8 map instead.
	Dungeon = {
		position = 0xDBAE
	},
	
	-- 0xD700 - oxD79B (ignore the bytes after B, so, 0xD70C- 0xD70F)
	-- FF means edge of screen. Will have to work on tiles.... that will take a lot of time.
	CurrentLoadedMap = {
		baseAddress = 0xD700
	},
	
	 -- 0x00 = overworld, 0x01 = dungeon, 0x02 = side view area?
	WorldOrDungeon = {
		location = 0xD401
	},
	
	 -- room number. Must appear on map or it will lead to an empty room.
	Room = {
		number = 0xD403
	}
}
	
-- private function to read a raw memory address	
local function raw(address, base, precision)
	local value = memory.readbyte(address)
	
	if base and string.upper(base) == "HEX" then
		value = string.format("%x", memory.readbyte(address))
		value = string.upper(value)
		return value
	end
	
	-- default to base 10
	return tonumber(memory.readbyte(address), 10)
end

-- generic private function to further get the value at the bye
local function getValue(section, key, base, precision)
	local memoryAddress
	
	if key then
		memoryAddress = section[key]
	end
	
	return raw(memoryAddress, base)
end


function Memory.link(section, key, base, precision)
	local section = Link[section]	
	return getValue(section, key, base)
end
	
return Memory