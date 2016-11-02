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
		rooms[i] = modtable.GenerateRoomObject(math.random(x, x+w), math.random(y, y+w), 3, 3, 10, 10)
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
		for k = 1, n-1 do
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
--return the resulting table
-------------------------

return modtable