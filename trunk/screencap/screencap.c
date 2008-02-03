/* screencap
 * binarymillenium 2007
 * This file is a Frei0r plugin.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#ifdef USEWX
#include <wx/wx.h>
#include <wx/rawbmp.h>
#else
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#endif

extern "C" {
#include "frei0r.h"
}


typedef struct screencap_instance
{
	unsigned int x;
	unsigned int y;
  unsigned int width;
  unsigned int height;

#ifdef USEWX
	wxBitmap* bmp;
	HBITMAP bitmap;
	int savewximage;
	wxDC& dc;
#else
    Display *dpy;
    //XImage *ximage;
#endif

} screencap_instance_t;

#ifdef USEWX
bool wxScreenCapture(wxDC& dc,int x, int y, int sizeX, int sizeY, wxBitmap* bmp, HBITMAP& bitmap, int savewximage)
{
	//sizeX = sizeX; //GetSystemMetrics(SM_CXSCREEN);
	//sizeY = sizeY; //GetSystemMetrics(SM_CYSCREEN);
     static int compat_counter = 0;
	compat_counter++;

	bmp->SetHeight(sizeY);
	bmp->SetWidth(sizeX);


	HDC mainWinDC = GetDC(GetDesktopWindow());
	HDC memDC = CreateCompatibleDC(mainWinDC);

    if (bitmap != NULL) {
        std::cout << "bitmap deleted" << std::endl;
        DeleteObject(bitmap);
    }

	bitmap = CreateCompatibleBitmap(mainWinDC,sizeX,sizeY);

	if (bitmap == NULL) {
		std::cerr << "CreateCompatibleBitmap failed at " <<
					 compat_counter << std::endl; 

		//      mainWinDC << " " << sizeX << " " <<
		//sizeY << std::endl;
		exit(1);
		return false;
	}

	HGDIOBJ hOld = SelectObject(memDC,bitmap);
	BitBlt(memDC, 0, 0,sizeX,sizeY, mainWinDC, x, y, SRCCOPY);
	SelectObject(memDC, hOld);
	DeleteDC(memDC);
	ReleaseDC(GetDesktopWindow(), mainWinDC);
	bmp->SetHBITMAP((WXHBITMAP)bitmap);
	if (bmp->Ok() ) {
		//dc.DrawText( _T("BMP ok"), 30, 20 );

	} else {
		//dc.DrawText( _T("BMP not ok"), 30, 20 );
		std::cerr << "bmp not ok" << std::endl;
		return false;
	}

	if (savewximage) {
		bmp->SaveFile( wxT("/cygdrive/b/text.bmp"), wxBITMAP_TYPE_BMP);
	}

	return true;

}
#endif

/* Clamps a int32-range int between 0 and 255 inclusive. */
unsigned char CLAMP0255(int32_t a)
{
  return (unsigned char)
    ( (((-a) >> 31) & a)  // 0 if the number was negative
      | (255 - a) >> 31); // -1 if the number was greater than 255
}

int f0r_init()
{
#ifdef USEWX
    wxInitialize();
#else
#endif
  return 1;
}

void f0r_deinit()
{
#ifdef USEWX
wxUninitialize();
#endif
}

void f0r_get_plugin_info(f0r_plugin_info_t* inverterInfo)
{
  inverterInfo->name = "screencap";
  inverterInfo->author = "binarymillenium";
  inverterInfo->plugin_type = F0R_PLUGIN_TYPE_FILTER;
  inverterInfo->color_model = F0R_COLOR_MODEL_BGRA8888;
  inverterInfo->frei0r_version = FREI0R_MAJOR_VERSION;
  inverterInfo->major_version = 0; 
  inverterInfo->minor_version = 2; 
  inverterInfo->num_params =  2; 
  inverterInfo->explanation = "grabs an image of the desktop";
}

void f0r_get_param_info(f0r_param_info_t* info, int param_index)
{
  switch(param_index)
  {
  case 0:
    info->name = "x offset";
    info->type = F0R_PARAM_DOUBLE;
    info->explanation = "x offset";
    break;

  case 1:
    info->name = "y offset";
    info->type = F0R_PARAM_DOUBLE;
    info->explanation = "y offset";
    break;
  }
}

f0r_instance_t f0r_construct(unsigned int width, unsigned int height)
{
  screencap_instance_t* inst = 
    (screencap_instance_t*)malloc(sizeof(screencap_instance_t));

  inst->width = width; 
  inst->height = height;

  inst->x = 0;
  inst->y = 0;

#ifdef USEWX
  inst->bmp = new wxBitmap;
  inst->bitmap = NULL;
  inst->savewximage = 0; 
#else
  inst->dpy = XOpenDisplay(NULL);
#endif
  return (f0r_instance_t)inst;
}

void f0r_destruct(f0r_instance_t instance)
{
  free(instance);
}

void f0r_set_param_value(f0r_instance_t instance, 
                         f0r_param_t param, int param_index)
{
  assert(instance);
  screencap_instance_t* inst = (screencap_instance_t*)instance;

  switch(param_index)
  {
  case 0:
    inst->x = (unsigned int)(1000.0*(*(double*)param));
    break;
  case 1:
    inst->y = (unsigned int)(1000.0*(*(double*)param));
    break;

  }
}

void f0r_get_param_value(f0r_instance_t instance,
                         f0r_param_t param, int param_index)
{
  assert(instance);
  screencap_instance_t* inst = (screencap_instance_t*)instance;
  
  switch(param_index)
  {
  case 0:
    *(double*)param = (double)inst->x;
    break;
 case 1:
    *(double*)param = (double)inst->y;
    break;

  }
}

void f0r_update(f0r_instance_t instance, double time,
                const uint32_t* inframe, uint32_t* outframe)
{
  assert(instance);
  screencap_instance_t* inst = (screencap_instance_t*)instance;
  unsigned int len = inst->width * inst->height;
  
  unsigned char* dst = (unsigned char*)outframe;
  const unsigned char* src = (unsigned char*)inframe;


  int r, g, b, bw;

 
 #ifdef USEWX
  if (!wxScreenCapture(inst->dc, inst->x, inst->y, inst->width, inst->height,
	 inst->bmp, inst->bitmap, inst->savewximage))
	return;


  /// get image from desktop in wxBitmap format,
  wxAlphaPixelData rawbmp(*(inst->bmp), wxPoint(0,0),
          wxSize(inst->width, inst->height));
  wxAlphaPixelData::Iterator p(rawbmp);  


   for (unsigned i = 0; (i < inst->height); i++) {
   for (unsigned j = 0; (j < inst->width); j++) { 
     
 //r = src[0];
      //g = src[1];
      //b = src[2];

      int ind = i*inst->width + j;

      bool flip = false;
// ((i > inst->height/4-1) && (i < 3*inst->height/4)
//		      && (j > inst->width/4-1) && (j < 3*inst->width/4));

	dst[2] = flip ? 255 - p.Red()  : p.Red();
	dst[1] = flip ? 255 - p.Green(): p.Green();
	dst[0] = flip ? 255 - p.Blue() : p.Blue();

      p.MoveTo(rawbmp, j, i); 

	dst += 4;
    }
  }
  DeleteObject(inst->bitmap);
	inst->bitmap = NULL;
#else
    
    XImage *ximage;

    /// this will crash if x + width is bigger than the screen size
    /// TBD how to find out the screen size?
    if (inst->x + inst->width >= 1024) inst->x = 1024-inst->width-1;
    if (inst->y + inst->height >= 800) inst->y = 800-inst->height-1;
    ximage = XGetImage(inst->dpy, RootWindow(inst->dpy, DefaultScreen(inst->dpy)) ,
                       2*inst->x, inst->y,
                       inst->width, inst->height, AllPlanes, ZPixmap);
    if (!ximage) {
        std::cerr << "XGetImage failed" << std::endl;
    } 


    for (unsigned i = 0; (i < inst->height); i++) {
        for (unsigned j = 0; (j < inst->width); j++) {
            int ind = i*inst->width + j;

            bool flip = ((i > inst->height/4-1) && (i < 3*inst->height/4) &&
                    (j > inst->width/4-1)  && (j < 3*inst->width/4));
            flip = !flip;
            flip = true;

            unsigned long thepix = 0; //ximage->data + ind*3; 
                thepix = XGetPixel(ximage, j,i); //ximage->data + ind*3; i
            unsigned short red   = (thepix & ximage->red_mask) >> 16;
            unsigned short green = (thepix & ximage->green_mask) >> 8;
            unsigned short blue  = (thepix & ximage->blue_mask) >> 0;

            int incr = 4;
            dst[ind*incr+2] = flip ? red   : 255-red;
            dst[ind*incr+1] = flip ? green : 255-green;
            dst[ind*incr+0] = flip ? blue  : 255-blue;
            //dst[ind*4+3] = 1.0;

	        //dst += incr;
        } 
    }

    XDestroyImage(ximage);
#endif

}

