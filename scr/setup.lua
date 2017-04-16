print("beginning setup.lua")

math.randomseed(os.time())

print("package path")
package.path = package.path .. ";scr/?.lua"

print("APIs")
cursorAPI = require("cursor")
regionAPI = require("region")
regionPagerAPI = require("region_pager")
tileSheetAPI = require("tile_sheet")

print("save format")
saveFormat = require("save_format")

print("map generators")
--mapMaker = require("map_maker")
--randomRooms = require("random_rooms")
--underdirk = require("underdirk")
--infinity = require("infinity_generator")

print("Attempting to set the map components")
tileSheetAPI.Load("rsc/dungeon_sheet.png", 32, 32)
--regionPagerAPI.SetOnCreate(randomRooms.Blank)

--print("Attempting to generate a dungeon")

--METHOD 3
--regionPagerAPI.SetOnCreate(infinity.Blank)

--METHOD 2
--underdirk.GenerateDungeon(0, 0, 30, 30, 15)

--METHOD 1
--local hearts = {}

--hearts[1] = randomRooms.GenerateDungeon(1, 1, 50, 50, 10)
--hearts[2] = randomRooms.GenerateDungeon(50, 1, 50, 50, 10)

--randomRooms.GenPath(hearts[1][1], hearts[1][2], hearts[2][1], hearts[2][2])

--usability
function save(arg)
	local fname = arg or "default.map"
	saveFormat.SaveAll(fname)
end

function load(arg)
	local fname = arg or "default.map"
	saveFormat.LoadAll(fname)
end

function clear()
	regionPagerAPI.UnloadAll()
end

function setTile(i)
	local j = i or 0
	cursorAPI.SetTile(j)
end

print("setup.lua complete")
