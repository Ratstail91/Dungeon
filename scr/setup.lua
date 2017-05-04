print("beginning setup.lua")

math.randomseed(os.time())

print("package path")
package.path = package.path .. ";scr/?.lua"

print("APIs")
cursorAPI = require("cursor")
regionAPI = require("region")
regionPagerAPI = require("region_pager")
tileSheetAPI = require("tile_sheet")
markerAPI = require("marker")
markerManagerAPI = require("marker_manager")

print("save format")
saveFormat = require("save_format")

print("map generators")

--mapped to "dungeon_sheet.png"
print("Attempting to set the map components")
tileSheetAPI.Load("rsc/dungeon_sheet.png", 32, 32)

regionPagerAPI.SetOnCreate(function(r)
	for i = 1, regionAPI.GetWidth(r) do
		for j = 1, regionAPI.GetHeight(r) do
			regionAPI.SetTile(r, i, j, 1, 1)
		end
	end
end)

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
