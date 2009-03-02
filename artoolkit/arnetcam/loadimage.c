/**
 * binarymillenium 2008-2009
 *
 *
 * Licensed under the latest version of the GNU GPL
 *
 *
 */

#ifdef _WIN32
#include <windows.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#ifndef __APPLE__
#include <GL/gl.h>
#else
#include <OpenGL/gl.h>
#endif
#include <AR/gsub.h>
#include <AR/video.h>
#include <AR/param.h>
#include <AR/ar.h>

#include <wand/MagickWand.h>

#include <math.h>



#define ThrowWandException(wand) \
{ \
  char \
      *description; \
       \
         ExceptionType \
             severity; \
              \
                description=MagickGetException(wand,&severity); \
                  (void) fprintf(stderr,"%s %s %lu %s\n",GetMagickModule(),description); \
                    description=(char *) MagickRelinquishMemory(description); \
                      exit(-1); \
                      }

ARUint8* loadImage(char* filename, int* xsize, int* ysize)
{
	ARUint8 *dptr;
	
	Image *image;
	MagickWand* magick_wand;

	magick_wand=NewMagickWand(); 
    if( magick_wand == NULL) {
        fprintf(stderr, "bad magickwand\n");
    }

	MagickBooleanType status=MagickReadImage(magick_wand,filename);
	if (status == MagickFalse) {
		//fprintf(stderr, "%s can't be read\n", filename);
		//exit(1);
        //return; //(1);
		ThrowWandException(magick_wand);
	}

	image = GetImageFromMagickWand(magick_wand);

	//ContrastImage(image,MagickTrue); 
	//EnhanceImage(image,&image->exception); 

	int index;

	*xsize = image->columns;
	*ysize = image->rows;
		
	dptr = malloc(sizeof(ARUint8) * 3 * image->rows * *xsize);
	int y;
	index = 0;
	for (y=0; y < (long) image->rows; y++)
	{
		const PixelPacket *p = AcquireImagePixels(image,0,y,*xsize,1,&image->exception);
		if (p == (const PixelPacket *) NULL)
			break;
		int x;
		for (x=0; x < (long) *xsize; x++)
		{
			/// convert to ARUint8 dptr
			/// probably a faster way to give the data straight over
			/// in BGR format
			dptr[index*3+2]   = p->red/256;
			dptr[index*3+1] = p->green/256;
			dptr[index*3] = p->blue/256;
			
			//fprintf(stderr,"%d, %d, %d\t%d\t%d\n", x, y, p->red/256, p->green/256, p->blue/256);
			p++;
			index++;
		}
	}

    DestroyMagickWand(magick_wand);

	return dptr;
}

