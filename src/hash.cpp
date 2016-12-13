/* Copyright: (c) Kayne Ruse 2015
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
#include "hash.hpp"

//DOCS: Do not alter these implementations. People much smarter than you wrote them.

//http://stackoverflow.com/questions/664014/what-integer-hash-function-are-good-that-accepts-an-integer-hash-key
//hash a single 32-bit integer
unsigned uinthash(unsigned x) {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x);
    return x;
}

//hash a byte array into a 32-bit integer
unsigned fnv_hash_1a_32(void *key, int len) {
	unsigned char *p = static_cast<unsigned char*>(key);
	unsigned h = 0x811c9dc5;
	for (int i = 0; i < len; i++) {
		h = ( h ^ p[i] ) * 0x01000193;
	}
	return h;
}

//2D coordinates, and a world seed
unsigned coordhash(unsigned x, unsigned y, unsigned seed) {
	//non-comutative hash
	return uinthash(uinthash(uinthash(x)) ^ uinthash(y) ^ seed);
}

//glue wrappers
//TODO: error checking
static int uinthash_wrapper(lua_State* L) {
	unsigned x = lua_tointeger(L, -1);
	lua_pushnumber(L, uinthash(x));
	return 1;
}

static int fnv_hash_1a_32_wrapper(lua_State* L) {
	void* key = lua_touserdata(L, -2);
	int len = lua_tointeger(L, -1);
	lua_pushnumber(L, fnv_hash_1a_32(key, len));
	return 1;
}

static int coordhash_wrapper(lua_State* L) {
	unsigned x = lua_tointeger(L, -3);
	unsigned y = lua_tointeger(L, -2);
	unsigned s = lua_tointeger(L, -1);
	lua_pushnumber(L, coordhash(x, y, s));
	return 1;
}

static const luaL_Reg hashlib[] = {
	{"uinthash", uinthash_wrapper},
	{"fnv_hash_1a_32", fnv_hash_1a_32_wrapper},
	{"coordhash", coordhash_wrapper},
	{nullptr, nullptr}
};

LUAMOD_API int openHashAPI(lua_State* L) {
	luaL_newlib(L, hashlib);
	return 1;
}