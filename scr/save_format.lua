--[[
/* Copyright: (c) Kayne Ruse 2017
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source
 * distribution.
*/
--]]

local regionAPI = require("region")
local regionPagerAPI = require("region_pager")

local markerAPI = require("marker")
local markerManagerAPI = require("marker_manager")

local modtable = {}

function modtable.SaveAll(fname)
	local fhandle = io.open(fname, "w")

	regionPagerAPI.ForEach(function(r)
		--metadata
		fhandle:write(regionAPI.GetX(r), "\n")
		fhandle:write(regionAPI.GetY(r), "\n")

		--tile data
		for k = 1, regionAPI.GetDepth(r) do
			for j = 1, regionAPI.GetHeight(r) do
				for i = 1, regionAPI.GetWidth(r) do
					fhandle:write(regionAPI.GetTile(r, i, j, k), " ")
				end
			end
		end

		fhandle:write("\n")

		--solid data
		for j = 1, regionAPI.GetHeight(r) do
			for i = 1, regionAPI.GetWidth(r) do
				fhandle:write(regionAPI.GetSolid(r, i, j) and "1" or "0", " ")
			end
		end

		fhandle:write("\n")
	end)

	--markers
	fhandle:write("markers\n")

	local markers = table.pack(markerManagerAPI.Find(function() return true end))

	for _, m in pairs(markers) do
		if type(m) ~= "userdata" then
			break
		end

		fhandle:write(markerAPI.GetX(m), " ")
		fhandle:write(markerAPI.GetY(m), " ")
		fhandle:write(markerAPI.GetText(m), "\n")
	end

	fhandle:close()
end

function  modtable.LoadAll(fname)
	local fhandle = io.open(fname, "r")

	regionPagerAPI.UnloadAll()
	markerManagerAPI.RemoveAll() --TODO: naming conventions need to match better

	while true do
		--metadata
		local x = fhandle:read()

		if x == nil or x == "markers" then
			break
		end

		local y = fhandle:read()

		local r = regionPagerAPI.CreateRegion(x, y)
		--tile data
		for k = 1, regionAPI.GetDepth(r) do
			for j = 1, regionAPI.GetHeight(r) do
				for i = 1, regionAPI.GetWidth(r) do
					regionAPI.SetTile(r, i, j, k, fhandle:read("n"))
				end
			end
		end

		--solid data
		for j = 1, regionAPI.GetHeight(r) do
			for i = 1, regionAPI.GetWidth(r) do
				regionAPI.SetSolid(r, i, j, fhandle:read("n") and true or false)
			end
		end

		--eat the last blank space
		fhandle:read()
		--TODO: a much nicer save format
	end

	--markers
	while true do
		local x = fhandle:read("n")
		local y = fhandle:read("n")
		local t = fhandle:read()

		if x == nil or y == nil or t == nil then
			break
		end

		local m = markerManagerAPI.Create()
		markerAPI.SetX(m, x)
		markerAPI.SetY(m, y)
		markerAPI.SetText(m, t)
	end

	fhandle:close()
end

return modtable