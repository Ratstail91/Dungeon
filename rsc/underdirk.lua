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
	io.write("underdirk:Blank(", regionAPI.GetX(r), ", ", regionAPI.GetY(r), ")\n")

	for i = 1, regionAPI.GetWidth(r) do
		for j = 1, regionAPI.GetHeight(r) do
			regionAPI.SetTile(r, i, j, 1, underdirk.wall)
		end
	end
end

--TODO: proper generator algorithm

--finally
return underdirk