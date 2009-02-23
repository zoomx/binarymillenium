/* 

 Copyright (C) 2009
    
    binarymillenium@gmail.com
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.*/


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

#include <math.h>


#include "arboardmodule.h"

void findMarkers(ARUint8* dataPtr, ARParam cparam, InstancePtr inst,int xsize, int ysize); 

typedef struct _MyInstance {

	ARParam  wparam;
    int             xsize, ysize;

} MyInstance, *MyInstancePtr;

int init(logT log_function)
{
  return 1;
}

void shutDown(void)
{
}

MyInstance* construct()
{
    MyInstance* my = (MyInstancePtr) malloc(sizeof(MyInstance));

    int             count = 0;


    /* set the initial camera parameters */
    if( arParamLoad("/home/lucasw/other/sw/ARToolKit/bin/Data/camera_para.dat", 1, &(my->wparam) ) < 0 ) {
        fprintf(stderr,"Camera parameter load error !!\n");
        //exit(0);
    }

        int patt_id;
    
    if( (patt_id=arLoadPatt("/home/lucasw/other/sw/ARToolKit/bin/Data/patt.hiro")) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
    }
   //fprintf(stderr,"patt.hiro %d\n", patt_id);

    if( (patt_id=arLoadPatt("/home/lucasw/other/sw/ARToolKit/bin/Data/patt.sample1")) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
    }
   //fprintf(stderr,"patt.sample1 %d\n", patt_id);

    if( (patt_id=arLoadPatt("/home/lucasw/other/sw/ARToolKit/bin/Data/patt.sample2")) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
    }
   //fprintf(stderr,"patt.sample2 %d\n", patt_id);

    if( (patt_id=arLoadPatt("/home/lucasw/other/sw/ARToolKit/bin/Data/patt.kanji")) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
    }
    //fprintf(stderr,"patt.kanji %d\n", patt_id);

    // printf("%s,\t\n",cur_filename);

    return my;
}

void destruct(MyInstance* my)
{
  argCleanup();
  free(my);
}

void update(void* instance)
{
    InstancePtr inst = (InstancePtr) instance;
   
    ARParam         cparam;
    int xsize = inst->in_1->xsize;
    int ysize = inst->in_1->ysize;
    /// TBD only do this when change in size is detected
    arParamChangeSize( & (inst->my->wparam), xsize, ysize, &cparam );
    arInitCparam( &cparam );
    //arParamDisp( &cparam );

    ARUint8 *dataPtr;// = (ARUint8*) inst->in_1->framebuffer;
    dataPtr = malloc(sizeof(ARUint8) * 3 * ysize * xsize);
    ARUint8 *tmp = dataPtr;

    int* src = (int*)inst->in_1->framebuffer;
    
    int x;
    int y;
    for (y =0; y < ysize; y++) {
    for (x =0; x < xsize; x++) {
        
        unsigned char* tmpc = (unsigned char*)(src); 
        tmp[0] = tmpc[0];   
        tmp[1] = tmpc[1];   
        tmp[2] = tmpc[2];
        tmp+=3;
        src++;
    }}

    findMarkers(dataPtr, cparam, inst, xsize, ysize);
    free(dataPtr);
}


void findMarkers(ARUint8* dataPtr, ARParam cparam, InstancePtr inst,int xsize, int ysize) 
{
    ARMarkerInfo    *marker_info;
    int             marker_num;
    int             j, k;
    int             thresh = 100;

    // detect the markers in the video frame 
    int rv = arDetectMarker(dataPtr, thresh, &marker_info, &marker_num);
    if (rv < 0) {
       // fprintf(stderr,"arDetectMarker failed\n");
       // exit(0);
    }

    //fprintf(stderr,"%d markers_found \n", marker_num);

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

#if 0
         printf("%g,\t%d,\t%g,\t%g,\t%g,\t%g,\t%g,\t\n",
            (float)marker_info[k].area/(float)(xsize*ysize), marker_info[k].id, marker_info[k].cf, 
           // marker_info[k].pos[0]/(float)xsize,         marker_info[k].pos[1]/(float)(ysize), 
            ox,         oy, 
           // marker_info[k].pos[0],         marker_info[k].pos[1], 
           // marker_info[k].vertex[0][0]/(float)xsize,   marker_info[k].vertex[0][1]/(float)(ysize));
            marker_info[k].vertex[0][0],   marker_info[k].vertex[0][1]
            );
#endif
            if (marker_info[k].id == 0) {
                inst->out_x1->number = marker_info[k].pos[0]/(float)xsize;
                inst->out_y1->number = marker_info[k].pos[1]/(float)ysize;
                inst->out_r1->number = 0;

            } 
            if (marker_info[k].id == 1) {
                inst->out_x2->number = marker_info[k].pos[0]/(float)xsize;
                inst->out_y2->number = marker_info[k].pos[1]/(float)ysize;
                inst->out_r2->number = 0; 
            }
        }
       
        /// print rotation matrix
        #if 0
        double          patt_trans[3][4];
		//fprintf("%f,\t%f,\t", patt_center[0], patt_center[1]);
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
        #endif
	}
}



 
