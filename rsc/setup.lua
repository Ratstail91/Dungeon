print("beginning setup.lua")

math.randomseed(os.time())

print("package path")
package.path = package.path .. ";rsc/?.lua"

print("APIs")
regionAPI = require("region")
regionPagerAPI = require("region_pager")
tileSheetAPI = require("tile_sheet")

print("map generators")
mapMaker = require("map_maker")
underdirk = require("underdirk")

print("Attempting to set the map components")
tileSheetAPI.Load(tileSheet, "rsc/dungeon_sheet.png", 32, 32)
regionPagerAPI.SetOnCreate(regionPager, underdirk.Blank)

print("Attempting to generate a dungeon")

local hearts = {}

hearts[1] = underdirk.GenerateDungeon(regionPager, 1, 1, 50, 50, 10)
hearts[2] = underdirk.GenerateDungeon(regionPager, 100, 1, 50, 50, 10)

underdirk.GenPath(regionPager, hearts[1][1], hearts[1][2], hearts[2][1], hearts[2][2])

print("setup.lua complete")