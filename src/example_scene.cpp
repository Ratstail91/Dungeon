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
#include "example_scene.hpp"

//TODO: remove this
#include "application.hpp"

#include <algorithm>
#include <iostream>
#include <sstream>

//TODO: have scripts work without c-style this parameters

ExampleScene::ExampleScene(lua_State* L) {
	//setup the lua state
	luaState = L;
	regionPager.SetLuaState(luaState);

	//push the necessary variables to the lua state
	lua_pushlightuserdata(luaState, &regionPager);
	lua_setglobal(luaState, REGION_PAGER_NAME);

	lua_pushlightuserdata(luaState, &tileSheet);
	lua_setglobal(luaState, TILESHEET_NAME);

	lua_pushlightuserdata(luaState, GetRenderer());
	lua_setglobal(luaState, RENDERER_NAME);

	lua_pushlightuserdata(luaState, &cursor);
	lua_setglobal(luaState, CURSOR_NAME);

	lua_pushlightuserdata(luaState, &markerManager);
	lua_setglobal(luaState, MARKER_MANAGER_NAME);

	//run the startup script
	if (luaL_dofile(luaState, "scr/setup.lua")) {
		throw(std::runtime_error("Failed to run scr/setup.lua"));
	}

	//setup the fonts
	inputFont = TTF_OpenFont("rsc/coolvetica rg.ttf", 24);
	textboxFont = TTF_OpenFont("rsc/coolvetica rg.ttf", 12);
	markerFont = TTF_OpenFont("rsc/coolvetica rg.ttf", 36);

	if (!inputFont || !textboxFont) {
		throw(std::runtime_error("Failed to load a font"));
	}

	//setup the textfield & textbox
	textField.SetBounds({0, 0, 128, 24});
	textField.SetY(screenHeight - 36);
	textBox.SetY(screenHeight - 36 - 12*6);

	//debugging
	markerManager.SetFont(markerFont);
}

ExampleScene::~ExampleScene() {
	//wipe the variables from the lua state
	lua_pushnil(luaState);
	lua_setglobal(luaState, MARKER_MANAGER_NAME);

	lua_pushnil(luaState);
	lua_setglobal(luaState, REGION_PAGER_NAME);

	lua_pushnil(luaState);
	lua_setglobal(luaState, TILESHEET_NAME);

	lua_pushnil(luaState);
	lua_setglobal(luaState, RENDERER_NAME);

	lua_pushnil(luaState);
	lua_setglobal(luaState, CURSOR_NAME);


	//close the APIs
	TTF_CloseFont(inputFont);
	TTF_CloseFont(textboxFont);
	TTF_CloseFont(markerFont);
}

//-------------------------
//frame phases
//-------------------------

void ExampleScene::FrameStart() {
	//
}

void ExampleScene::Update() {
	//
}

void ExampleScene::FrameEnd() {
	//
}

void ExampleScene::RenderFrame(SDL_Renderer* renderer) {
	//draw the map
	for (auto& it : *regionPager.GetContainer()) {
		tileSheet.DrawRegionTo(renderer, &it, camera.x, camera.y, camera.zoom, camera.zoom);
	}

	//draw the markers
	markerManager.DrawTo(renderer, camera.x, camera.y, camera.zoom, camera.zoom);

	//draw the terminal
	textField.DrawTo(renderer);
	textBox.DrawTo(renderer);
}

//-------------------------
//input events
//-------------------------

void ExampleScene::MouseMotion(SDL_MouseMotionEvent const& event) {
	//moving the camera
	if (event.state & SDL_BUTTON_RMASK) {
		//note: zoom is reflected in coordinates
		camera.x -= event.xrel / camera.zoom;
		camera.y -= event.yrel / camera.zoom;
	}

	if (event.state & SDL_BUTTON_LMASK) {
		int tileX = (event.x / camera.zoom + camera.x);
		int tileY = (event.y / camera.zoom + camera.y);

		//BUGFIX: This fixes an off-by-one error
		if (tileX >= 0) {
			tileX = tileX / tileSheet.GetClipW();
		}
		else {
			tileX = tileX / tileSheet.GetClipW() - 1;
		}

		if (tileY >= 0) {
			tileY = tileY / tileSheet.GetClipH();
		}
		else {
			tileY = tileY / tileSheet.GetClipH() - 1;
		}

		regionPager.SetTile(tileX, tileY, cursor.layerSelection, cursor.tileSelection);
	}
}

void ExampleScene::MouseButtonDown(SDL_MouseButtonEvent const& event) {
	//NOTE: since this is an editor, I've disabled the click functionality for the terminal
//	textField.MouseButtonDown(event);

	if (event.button == SDL_BUTTON_LEFT) {
		int tileX = (event.x / camera.zoom + camera.x);
		int tileY = (event.y / camera.zoom + camera.y);

		//BUGFIX: This fixes an off-by-one error
		if (tileX >= 0) {
			tileX = tileX / tileSheet.GetClipW();
		}
		else {
			tileX = tileX / tileSheet.GetClipW() - 1;
		}

		if (tileY >= 0) {
			tileY = tileY / tileSheet.GetClipH();
		}
		else {
			tileY = tileY / tileSheet.GetClipH() - 1;
		}

		regionPager.SetTile(tileX, tileY, cursor.layerSelection, cursor.tileSelection);
	}
}

void ExampleScene::MouseButtonUp(SDL_MouseButtonEvent const& event) {
	//
}

void ExampleScene::MouseWheel(SDL_MouseWheelEvent const& event) {
	//toward the user
	if (event.y < 0) {
		camera.zoom /= 2;
	}

	if (camera.zoom < 0.25) {
		camera.zoom = 0.25;
	}

	//away from the user
	if (event.y > 0) {
		camera.zoom *= 2;
	}

	if (camera.zoom > 4.0) {
		camera.zoom = 4.0;
	}
}

void ExampleScene::KeyDown(SDL_KeyboardEvent const& event) {
	//hotkeys
	if (event.keysym.mod & KMOD_CTRL) {
		switch(event.keysym.sym) {
			case SDLK_l:
				//save the map data
				luaL_dostring(luaState, "load()");
			break;

			case SDLK_s:
				//save the map data
				luaL_dostring(luaState, "save()");
			break;

			case SDLK_q:
				//publish the map data
				PublishMapScreen();
			break;
		}

		return;
	}

	//hotkeys, no recognized mods
	switch(event.keysym.sym) {
		case SDLK_ESCAPE:
			QuitEvent();
		break;

		case SDLK_RETURN:
			//not focus
			if (!textField.GetFocus()) {
				textField.SetFocus(true);
				SDL_StartTextInput();
			}
			//focus
			else {
				if (textField.GetText().length() > 0) {
					luaL_dostring(luaState, textField.GetText().c_str());
					textBox.PushLine(GetRenderer(), textboxFont, SDL_Color{0, 255, 0, 255}, textField.GetText());
					textField.SetText(GetRenderer(), inputFont, SDL_Color{0, 255, 0, 255}, std::string(""));
				}
				textField.SetFocus(false);
				SDL_StopTextInput();
				while (textBox.GetContainer()->size() > 5) {
					textBox.PopLines();
				}
			}
		break;

		case SDLK_BACKSPACE:
			//easier than mucking about with SDL_TextEditEvent
			if (textField.GetFocus()) {
				textField.PopChars(GetRenderer(), inputFont, SDL_Color{0, 255, 0, 255}, 1);
			}
	}
}

void ExampleScene::KeyUp(SDL_KeyboardEvent const& event) {
	//
}

void ExampleScene::TextInput(SDL_TextInputEvent const& event) {
	textField.PushText(GetRenderer(), inputFont, SDL_Color{0, 255, 0, 255}, std::string(event.text));
}

void ExampleScene::PublishMapScreen() {
	//determine the width and height of the image file
	int lowerX = 0, upperX = 0;
	int lowerY = 0, upperY = 0;

	std::for_each(regionPager.GetContainer()->begin(), regionPager.GetContainer()->end(), [&](Region& r) -> void {
		if (r.GetX() < lowerX) {
			lowerX = r.GetX();
		}
		if (r.GetY() < lowerY) {
			lowerY = r.GetY();
		}
		if (r.GetX() > upperX) {
			upperX = r.GetX();
		}
		if (r.GetY() > upperY) {
			upperY = r.GetY();
		}
	});

	int width = (upperX - lowerX + REGION_WIDTH) * tileSheet.GetClipW();
	int height = (upperY - lowerY + REGION_HEIGHT) * tileSheet.GetClipH();

	//make a texture
	SDL_Texture* texture = SDL_CreateTexture(GetRenderer(), SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, width, height);

	//check
	if (!texture) {
		std::ostringstream msg;
		msg << "Failed to create a texture; " << SDL_GetError();
		throw(std::runtime_error(msg.str()));
	}

	//render each region to the new texture
	SDL_SetRenderTarget(GetRenderer(), texture);

	for (auto& it : *regionPager.GetContainer()) {
		tileSheet.DrawRegionTo(GetRenderer(), &it, lowerX * tileSheet.GetClipW(), lowerY * tileSheet.GetClipH(), 1, 1);
	}

	markerManager.DrawTo(GetRenderer(), lowerX * tileSheet.GetClipW(), lowerY * tileSheet.GetClipH(), 1, 1);

	SDL_SetRenderTarget(GetRenderer(), nullptr);

	//make surface from texture
	SDL_Surface* surface = makeSurfaceFromTexture(GetRenderer(), texture);
	SDL_DestroyTexture(texture);

	//check
	if (!surface) {
		std::ostringstream msg;
		msg << "Failed to create a surface; " << SDL_GetError();
		throw(std::runtime_error(msg.str()));
	}

	//finally
	int ret = savePNG(surface, "screenshot.png");
	std::cout << "Save return code: " << ret << std::endl;
}