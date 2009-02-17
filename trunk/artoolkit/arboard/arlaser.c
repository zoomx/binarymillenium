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

void findMarkers(ARUint8* dataPtr); 
ARUint8* loadImage(char* filename);
int             xsize, ysize;

   ARParam         cparam;

int main(int argc, char **argv)
{
    ARUint8 *dataPtr;

    //
    // Camera configuration.
    //
#ifdef _WIN32
    char			*vconf = "Data\\WDM_camera_flipV.xml";
#else
    char			*vconf = "";
#endif

    int             count = 0;

   // char           *cparam_name    = "../calib_camera2/newparam.dat";

    char path[100];
    char cparam_name[100];
    char* cur_filename;
   
    if (argc < 2) {
        fprintf(stderr,"provide a jpeg file name\n");
        return;
    }
    

    int one = 1;
    //glutInit(&one,argv);


    cur_filename = argv[1];

    if (argc > 2) {
        sprintf(path,"%s/", argv[2]);
    } else {
        sprintf(path, "");
    }

    fprintf(stderr,"%d %s,\n", argc, cur_filename);

    /// make this get an image with curl
	dataPtr	    = loadImage(cur_filename);

	ARParam  wparam;

    sprintf(cparam_name,"%s%s",path,"camera_para.dat");
    fprintf(stderr,"%s\n", cparam_name);

    /* set the initial camera parameters */
    if( arParamLoad(cparam_name, 1, &wparam) < 0 ) {
    //if( arParamLoad("camera_para.dat", 1, &wparam) < 0 ) {
        fprintf(stderr,"Camera parameter load error !!\n");
        exit(0);
    }
    arParamChangeSize( &wparam, xsize, ysize, &cparam );
    arInitCparam( &cparam );
    //fprintf(stderr,"*** Camera Parameter ***\n");
    //arParamDisp( &cparam );

    int patt_id;
    char buffer[100];
    
    sprintf(buffer,"%spatt.hiro",path);
    if( (patt_id=arLoadPatt(buffer)) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
        exit(0);
    }

    sprintf(buffer,"%spatt.sample1",path);
    if( (patt_id=arLoadPatt(buffer)) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
        exit(0);
    }

    sprintf(buffer,"%spatt.sample2",path);
    if( (patt_id=arLoadPatt(buffer)) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
        exit(0);
    }
   // fprintf(stderr,"patt.sample2 %d\n", patt_id);


#if 0
	fprintf(stderr,"xysize %d %d\n\
cparam %g\t%g\t%g\t%g\n \
mat\n \
%g\t%g\t%g\t%g\n \
%g\t%g\t%g\t%g\n \
%g\t%g\t%g\t%g\n", 
		cparam.xsize, cparam.ysize,
		cparam.dist_factor[0], cparam.dist_factor[1], cparam.dist_factor[2], cparam.dist_factor[3], 
		cparam.mat[0][0], cparam.mat[0][1], cparam.mat[0][2], cparam.mat[0][3], 	
		cparam.mat[1][0], cparam.mat[1][1], cparam.mat[1][2], cparam.mat[1][3], 	
		cparam.mat[2][0], cparam.mat[2][1], cparam.mat[2][2], cparam.mat[2][3]	
		);
#endif

    /* open the graphics window */
    //argInit( &cparam, 1.0, 0, 0, 0, 0 );

    printf("%s,\t\n",cur_filename);
	findMarkers(dataPtr);

    argCleanup();
}

void findMarkers(ARUint8* dataPtr) 
{
    ARMarkerInfo    *marker_info;
    int             marker_num;
    int             j, k;
    int             thresh = 100;

    // detect the markers in the video frame 
    int rv = arDetectMarker(dataPtr, thresh, &marker_info, &marker_num);
    if (rv < 0) {
        fprintf(stderr,"arDetectMarker failed\n");
        exit(0);
    }

    fprintf(stderr,"%d markers_found \n", marker_num);

/*
    // check for object visibility 
    k = -1;
        if ( patt_id == marker_info[j].id ) {
            if( k == -1 ) k = j;
            else if( marker_info[k].cf < marker_info[j].cf ) k = j;
        }
    }
  */	
    
    for ( k = 0; k < marker_num; k++ ) {

        if (1) {
        double ox,oy;
        arParamIdeal2Observ(cparam.dist_factor ,  marker_info[k].pos[0], marker_info[k].pos[1], &ox, &oy);


        printf("%g,\t%d,\t%g,\t%g,\t%g,\t%g,\t%g,\t",
            (float)marker_info[k].area/(float)(xsize*ysize), marker_info[k].id, marker_info[k].cf, 
           // marker_info[k].pos[0]/(float)xsize,         marker_info[k].pos[1]/(float)(ysize), 
            ox,         oy, 
           // marker_info[k].pos[0],         marker_info[k].pos[1], 
           // marker_info[k].vertex[0][0]/(float)xsize,   marker_info[k].vertex[0][1]/(float)(ysize));
            marker_info[k].vertex[0][0],   marker_info[k].vertex[0][1]
            );
        }
       
        /// print rotation matrix
        if (0) {
        double          patt_trans[3][4];
        double          patt_width     = 80.0;
        double          patt_center[2] = {0.0, 0.0};
        /* get the transformation between the marker and the real camera */
		arGetTransMat(&marker_info[k], patt_center, patt_width, patt_trans);

		/// what is patt_center, it seems to be zeros
		//fprintf("%f,\t%f,\t", patt_center[0], patt_center[1]);
	
		int i;
		for (j = 0; j < 3; j++) {
		for (i = 0; i < 4; i++) {
				printf("%f,\t", patt_trans[j][i]);	
			}
			printf("\t");
		}
        }
		printf("\n");
	}
}




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

ARUint8* loadImage(char* filename)
{
	ARUint8 *dptr;
	
	Image *image;
	MagickWand* magick_wand;

	MagickWandGenesis();
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

	xsize = image->columns;
	ysize = image->rows;
		
	dptr = malloc(sizeof(ARUint8) * 3 * image->rows * xsize);
	int y;
	index = 0;
	for (y=0; y < (long) image->rows; y++)
	{
		const PixelPacket *p = AcquireImagePixels(image,0,y,xsize,1,&image->exception);
		if (p == (const PixelPacket *) NULL)
			break;
		int x;
		for (x=0; x < (long) xsize; x++)
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

	return dptr;
}

