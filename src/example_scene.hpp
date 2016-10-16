/* Copyright: (c) Kayne Ruse 2013-2016
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
#pragma once

#include "base_scene.hpp"

#include "image.hpp"
#include "region_pager_lua.hpp"
#include "tile_sheet.hpp"

#include "lua.hpp"

class ExampleScene : public BaseScene {
public:
	ExampleScene(lua_State* L);
	~ExampleScene();

	void RenderFrame(SDL_Renderer* renderer) override;

private:
	//frame phases
	void FrameStart() override;
	void Update() override;
	void FrameEnd() override;

	//input events
	void MouseMotion(SDL_MouseMotionEvent const& event) override;
	void MouseButtonDown(SDL_MouseButtonEvent const& event) override;
	void MouseButtonUp(SDL_MouseButtonEvent const& event) override;
	void MouseWheel(SDL_MouseWheelEvent const& event) override;
	void KeyDown(SDL_KeyboardEvent const& event) override;
	void KeyUp(SDL_KeyboardEvent const& event) override;

	//test members
	lua_State* luaState = nullptr;

	Image image;
	RegionPagerLua pager;
	TileSheet tileSheet;
};
