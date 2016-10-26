print("beginning setup.lua")

print("package path")
package.path = package.path .. ";rsc/?.lua"

print("APIs")
regionAPI = require("region")
regionPagerAPI = require("region_pager")
tileSheetAPI = require("tile_sheet")

print("map generators")
mapMaker = require("map_maker")
underdirk = require("underdirk")

print("Attempting to set...")
tileSheetAPI.Load(tileSheet, "rsc/dungeon_sheet.png", 32, 32)
regionPagerAPI.SetOnCreate(regionPager, underdirk.Blank)

print("setup.lua complete")