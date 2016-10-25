print("beginning setup.lua")

print("package path")
package.path = package.path .. ";rsc/?.lua"

print("APIs")
regionAPI = require("region")
regionPagerAPI = require("region_pager")
tileSheetAPI = require("tile_sheet")

print("map maker")
mapMaker = require("rsc/map_maker")

print("Attempting to set...")
regionPagerAPI.SetOnCreate(regionPager, mapMaker.DebugIsland)

print("setup.lua complete")