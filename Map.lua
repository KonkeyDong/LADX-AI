local utilities = require("utilities")

Map = {}

function Map:new()
	local self = setmetatable({}, { __index = Map })

	self.destination = {
		map         = 0xD401, -- 00 = overworld, 01 = dungeon, 02 = side view area
		location    = 0xD402, -- values from 00 to 1F accepted. FF is Color Dungeon
		room_number = 0xD403
	}

	-- Position in map. Byte 0xDB54 will store both X and Y
	-- coordinates in one byte (the overworld map is 16 x 16)
	-- The left hex digit is the Y position
	-- The right hex didit is the X position
	-- The origin is 0,0 at the top left of the map.
	self.coordinates = {
		address = 0xDB54,
		cache = 0, -- cache to avoid constant substring manipulation
		X = -1,
		Y = -1
	}

	-- -- not world map position, but what screen you're on.
	-- -- will need work to graph everything out
	-- self.location = {
	-- 	X = 0xD404,
	-- 	Y = 0XD405,
	-- 	dungeon = {
	-- 		X = 0XDBAE -- needs further research
	-- 	}
	-- }

	return self
end

-- default constructor
function Map:display_map_tile_data(settings)
	if not settings.draw_tile_id then
		return
	end

	local tile = {}
	-- 0xD700 - 0xD70B are all value FF (edge of screen).
	-- This pattern continue around all the entire perimeter.
	local base_number = 0xD710 
	for y = 1, 8 do
		tile[y] = {}
		for x = 1, 10 do
			local offset = base_number + x
			 
			local tile_id = memory.readbyte(offset)
			tile_id = string.format("%02x", tile_id)
			tile_id = string.upper(tile_id)
			
			tile[y][x] = tile_id
			
			gui.drawText((x * 16) - 16, (y * 16) - 16, tile_id, nil, nil, 8.5)
		end
		
		base_number = base_number + 16
	end
	
	-- return tile
end

function Map:get_raw_world_map_coordinates()
	return memory.readbyte(self.coordinates.address)
end

function Map:_get_current_coordinates()
	return self.coordinates.X, self.coordinates.Y
end

function Map:separate_world_map_coordinates_string()
	return "WM: " .. utilities.format_coordinates(self:separate_world_map_coordinates())
end

function Map:separate_world_map_coordinates()
	local position = self:get_raw_world_map_coordinates()

	-- no need to update link's current worl map position
	-- if we haven't change screens!
	if self.coordinates.cache == position then
		return self:_get_current_coordinates()
	end

	self.coordinates.cache = position

	position = string.format("%x", position)
	position = string.upper(position)

	self.coordinates.Y = string.sub(position, 1, 1)
	self.coordinates.X = string.sub(position, 2, 2)

	return self:_get_current_coordinates()
end

-- function Map:get_x_location() return memory.readbyte(self.location.X) end
-- function Map:get_y_location() return memory.readbyte(self.location.Y) end

return Map
