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

#include <iostream>

ExampleScene::ExampleScene(lua_State* L) {
	luaState = L;

	image.Load(GetRenderer(), "rsc/krstudios.png");
	tileSheet.Load(GetRenderer(), "rsc/overworld.png", 32, 32);

	pager.SetLuaState(luaState);

	//setup the fonts
	inputFont = TTF_OpenFont("rsc/coolvetica rg.ttf", 24);
	textboxFont = TTF_OpenFont("rsc/coolvetica rg.ttf", 12);

	if (!inputFont || !textboxFont) {
		throw(std::runtime_error("Failed to load a font"));
	}

	//setup the textfield & textbox
	textField.SetBounds({0, 0, 128, 12});
	textBox.PushLine(GetRenderer(), textboxFont, SDL_Color{255, 255, 255, 255}, "Testing....");
	textBox.SetY(24);
}

ExampleScene::~ExampleScene() {
	TTF_CloseFont(inputFont);
	TTF_CloseFont(textboxFont);
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
	image.DrawTo(renderer, 0, 0, .5, .5);
	textField.DrawTo(renderer);
	textBox.DrawTo(renderer);
}

//-------------------------
//input events
//-------------------------

void ExampleScene::MouseMotion(SDL_MouseMotionEvent const& event) {
	//
}

void ExampleScene::MouseButtonDown(SDL_MouseButtonEvent const& event) {
	textField.MouseButtonDown(event);
	if (textField.GetFocus()) {
		std::cout << "Focus" << std::endl;
	}
}

void ExampleScene::MouseButtonUp(SDL_MouseButtonEvent const& event) {
	//
}

void ExampleScene::MouseWheel(SDL_MouseWheelEvent const& event) {
	//
}

void ExampleScene::KeyDown(SDL_KeyboardEvent const& event) {
	//hotkeys
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
					textBox.PushLine(GetRenderer(), textboxFont, SDL_Color{255, 255, 255, 255}, textField.GetText());
					textField.SetText(GetRenderer(), inputFont, SDL_Color{255,255,255,255}, std::string(""));
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
				textField.PopChars(GetRenderer(), inputFont, SDL_Color{255, 255, 255, 255}, 1);
			}
	}
}

void ExampleScene::KeyUp(SDL_KeyboardEvent const& event) {
	//
}

void ExampleScene::TextInput(SDL_TextInputEvent const& event) {
	textField.PushText(GetRenderer(), inputFont, SDL_Color{255, 255, 255, 255}, std::string(event.text));
}