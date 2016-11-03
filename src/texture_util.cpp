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
#include "texture_util.hpp"

//for screenshots
SDL_Surface* makeSurfaceFromTexture(SDL_Renderer* const renderer, SDL_Texture* texture) {
	//point to the texture
	SDL_SetRenderTarget(renderer, texture);

	//get the width & height of the texture
	int width = 0, height = 0;
	SDL_QueryTexture(texture, nullptr, nullptr, &width, &height);

	//make the surface
	SDL_Surface* surface = SDL_CreateRGBSurface(0, width, height, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);

	if(surface) {
		//Read the pixels from the current render target and save them onto the surface
		SDL_RenderReadPixels(renderer, NULL, 0, surface->pixels, surface->pitch);
	}

	//cleanup
	SDL_SetRenderTarget(renderer, nullptr);

	return surface;
}