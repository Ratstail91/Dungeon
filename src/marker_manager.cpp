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
#include "marker_manager.hpp"

#include "render_text_texture.hpp"

#include <algorithm>

MarkerManager::~MarkerManager() {
	RemoveAll();
}

TTF_Font* MarkerManager::SetFont(TTF_Font* f) {
	return font = f;
}

TTF_Font* MarkerManager::GetFont() const {
	return font;
}

Marker* MarkerManager::CreateMarker() {
	Marker* marker = new Marker();
	markerList.push_back(&*marker);
	return marker;
}

void MarkerManager::ForEach(std::function<void(Marker*)> lambda) {
	std::for_each(markerList.begin(), markerList.end(), [&](Marker* marker) -> void {
		lambda(marker);
	});
}

void MarkerManager::RemoveIf(std::function<bool(Marker*)> lambda) {
	markerList.remove_if([&](Marker* marker) -> bool {
		if(lambda(marker)) {
			delete marker;
			return true;
		}
		return false;
	});
}

void MarkerManager::RemoveAll() {
	std::for_each(markerList.begin(), markerList.end(), [&](Marker* marker) -> void {
		delete marker;
	});
	markerList.clear();
}

int MarkerManager::Size() {
	return markerList.size();
}

void MarkerManager::DrawTo(SDL_Renderer* const renderer, int camX, int camY, double scaleX, double scaleY) {
	std::for_each(markerList.begin(), markerList.end(), [&](Marker* marker) -> void {
		//prevent an empty texture throwing an error
		if (marker->GetText().size() == 0) {
			return;
		}

		renderTextDirect(renderer, font, SDL_Color{0, 255, 0, 255}, marker->GetText(),
			(marker->GetX() - camX) * scaleX,
			(marker->GetY() - camY) * scaleY
		);
	});
}
