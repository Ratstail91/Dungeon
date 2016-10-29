--[[
/* Copyright: (c) Kayne Ruse 2016
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

--DOCS: A basic dungeon map generator

local regionAPI = require("region")
local regionPagerAPI = require("region_pager")

local underdirk = {}

--utility functions
function underdirk.Sqr(x) return x*x end
function underdirk.Dist(x, y, i, j) return math.sqrt(underdirk.Sqr(x - i) + mapMaker.Sqr(y - j)) end

function underdirk.GThenSwitch(a, b)
	--BUGFIX: This resolves a problem with the for loop and iterating through paths, ensuring that they iterate upwards
	if a > b then
		return b, a
	else
		return a, b
	end
end

--tile macros, mapped to the tilesheet "dungeon_sheet.png"
underdirk.wall		= 1
underdirk.open		= 2
underdirk.doorv		= 3
underdirk.doorh		= 4
underdirk.sdoorv	= 5
underdirk.sdoorh	= 6
underdirk.stairsnd	= 7
underdirk.stairswd	= 8
underdirk.stairssd	= 9
underdirk.stairsed	= 10

--blank backgrounds
function underdirk.Blank(r)
	--debug
--	io.write("underdirk:Blank(", regionAPI.GetX(r), ", ", regionAPI.GetY(r), ")\n")

	for i = 1, regionAPI.GetWidth(r) do
		for j = 1, regionAPI.GetHeight(r) do
			regionAPI.SetTile(r, i, j, 1, underdirk.wall)
		end
	end
end

--TODO: proper generator algorithm
function underdirk.GenerateDungeon(x, y, w, h, n)
	heartList = {}

	--generate rooms
	for i = 1, n do
		heartList[i] = underdirk.GenRoom(math.random(x,x+w), math.random(y,y+h), math.random(3, 10), math.random(3,10))
	end

	--generate paths between rooms
	for i = 1, n-1 do
		underdirk.GenPath(heartList[i][1], heartList[i][2], heartList[i+1][1], heartList[i+1][2])
	end

	return heartList[1]
end

function underdirk.GenRoom(x, y, w, h)
	for i = x, x+w-1 do
		for j = y, y+h-1 do
			--NOTE: zero indexing is used in RegionPager API, but not Region API.
			regionPagerAPI.SetTile(i, j, 0, underdirk.open)
		end
	end

	return {math.random(x, x+w-1), math.random(y, y+h-1)}
end

--GenPath generates the longest path first, wich is why it's split into three parts

function underdirk.GenPath(x1, y1, x2, y2)
--	print("path with", x1, y1, x2, y2)
	if math.abs(x2-x1) > math.abs(y2-y1) then
		return underdirk.GenPathX(x1, y1, x2, y2)
	else
		return underdirk.GenPathY(x1, y1, x2, y2)
	end
end

function underdirk.GenPathX(x1, y1, x2, y2)
	local x1s
	local x2s
	local y1s
	local y2s

	--BUGFIX
	x1s, x2s = underdirk.GThenSwitch(x1, x2)
	y1s, y2s = underdirk.GThenSwitch(y1, y2)

	--generate a simple path between two coordinates, starting with cardinal X
	for i = x1s, x2s do
		regionPagerAPI.SetTile(i, y1, 0, underdirk.open)
--		io.write("x")
	end

	for j = y1s, y2s do
		regionPagerAPI.SetTile(x2, j, 0, underdirk.open)
--		io.write("y")
	end
--	io.write("+\n")
end

function underdirk.GenPathY(x1, y1, x2, y2)
	local x1s
	local x2s
	local y1s
	local y2s

	--BUGFIX
	x1s, x2s = underdirk.GThenSwitch(x1, x2)
	y1s, y2s = underdirk.GThenSwitch(y1, y2)

	--generate a simple path between two coordinates, starting with cardinal Y
	for j = y1s, y2s do
		regionPagerAPI.SetTile(x1, j, 0, underdirk.open)
--		io.write("y")
	end

--	io.write("(", y1, ",", y2, ")")

	for i = x1s, x2s do
		regionPagerAPI.SetTile(i, y2, 0, underdirk.open)
--		io.write("x")
	end
--	io.write("-\n")
end

--finally
return underdirk