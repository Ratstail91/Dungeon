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
#include "marker_api.hpp"

#include "marker.hpp"

static int setX(lua_State* L) {
	//get the marker
	Marker* marker = reinterpret_cast<Marker*>(lua_touserdata(L, 1));

	//set the value
	marker->SetX(lua_tointeger(L, 2));

	//finally
	return 0;
}

static int getX(lua_State* L) {
	//get the marker
	Marker* marker = reinterpret_cast<Marker*>(lua_touserdata(L, 1));

	//get the value
	lua_pushinteger(L, marker->GetX());

	//finally
	return 1;
}

static int setY(lua_State* L) {
	//get the marker
	Marker* marker = reinterpret_cast<Marker*>(lua_touserdata(L, 1));

	//set the value
	marker->SetY(lua_tointeger(L, 2));

	//finally
	return 0;
}

static int getY(lua_State* L) {
	//get the marker
	Marker* marker = reinterpret_cast<Marker*>(lua_touserdata(L, 1));

	//get the value
	lua_pushinteger(L, marker->GetY());

	//finally
	return 1;
}

static int setText(lua_State* L) {
	//get the marker
	Marker* marker = reinterpret_cast<Marker*>(lua_touserdata(L, 1));

	//set the value
	marker->SetText(lua_tostring(L, 2));

	//finally
	return 0;
}

static int getText(lua_State* L) {
	//get the marker
	Marker* marker = reinterpret_cast<Marker*>(lua_touserdata(L, 1));

	//set the value
	lua_pushstring(L, marker->GetText().c_str());

	//finally
	return 1;
}

static const luaL_Reg markerLib[] = {
	{"SetX", setX},
	{"GetX", getX},
	{"SetY", setY},
	{"GetY", getY},
	{"SetText", setText},
	{"GetText", getText},
	{nullptr, nullptr}
};

LUAMOD_API int openMarkerAPI(lua_State* L) {
	luaL_newlib(L, markerLib);
	return 1;
}