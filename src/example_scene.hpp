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

#include "cursor.hpp"
#include "cursor_api.hpp"
#include "image.hpp"
#include "marker_manager.hpp"
#include "marker_manager_api.hpp"
#include "region_pager_api.hpp"
#include "region_pager_lua.hpp"
#include "text_box.hpp"
#include "text_field.hpp"
#include "texture_util.hpp"
#include "tile_sheet.hpp"
#include "tile_sheet_api.hpp"

#include "lua.hpp"

#include "SDL2/SDL_ttf.h"

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
	void TextInput(SDL_TextInputEvent const& event) override;

	void PublishMapScreen();

	//camera
	struct Camera {
		double x = 0, y = 0;
		double zoom = 1.0;
	} camera;

	//selection
	Cursor cursor;

	//markers
	MarkerManager markerManager;

	//test members
	lua_State* luaState = nullptr;

	//tile members
	RegionPagerLua regionPager;
	TileSheet tileSheet;

	//text inputs
	TTF_Font* inputFont = nullptr;
	TTF_Font* textboxFont = nullptr;
	TextField textField;
	TextBox textBox;
};
