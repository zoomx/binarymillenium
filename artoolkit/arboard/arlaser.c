/**
 * binarymillenium 2008-2009
 *
 *
 * Offered under the latest version of the GNU GPL
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
#include <GL/glut.h>
#else
#include <OpenGL/gl.h>
#include <GLUT/glut.h>
#endif
#include <AR/gsub.h>
#include <AR/video.h>
#include <AR/param.h>
#include <AR/ar.h>

#include <wand/MagickWand.h>

#include <math.h>

void findMarkers(ARUint8* dataPtr, int patt_id); 
ARUint8* loadImage(char* filename);
int             xsize, ysize;


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

    char           *cparam_name    = "../calib_camera2/newparam.dat";
    ARParam         cparam;

    char           *patt_name      = "patt.hiro";
    int             patt_id;

    char* cur_filename;
    
    int one = 1;
    glutInit(&one,argv);

    cur_filename = argv[1];

    fprintf(stderr,"%d %s,\n", argc, cur_filename);
    fprintf(stdout,"%s,\t",cur_filename);

    /// make this get an image with curl
	dataPtr	    = loadImage(cur_filename);

	ARParam  wparam;
	
    /* set the initial camera parameters */
    if( arParamLoad(cparam_name, 1, &wparam) < 0 ) {
        fprintf(stderr,"Camera parameter load error !!\n");
        exit(0);
    }
    arParamChangeSize( &wparam, xsize, ysize, &cparam );
    arInitCparam( &cparam );
    //fprintf(stderr,"*** Camera Parameter ***\n");
    //arParamDisp( &cparam );

    if( (patt_id=arLoadPatt(patt_name)) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
        exit(0);
    }

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
    argInit( &cparam, 1.0, 0, 0, 0, 0 );

	findMarkers(dataPtr,patt_id);

    argCleanup();
}

void findMarkers(ARUint8* dataPtr, int patt_id) 
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

    printf("%d markers_found \n", marker_num);

    // check for object visibility 
    k = -1;
    for ( j = 0; j < marker_num; j++ ) {
        if ( patt_id == marker_info[j].id ) {
            if( k == -1 ) k = j;
            else if( marker_info[k].cf < marker_info[j].cf ) k = j;
        }
    }
  	
    if( k == -1 ) {
		//fprintf(stderr,"no visible objects\n");
      
	   int i;
		for (i = 0; i < 12; i++) {
				fprintf(stdout, "0,\t");	
		}
		fprintf(stdout,"\n");
    
    } else {
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
				fprintf(stdout, "%f,\t", patt_trans[j][i]);	
			}
			printf("\t");
		}
		fprintf(stdout,"\n");
	}
}


ARUint8* loadImage(char* filename)
{
	ARUint8 *dptr;
	
	Image *image;
	MagickWand* magick_wand;

	MagickWandGenesis();
	magick_wand=NewMagickWand(); 
	

	MagickBooleanType status=MagickReadImage(magick_wand,filename);
	if (status == MagickFalse) {
		fprintf(stderr, "%s cant be read\n", filename);
		return; //(1);
		//ThrowWandException(magick_wand);
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

