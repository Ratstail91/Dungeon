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

local regionAPI = require("region")
local regionPagerAPI = require("region_pager")

local modtable = {}
--
--utility functions
function modtable.Sqr(x) return x*x end
function modtable.Dist(x, y, i, j) return math.sqrt(modtable.Sqr(x - i) + mapMaker.Sqr(y - j)) end

function modtable.GThenSwitch(a, b)
	--BUGFIX: This resolves a problem with the for loop and iterating through paths, ensuring that they iterate upwards
	if a > b then
		return b, a
	else
		return a, b
	end
end

--tile macros, mapped to the tilesheet "dungeon_sheet.png"
modtable.wall		= 1
modtable.open		= 2
modtable.doorv		= 3
modtable.doorh		= 4
modtable.sdoorv		= 5
modtable.sdoorh		= 6
modtable.stairsnd	= 7
modtable.stairswd	= 8
modtable.stairssd	= 9
modtable.stairsed	= 10

--list of filters for finding door locations
modtable.hfilters = {
	--normal filter orientation
	{modtable.open, modtable.open, modtable.open, modtable.wall, modtable.open, modtable.wall, -1, -1, -1},
	{modtable.wall, modtable.open, modtable.open, modtable.wall, modtable.open, modtable.wall, -1, -1, -1},
	{modtable.open, modtable.open, modtable.wall, modtable.wall, modtable.open, modtable.wall, -1, -1, -1},
	--rotated 180 degrees
	{-1, -1, -1, modtable.wall, modtable.open, modtable.wall, modtable.open, modtable.open, modtable.open},
	{-1, -1, -1, modtable.wall, modtable.open, modtable.wall, modtable.open, modtable.open, modtable.wall},
	{-1, -1, -1, modtable.wall, modtable.open, modtable.wall, modtable.wall, modtable.open, modtable.open}
}

modtable.vfilters = {
	--90 degrees
	{modtable.open, modtable.wall, -1, modtable.open, modtable.open, -1, modtable.open, modtable.wall, -1},
	{modtable.open, modtable.wall, -1, modtable.open, modtable.open, -1, modtable.wall, modtable.wall, -1},
	{modtable.wall, modtable.wall, -1, modtable.open, modtable.open, -1, modtable.open, modtable.wall, -1},
	--270 degrees
	{-1, modtable.wall, modtable.open, -1, modtable.open, modtable.open, -1, modtable.wall, modtable.open},
	{-1, modtable.wall, modtable.wall, -1, modtable.open, modtable.open, -1, modtable.wall, modtable.open},
	{-1, modtable.wall, modtable.open, -1, modtable.open, modtable.open, -1, modtable.wall, modtable.wall}
}

modtable.cornerfilters = {
	{modtable.wall, modtable.wall, modtable.wall, -1, modtable.open, modtable.wall, modtable.wall, -1, modtable.wall},
	{modtable.wall, modtable.wall, modtable.wall, modtable.wall, modtable.open, -1, modtable.wall, -1, modtable.wall},
	{modtable.wall, -1, modtable.wall, modtable.wall, modtable.open, -1, modtable.wall, modtable.wall, modtable.wall},
	{modtable.wall, -1, modtable.wall, -1, modtable.open, modtable.wall, modtable.wall, modtable.wall, modtable.wall}
}

--blank backgrounds
function modtable.Blank(r)
	for i = 1, regionAPI.GetWidth(r) do
		for j = 1, regionAPI.GetHeight(r) do
			regionAPI.SetTile(r, i, j, 1, modtable.wall)
		end
	end
end

function modtable.GenerateDungeon(x, y, w, h, n)
	--setup
	regionPagerAPI.SetOnCreate(modtable.Blank)
	--make the rooms
	rooms = {}

	--basic rooms
	for i = 1, n do
		rooms[i] = modtable.GenerateRoomObject(math.random(x, x+w), math.random(y, y+w), 2, 2, 6, 6)
	end

	--TODO: prefab rooms

	--shift the rooms apart
	local restart = true
	while restart == true do
		restart = false

		--compare each room to each other room, and shift them apart if a collision is detected
		for i = 1, n do
			for j = 1, n do
				local retFlag = modtable.ShiftCollisions(rooms[i], rooms[j])

				if retFlag == 1 then
					restart = true
				end
				if retFlag == 2 then
					print("Warning: Objects can't be shifted")
					rooms[j].x = rooms[j].x + 1
				end
			end
		end
	end

	--connect the rooms with pathway representations
	for i = 1, n do
		--determine the centers AFTER shifting
		rooms[i].centerX = rooms[i].x + math.floor(rooms[i].w / 2)
		rooms[i].centerY = rooms[i].y + math.floor(rooms[i].h / 2)
	end

	for i = 1, n do
		local closest = -1
		local dist = 9999999999

		--find the closest room to room[i]
		for k = 1, n do
			local d = modtable.Dist(rooms[i].x, rooms[i].y, rooms[k].x, rooms[k].y)
			if d < dist and i ~= k and rooms[k].target == -1 then
				closest = k
				dist = d
			end
		end

		rooms[i].target = closest
	end

	--save the resulting rooms
	for k = 1, n do
		for i = rooms[k].x, rooms[k].x + rooms[k].w do
			for j = rooms[k].y, rooms[k].y + rooms[k].h do
				regionPagerAPI.SetTile(i, j, 0, modtable.open)
			end
		end

		--generate the paths
		if rooms[k].target ~= -1 then
			modtable.GenPath(rooms[k].centerX, rooms[k].centerY, rooms[rooms[k].target].centerX, rooms[rooms[k].target].centerY)
		else
			print("ERROR: -1 target found")
		end
	end

	--prep the arguments for the filter algorithm
	local lowerX = 0
	local upperX = 0
	local lowerY = 0
	local upperY = 0
	regionPagerAPI.ForEach(function(r)
		--mimicing the "publish" code
		if (regionAPI.GetX(r) < lowerX) then lowerX = regionAPI.GetX(r) end
		if (regionAPI.GetX(r) > upperX) then upperX = regionAPI.GetX(r) end
		if (regionAPI.GetY(r) < lowerY) then lowerY = regionAPI.GetY(r) end
		if (regionAPI.GetY(r) > upperY) then upperY = regionAPI.GetY(r) end
	end)

	--pass to the filter algorithm
	modtable.MatchFilters(
		lowerX+1, upperX+regionAPI.GetWidth()-2,
		lowerY+1, upperY+regionAPI.GetHeight()-2,
		modtable.hfilters,
		function (i, j)
			local t = math.random(10)
			if (t <= 7) then
				regionPagerAPI.SetTile(i, j, 0, modtable.doorh)
			end
			if (t >= 8 and t <= 9) then
				regionPagerAPI.SetTile(i, j, 0, modtable.sdoorh)
			end
		end
	)

	modtable.MatchFilters(
		lowerX+1, upperX+regionAPI.GetWidth()-2,
		lowerY+1, upperY+regionAPI.GetHeight()-2,
		modtable.vfilters,
		function (i, j)
			local t = math.random(10)
			if (t <= 7) then
				regionPagerAPI.SetTile(i, j, 0, modtable.doorv)
			end
			if (t >= 8 and t <= 9) then
				regionPagerAPI.SetTile(i, j, 0, modtable.sdoorv)
			end
		end
	)

	--correcting the "kink" doors
	modtable.MatchFilters(
		lowerX+1, upperX+regionAPI.GetWidth()-2,
		lowerY+1, upperY+regionAPI.GetHeight()-2,
		modtable.cornerfilters,
		function (i, j)
			if (regionPagerAPI.GetTile(i-1, j, 0) ~= modtable.wall) then regionPagerAPI.SetTile(i-1, j, 0, modtable.open) end
			if (regionPagerAPI.GetTile(i+1, j, 0) ~= modtable.wall) then regionPagerAPI.SetTile(i+1, j, 0, modtable.open) end
			if (regionPagerAPI.GetTile(i, j-1, 0) ~= modtable.wall) then regionPagerAPI.SetTile(i, j-1, 0, modtable.open) end
			if (regionPagerAPI.GetTile(i, j+1, 0) ~= modtable.wall) then regionPagerAPI.SetTile(i, j+1, 0, modtable.open) end
		end
	)

--	for i = lowerX+1, upperX+regionAPI.GetWidth()-2 do
--		for j = lowerY+1, upperY+regionAPI.GetHeight()-2 do
--			regionPagerAPI.GetTile(i, j, 0)
--		end
--	end
end

function modtable.GenerateRoomObject(x, y, minW, minH, maxW, maxH)
	local obj = {}
	obj.x = x
	obj.y = y
	obj.w = math.random(minW, maxW)
	obj.h = math.random(minH, maxH)

	--for passages
--	obj.centerX = obj.x + math.floor(obj.w / 2)
--	obj.centerY = obj.y + math.floor(obj.h / 2)
	obj.target = -1

	return obj
end

-------------------------
--Collision checking
-------------------------

function modtable.CheckCollision(lhs, rhs)
	--check if two room objects overlap
	if lhs.x > rhs.x + rhs.w then return false end
	if lhs.y > rhs.y + rhs.h then return false end
	if lhs.x + lhs.w < rhs.x then return false end
	if lhs.y + lhs.h < rhs.y then return false end
	return true
end

function modtable.ShiftCollisions(lhs, rhs)
	--return values: -1 = same object, 0 = move on, 1 = shifting occurred, 2 = object can't be shifted
	local retFlag = 0

	if lhs == rhs then
		return -1
	end

	--add a margin to avoid kissing
	lhs.x = lhs.x - 1
	lhs.y = lhs.y - 1
	lhs.w = lhs.w + 2
	lhs.h = lhs.h + 2

	--very crude separation algorithm
	while modtable.CheckCollision(lhs, rhs) do
		--error checking
		retFlag = 2

		if math.abs(lhs.x - rhs.x) > math.abs(lhs.y - rhs.y) then
			--X direction
			if lhs.x < rhs.x then
				lhs.x = lhs.x - 1
				rhs.x = rhs.x + 1
				retFlag = 1
			end

			if lhs.x > rhs.x then
				lhs.x = lhs.x + 1
				rhs.x = rhs.x - 1
				retFlag = 1
			end
		else
			--Y direction
			if lhs.y < rhs.y then
				lhs.y = lhs.y - 1
				rhs.y = rhs.y + 1
				retFlag = 1
			end

			if lhs.y > rhs.y then
				lhs.y = lhs.y + 1
				rhs.y = rhs.y - 1
				retFlag = 1
			end
		end

		--error checking
		if retFlag == 2 then
			--correct the margin
			lhs.x = lhs.x + 1
			lhs.y = lhs.y + 1
			lhs.w = lhs.w - 2
			lhs.h = lhs.h - 2

			--return the error
			return retFlag
		end
	end

	--correct the margin
	lhs.x = lhs.x + 1
	lhs.y = lhs.y + 1
	lhs.w = lhs.w - 2
	lhs.h = lhs.h - 2

	return retFlag
end

-------------------------
--GenPath generates the longest path first, wich is why it's split into three parts
-------------------------

function modtable.GenPath(x1, y1, x2, y2)
--	print("path with", x1, y1, x2, y2)
	if math.abs(x2-x1) > math.abs(y2-y1) then
		return modtable.GenPathX(x1, y1, x2, y2)
	else
		return modtable.GenPathY(x1, y1, x2, y2)
	end
end

function modtable.GenPathX(x1, y1, x2, y2)
	local x1s
	local x2s
	local y1s
	local y2s

	--BUGFIX
	x1s, x2s = modtable.GThenSwitch(x1, x2)
	y1s, y2s = modtable.GThenSwitch(y1, y2)

	--generate a simple path between two coordinates, starting with cardinal X
	for i = x1s, x2s do
		regionPagerAPI.SetTile(i, y1, 0, modtable.open)
--		io.write("x")
	end

	for j = y1s, y2s do
		regionPagerAPI.SetTile(x2, j, 0, modtable.open)
--		io.write("y")
	end
--	io.write("+\n")
end

function modtable.GenPathY(x1, y1, x2, y2)
	local x1s
	local x2s
	local y1s
	local y2s

	--BUGFIX
	x1s, x2s = modtable.GThenSwitch(x1, x2)
	y1s, y2s = modtable.GThenSwitch(y1, y2)

	--generate a simple path between two coordinates, starting with cardinal Y
	for j = y1s, y2s do
		regionPagerAPI.SetTile(x1, j, 0, modtable.open)
--		io.write("y")
	end

--	io.write("(", y1, ",", y2, ")")

	for i = x1s, x2s do
		regionPagerAPI.SetTile(i, y2, 0, modtable.open)
--		io.write("x")
	end
--	io.write("-\n")
end

-------------------------
--MatchFilters, for generating doors in correct places
-------------------------

function modtable.MatchFilters(lowerX, upperX, lowerY, upperY, filters, callback)
	--for each potential location
	for i = lowerX, upperX do
		for j = lowerY, upperY do
			--compare it to the filters
			for _, f in pairs(filters) do
				if (f[1] ~= -1 and f[1] ~= regionPagerAPI.GetTile(i-1, j-1, 0)) then goto continue end
				if (f[2] ~= -1 and f[2] ~= regionPagerAPI.GetTile(i  , j-1, 0)) then goto continue end
				if (f[3] ~= -1 and f[3] ~= regionPagerAPI.GetTile(i+1, j-1, 0)) then goto continue end
				if (f[4] ~= -1 and f[4] ~= regionPagerAPI.GetTile(i-1, j  , 0)) then goto continue end
				if (f[5] ~= -1 and f[5] ~= regionPagerAPI.GetTile(i  , j  , 0)) then goto continue end
				if (f[6] ~= -1 and f[6] ~= regionPagerAPI.GetTile(i+1, j  , 0)) then goto continue end
				if (f[7] ~= -1 and f[7] ~= regionPagerAPI.GetTile(i-1, j+1, 0)) then goto continue end
				if (f[8] ~= -1 and f[8] ~= regionPagerAPI.GetTile(i  , j+1, 0)) then goto continue end
				if (f[9] ~= -1 and f[9] ~= regionPagerAPI.GetTile(i+1, j+1, 0)) then goto continue end

				callback(i, j)
				::continue::
			end
		end
	end
end

-------------------------
--return the resulting table
-------------------------

return modtable