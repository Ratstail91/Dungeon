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

local modtable = {}

function modtable.SaveAll(fname)
	local fhandle = io.open(fname, "w")

	regionPagerAPI.ForEach(function(r)
		--metadata
		fhandle:write(regionAPI.GetX(r), " ")
		fhandle:write(regionAPI.GetY(r), " ")

		--tile data
		for k = 1, regionAPI.GetDepth(r) do
			for j = 1, regionAPI.GetHeight(r) do
				for i = 1, regionAPI.GetWidth(r) do
					fhandle:write(regionAPI.GetTile(r, i, j, k), " ")
				end
			end
		end

		--solid data
		for j = 1, regionAPI.GetHeight(r) do
			for i = 1, regionAPI.GetWidth(r) do
				fhandle:write(regionAPI.GetSolid(r, i, j) and "1" or "0", " ")
			end
		end
	end)

	fhandle:close()
end

function  modtable.LoadAll(fname)
	local fhandle = io.open(fname, "r")

	regionPagerAPI.UnloadAll()

	while true do
		--metadata
		local x = fhandle:read("n")
		local y = fhandle:read("n")

		if x == nil or y == nil then
			break
		end

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
	end
	fhandle:close()
end

return modtable