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
#include "cursor_api.hpp"

#include "cursor.hpp"

static int setTileSelection(lua_State* L) {
	//get the cursor
	lua_getglobal(L, CURSOR_NAME);
	Cursor* cursor = reinterpret_cast<Cursor*>(lua_touserdata(L, -1));

	//get the parameters
	Region::type_t tile = lua_tointeger(L, 1);

	//set the value
	cursor->tileSelection = tile;

	return 0;
}

static int setLayerSelection(lua_State* L) {
	//get the cursor
	lua_getglobal(L, CURSOR_NAME);
	Cursor* cursor = reinterpret_cast<Cursor*>(lua_touserdata(L, -1));

	//get the parameters
	int layer = lua_tointeger(L, 1);

	//set the value
	cursor->layerSelection = layer;

	return 0;
}

static const luaL_Reg cursorLib[] = {
	{"SetTile", setTileSelection},
	{"SetLayer", setLayerSelection},
	{nullptr, nullptr}
};

LUAMOD_API int openCursorAPI(lua_State* L) {
	luaL_newlib(L, cursorLib);
	return 1;
}