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
#pragma once

//#include "marker.hpp"

#include "SDL2/SDL.h"
#include "SDL2/SDL_ttf.h"

#include <functional>
#include <list>

//TODO: temporary placeholder
struct Marker {
	int foobar = 0;
};

class MarkerManager {
public:
	MarkerManager() = default;
	~MarkerManager();

	TTF_Font* SetFont(TTF_Font* font);
	TTF_Font* GetFont() const;

	Marker* CreateMarker();

	void ForEach(std::function<void(Marker*)> lambda);
	void RemoveIf(std::function<bool(Marker*)> lambda);
	void RemoveAll();

	int Size();

	//render
	void DrawTo(SDL_Renderer* const renderer, int camX, int camY, double scaleX = 1.0, double scaleY = 1.0);

private:
	std::list<Marker*> markerList;
	TTF_Font* font = nullptr;
};