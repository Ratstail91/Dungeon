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

#include "lodepng.h"

#include <sstream>
#include <stdexcept>
#include <vector>

#include <iostream>

//for screenshots
SDL_Surface* makeSurfaceFromTexture(SDL_Renderer* const renderer, SDL_Texture* texture) {
	//DEBUG: get the renderer info
	SDL_RendererInfo info;
	SDL_GetRendererInfo(renderer, &info);

	std::cout << "Renderer info:" << std::endl;
	for (int i = 0; i < info.num_texture_formats; i++) {
		std::cout << "\t" << SDL_GetPixelFormatName(info.texture_formats[i]) << std::endl;
	}

	//point to the texture
	SDL_SetRenderTarget(renderer, texture);

	//get the width & height of the texture
	int width = 0, height = 0;
	SDL_QueryTexture(texture, nullptr, nullptr, &width, &height);

	//find a compatible render mode for the new surface
	SDL_Surface* surface = nullptr;
	for (int i = 0; i < info.num_texture_formats; i++) {
		switch (info.texture_formats[i]) {
			case SDL_PIXELFORMAT_ARGB8888:
				surface = SDL_CreateRGBSurface(0, width, height, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
			goto outerbreak;
			//TODO: add more formats here
		}
	}
outerbreak:

	if(surface) {
		//Read the pixels from the current render target and save them onto the surface
		SDL_RenderReadPixels(renderer, NULL, 0, surface->pixels, surface->pitch);
	}

	//cleanup
	SDL_SetRenderTarget(renderer, nullptr);

	return surface;
}

int savePNG(SDL_Surface* surface, const char* fname) {
	//error checking
	if (!surface || !fname) {
		return -1;
	}

    //vars
	std::vector<unsigned char> buffer;

	//make sure there is enough space
	buffer.resize(surface->w * surface->h * 4);

	//convert from SDL_Surface to vector<unsigned char>, one pixel at a time
	for (int y = 0; y < surface->h; y++) {
		for (int x = 0; x < surface->w; x++) {
			//get a pointer to the RGBA data in the surface
			Uint32* rgba = (Uint32*)surface->pixels + (surface->pitch * y / 4) + x;

			//handle various surface formats
			Uint32 r = ((*rgba) >> surface->format->Rshift) & 0xFF;
			Uint32 g = ((*rgba) >> surface->format->Gshift) & 0xFF;
			Uint32 b = ((*rgba) >> surface->format->Bshift) & 0xFF;
			Uint32 a = ((*rgba) >> surface->format->Ashift) & 0xFF;

			//finally, assign the data in RGBA format
			buffer[y*surface->w*4 + x*4 + 0] = r;
			buffer[y*surface->w*4 + x*4 + 1] = g;
			buffer[y*surface->w*4 + x*4 + 2] = b;
			buffer[y*surface->w*4 + x*4 + 3] = 255; //BUGFIX: SDL_Surface's alpha is 0 usually
		}
	}

	//save the converted image to the file
	int error = lodepng::encode(fname, buffer, surface->w, surface->h);

	if (error) {
		std::ostringstream msg;
		msg << "lodepng error: " << lodepng_error_text(error);
		throw(std::runtime_error(msg.str()));
	}

	return 0;
}
