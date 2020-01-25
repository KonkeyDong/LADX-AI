memory.usememorydomain("System Bus")

local Map = require "Map"
local Link = require "Link"
local SETTINGS = require "settings"

-- globals
local link = Link:new()
local map = Map:new()
	
-- local function run(settings)




	--console.log(Memory.value("HeldItems", "A"))
	

	-- WM_pos = string.format("%x", memory.readbyte(0xDB54))
	-- WM_pos = string.upper(WM_pos)
	-- WM_pos_y = string.sub(WM_pos, 1, 1) -- from position 1 to position 1 (inclusive)
	-- WM_pos_x = string.sub(WM_pos, 2, 2) -- from position 2 to position 2 (inclusive)
	
	-- looks like 95a0, c430, and e430 point to if we are in the overworld, or dungeon
	-- (overworld = 0, dungeon = 2)
	
	-- temp. remove later

	
	-- Seems like byte 0xFF98 & 0xFF99 are Link's X and Y pixel position respecitively
	-- looks like the point is at the base of link's feet, almost direclty in the center

	
	-- npc positions start at 0xC200:
	-- npc_x @ 0xC200
	-- npc_y @ 0xC210
	-- npc living flag @ 0xC280 (5 = alive; 1 = die animation; 0 = dead
	-- npc idle flag @ 0xC290 (0 = moving; 1 = idle (stopped))
	-- npc health @ 0xC360
	-- npc sprite ID @ 0xC3A0 ?
	-- npc invinciblility frames @ 0xC420
	-- enemy_x_base = memory.readbyte(0xC200)
	-- enemy_y_base = memory.readbyte(0xC210) - 8
	
	-- enemy_x_left = enemy_x_base - 8
	-- enemy_x_right = enemy_x_base + 8
	-- enemy_y_top = enemy_y_base - 8
	-- enemy_y_bot = enemy_y_base + 8

	-- gui.drawBox(enemy_x_left, enemy_y_top, enemy_x_right, enemy_y_bot, 0x00FF0000, 0x40FF0000)
	
	
	
	-- byte 0xFFFA looks like Link's tile location on the screen.
	-- going left-right increments by 1
	-- going up-down increments by 16
	

--[[

	local camx = mainmemory.read_u16_le(cx)
	local camy = mainmemory.read_u16_le(cy)
	local x = mainmemory.read_u16_le(px) - camx
	local y = mainmemory.read_u16_le(py) - camy
	local facing = mainmemory.read_u8(pbase + 0x11)
	local boxpointer = mainmemory.read_u16_le(pbase + 0x20) + 0x28000
	local xoff = memory.read_s8(boxpointer + 0)
	local yoff = memory.read_s8(boxpointer + 1)
	local xrad = memory.read_u8(boxpointer + 2)
	local yrad = memory.read_u8(boxpointer + 3)
	
	if facing > 0x45 then
		xoff = xoff * -1
	end
	
	gui.drawBox(x + xoff +xrad,y + yoff + yrad, x + xoff - xrad, y + yoff - yrad,0xFF0000FF,0x400000FF)
	--]]
-- end

local function draw_grid(settings)
	if not settings.draw_grid then
		return
	end

	for i = 1, 16 do
		gui.drawLine(0, i * 16, 160, i * 16)
		gui.drawLine(i * 16, 0, i * 16, 127)
	end	
end

local DISPLAY_STAT_ORDER = {
	function() return link:get_health_points_string() end,
	function() return link:get_heart_containers_string() end,
	function() return link:get_x_y_coordinate_string() end,
	function() return link:get_facing_direction_string() end,
	function() return map:separate_world_map_coordinates_string() end
}

local function draw_stats(settings)
	if not settings.display_stats then
		return
	end

	for i = 1, #DISPLAY_STAT_ORDER do
		gui.text(0, (i * 15), DISPLAY_STAT_ORDER[i]())
	end
end

-- try setting values...
-- link:set_HC(10)
-- link:equip_button_a(link.item.sword)
-- memory.writebyte(link.inventory.slot_1, link.item.feather)
-- link:equip_button_a(link.item.sword)
-- memory.writebyte(link.item_level.sword, 1)

-- memory.writebyte(map.destination.X, 5) -- actually moves link!

-- main loop
while true do
	draw_grid(SETTINGS)
	draw_stats(SETTINGS)
	link:draw_hit_box(SETTINGS)
	map:display_map_tile_data(SETTINGS)

	-- DO NOT REMOVE
	emu.frameadvance()
end