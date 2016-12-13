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

local modtable = {}

--tile macros, mapped to the tilesheet "overworld.bmp"
modtable.blank	= 0
modtable.water	= 18 + 3 * 0
modtable.sand	= 18 + 3 * 1
modtable.plains	= 18 + 3 * 2
modtable.grass	= 18 + 3 * 3
modtable.dirt	= 18 + 3 * 4

--"edge" macros
modtable.edges = {}
modtable.edges.north = -16
modtable.edges.south = 16
modtable.edges.east = 1
modtable.edges.west = -1

--the blank function
function modtable.Blank(r)
	for i = 1, 20 do
		for j = 1, 20 do
			regionAPI.SetTile(r, i, j, 1, modtable.water)
		end
	end
end

return modtable