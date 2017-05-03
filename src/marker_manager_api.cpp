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
#include "marker_manager_api.hpp"

#include "marker_manager.hpp"

#include <sstream>

static int createMarker(lua_State* L) {
	//get the manager
	lua_getglobal(L, MARKER_MANAGER_NAME);
	MarkerManager* markerManager = reinterpret_cast<MarkerManager*>(lua_touserdata(L, -1));

	//create the new marker
	Marker* marker = markerManager->CreateMarker();

	//push and return the marker
	lua_pushlightuserdata(L, reinterpret_cast<void*>(marker));
	return 1;
}

static int findMarker(lua_State* L) {
	//get the manager
	lua_getglobal(L, MARKER_MANAGER_NAME);
	MarkerManager* markerManager = reinterpret_cast<MarkerManager*>(lua_touserdata(L, -1));

	//find the markers based on a lambda
	int count = 0;
	markerManager->ForEach([&](Marker* marker) -> void {
		//push a copy of the lambda and marker to the stack
		lua_pushvalue(L, 1);
		lua_pushlightuserdata(L, reinterpret_cast<void*>(marker));

		//call the lambda copy
		if (lua_pcall(L, 1, 1, 0)) {
			//ya dun fucked up
			std::ostringstream msg;
			msg << "MarkerManager API Error (find): " << lua_tostring(L, -1);
			throw(std::runtime_error(msg.str()));
		}

		//check if this marker should be returned
		bool ret = lua_toboolean(L, -1);
		lua_pop(L, 1);

		//push a copy to the stack to be returned
		if (ret) {
			lua_pushlightuserdata(L, marker);
			count++;
		}
	});

	//push and return the marker
	return count;
}

static int removeMarkerIf(lua_State* L) {
	//get the manager
	lua_getglobal(L, MARKER_MANAGER_NAME);
	MarkerManager* markerManager = reinterpret_cast<MarkerManager*>(lua_touserdata(L, -1));

	//remove markers based on a lambda
	markerManager->RemoveIf([&](Marker* marker) -> bool {
		//push a copy of the lambda and marker to the stack
		lua_pushvalue(L, 1);
		lua_pushlightuserdata(L, reinterpret_cast<void*>(marker));

		//call the lambda copy
		if (lua_pcall(L, 1, 1, 0)) {
			//ya dun fucked up
			std::ostringstream msg;
			msg << "MarkerManager API Error (remove if): " << lua_tostring(L, -1);
			throw(std::runtime_error(msg.str()));
		}

		//check if this marker should be removed
		bool ret = lua_toboolean(L, -1);
		lua_pop(L, 1);

		//finally return the value
		return ret;
	});

	//finally
	return 0;
}

static int removeAllMarkers(lua_State* L) {
	//get the manager
	lua_getglobal(L, MARKER_MANAGER_NAME);
	MarkerManager* markerManager = reinterpret_cast<MarkerManager*>(lua_touserdata(L, -1));

	//remove all
	markerManager->RemoveAll();

	//finally
	return 0;
}

static int size(lua_State* L) {
	//get the manager
	lua_getglobal(L, MARKER_MANAGER_NAME);
	MarkerManager* markerManager = reinterpret_cast<MarkerManager*>(lua_touserdata(L, -1));

	//push the size
	lua_pushinteger(L, markerManager->Size());

	//finally
	return 1;
}

static const luaL_Reg markerManagerLib[] = {
	{"Create", createMarker},
	{"Find", findMarker},
	{"RemoveIf", removeMarkerIf},
	{"RemoveAll", removeAllMarkers},
	{"Size", size},
	{nullptr, nullptr}
};

LUAMOD_API int openMarkerManagerAPI(lua_State* L) {
	luaL_newlib(L, markerManagerLib);
	return 1;
}