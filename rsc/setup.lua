print("beginning setup.lua")

math.randomseed(os.time())

print("package path")
package.path = package.path .. ";rsc/?.lua"

print("APIs")
cursorAPI = require("cursor")
regionAPI = require("region")
regionPagerAPI = require("region_pager")
tileSheetAPI = require("tile_sheet")

print("map generators")
mapMaker = require("map_maker")
--randomRooms = require("random_rooms")

print("Attempting to set the map components")
tileSheetAPI.Load("rsc/dungeon_sheet.png", 32, 32)
--regionPagerAPI.SetOnCreate(randomRooms.Blank)

print("Attempting to generate a dungeon")

io.write("Outer Mark 1\n")
underdirk = require("underdirk")
io.write("Outer Mark 2\n")
underdirk.GenerateDungeon(0, 0, 30, 30, 15)
io.write("Outer Mark 3\n")

--local hearts = {}

--hearts[1] = randomRooms.GenerateDungeon(1, 1, 50, 50, 10)
--hearts[2] = randomRooms.GenerateDungeon(50, 1, 50, 50, 10)

--randomRooms.GenPath(hearts[1][1], hearts[1][2], hearts[2][1], hearts[2][2])

print("setup.lua complete")
