local utilities = require("utilities")

Link = {}

function Link:new()
	local self = setmetatable({}, { __index = Link })
	self.stats = {
		health_points    = 0xDB5A, -- Each increment of 0x08 is 1 heart (0x04 is half a heart)
		heart_containers = 0xDB5B,
	}

	self.facing = {
		address = 0xFF9E,
		direction_value = {
			right = 0,
			left  = 1,
			up    = 2,
			down  = 3
		},
		direction = {
			"right",
			"left",
			"up",
			"down"
		}

	}

	self.coordinates = {
		X = 0xFF98, -- X coordinate in pixels (on current screen)
		Y = 0xFF99  -- Y coordinate in pixels (on current screen)
	}
	
	-- NOTE: not memory addresses -- hex values are RGB color values
	self.gui = {
		lineColor       = 0xFF0000FF, -- dark blue
		backgroundColor = 0x400000FF -- light blue
	}		
	
	self.held_item = {
		B = 0xDB00, -- button B
		A = 0xDB01  -- button A
	}

	self.inventory = {
		slot_1  = 0xDB02,
		slot_2  = 0xDB03,
		slot_3  = 0xDB04,
		slot_4  = 0xDB05,	
		slot_5  = 0xDB06,
		
		slot_6  = 0xDB07,
		slot_7  = 0xDB08,
		slot_8  = 0xDB09,		
		slot_9  = 0xDB0A,
		slot_10 = 0xDB0B
	}
		
	-- IDs; not memory addresses.
	self.item = {
		sword         = 1,  --0x01,
		bombs         = 2,  --0x02,
		powerBracelet = 3,  --0x03,
		shield        = 4,  --0x04,
		bow           = 5,  --0x05,
		
		hookshot      = 6,  --0x06,
		fireRod       = 7,  --0x07,
		pegasusBoots  = 8,  --0x08,
		ocarina       = 9,  --0x09,
		feather       = 10, --0x0A,
		
		shovel        = 11, --0x0B,
		magicPowder   = 12, --0x0C,
		boomerang     = 13  --0x0D
	}
		
	self.item_amount = {
		magicPowder  = 0xDB4C,
		bombs        = 0xDB4D,
		arrows       = 0xDB45,
		
		maxMagic     = 0xDB76,
		maxBombs     = 0xDB77,
		maxArrows    = 0xDB78,
		
		keys         = 0xDBD0, -- not dungeon keys. not sure what key. World Map Keys?
		secretShells = 0xDB0F,
		goldLeaves   = 0xDB15
	}
		
	self.item_level = {
		powerBracelet = 0xDB43,
		shield        = 0xDB44,
		sword         = 0xDB4E,
	}
		
	self.misc_items = {
		flippers = 0xDB0C, -- 0x01 = have		
		potion   = 0xDB0D, -- 0x01 = have

		current_trading_item = 0xDB0E -- see table
	}
	
	self.overworldKeys = {
		tailKey  = 0xDB11,
		-- slimeKey = 00000, -- 0xDB10 not sure what key. Maybe slime key after gold leaves?
		fishKey  = 0xDB12,
		faceKey  = 0xDB13,
		eagleKey = 0xDB14
	}
			
	self.ocarina = {
		selectedSong  = 0xDB4A, -- not sure what values would be at the moment
		acquiredSongs = 0xDB49  -- 3 bit mask, 0 = no songs, 7 = all songs
	}
			
	-- Instruments Link currently has
	-- 0x00 = no instrument, 0x03 = has instrument
	self.instruments = {
		level_1 = 0xDB65,
		level_2 = 0xDB66,
		level_3 = 0xDB67,
		level_4 = 0xDB68,
		
		level_5 = 0xDB69,
		level_6 = 0xDB6A,
		level_7 = 0xDB6B,
		level_8 = 0xDB6C
	}

	return self
end

-- setters
function Link:set_heart_containers(value) memory.writebyte(self.stats.heart_containers, value) end

-- Equip item if aquired
function Link:equip_button(item, button)
	if button ~= item then
		local base_address = self.held_item.B
		for i = 0, 12 do
			address = base_address + i
			if item == memory.readbyte(address) then
				-- swap item from inventory
				local temp = memory.readbyte(button) -- get item from button
				memory.writebyte(button, item)       -- set button to item
				memory.writebyte(address, temp)      -- set inventory slot with item
				
				break
			end
		end
	end

	-- memory.writebyte(button, item)
end

function Link:equip_button_b(item)
	self:equip_button(item, self.held_item.B)
end

function Link:equip_button_a(item)
	self:equip_button(item, self.held_item.A)
end

-- getters
function Link:get_health_points_string() return "HP: " .. self:get_health_points() end
function Link:get_health_points() return tonumber(memory.readbyte(self.stats.health_points), 10) / 4 end

function Link:get_heart_containers_string() return "HC: " .. self:get_heart_containers() end
function Link:get_heart_containers() return memory.readbyte(self.stats.heart_containers) end

function Link:get_x_y_coordinate_string() return "Coord: " .. utilities.format_coordinates(self:get_x_y_coordinate()) end
function Link:get_x_y_coordinate() return self:get_x_coordinate(), self:get_y_coordinate() end
function Link:get_x_coordinate() return memory.readbyte(self.coordinates.X) end
function Link:get_y_coordinate() return memory.readbyte(self.coordinates.Y) - 8 end

function Link:get_button_a() return memory.readbyte(self.button.A) end
function Link:get_button_b() return memory.readbyte(self.button.B) end

function Link:draw_hit_box(settings)
	if settings.draw_link_hit_box then
		-- find edges
		local x = self:get_x_position()
		local y = self:get_y_position()

		local x_left = x - 8
		local x_right = x + 8
		local y_top = y - 8
		local y_bot = y + 8
		
		gui.drawBox(x_left, y_top, x_right, y_bot, self.gui.lineColor, self.gui.backgroundColor)
	end
end

function Link:get_facing_direction_string() return "Facing: " .. self:get_facing_direction() end
function Link:get_facing_direction()
	local value = memory.readbyte(self.facing.address)
	return self.facing.direction[value + 1] -- arrays in lua are one-based...
end

return Link