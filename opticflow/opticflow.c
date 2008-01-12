/**
 * binarymillenium 2007
 *
 * This code is released under the GPL
 *
 * *
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>


#include "cv.h"
#include "highgui.h"

extern "C" {
#include "frei0r.h"
}

#ifdef _EiC
#define WIN32
#endif


const int MAX_COUNT = 500;
const int WIN_SIZE = 10;

void detect_and_draw(f0r_instance_t instance);

typedef struct opticflow_instance{

    //CvCapture* capture;
    IplImage *frame_copy;

    int width;
    int height;

	
	IplImage *image, *grey, *prev_grey, *pyramid, *prev_pyramid, *swap_temp;
	//int win_size;
	CvPoint2D32f* points[2], *swap_points;
	char* status ;
	int count ;
	/// number of features to look for
	int set_count;
	int night_mode;
	int flags;
	int need_to_init;
	int circ_size;
	//int add_remove_pt;
	CvPoint pt;

    const char* input_name;
} opticflow_instance_t;

int f0r_init()
{
	return 1;
}

f0r_instance_t f0r_construct(unsigned int width, unsigned int height) //( int argc, char** argv )
{
    opticflow_instance_t* inst = 
        (opticflow_instance_t*)malloc(sizeof(opticflow_instance_t));

    inst->width = width;
    inst->height = height;

	inst->circ_size = 1;
    inst->set_count = MAX_COUNT;
	//
    //inst->capture = 0;
    inst->frame_copy = 0;

	int argc = 0;
	char** argv;

	inst->image = 0;

    //cvNamedWindow( "result", 1 );

    return (f0r_instance_t)inst;
}


void f0r_deinit()
{
}

void f0r_destruct(f0r_instance_t instance)
{
    free(instance);
    //cvDestroyWindow("result");
}

void f0r_set_param_value(f0r_instance_t instance,
                         f0r_param_t param, int param_index)
{
    assert(instance);
    opticflow_instance_t* inst = (opticflow_instance_t*)instance;

    switch(param_index)
    {
		case 0:
			if ( *((double*)param) > 0.5) {
				inst->need_to_init = 1;

				//printf("%f\r\n", *((double*)param) );	
					}
			break;
		case 1:
			inst->circ_size = (int) ( fabs(*((double*)param)) + 1.0);
		case 2:
			inst->set_count = (int) ( fabs(*((double*)param)) );
			if (inst->set_count > MAX_COUNT) {
				inst->set_count = MAX_COUNT;
			}
			if (inst->set_count < 1) {
				inst->set_count = 1;
			}

		break;
	}

}

void f0r_get_param_value(f0r_instance_t instance,
        f0r_param_t param, int param_index)
{
    assert(instance);
    opticflow_instance_t* inst = (opticflow_instance_t*)instance;

}

void f0r_get_plugin_info(f0r_plugin_info_t* opticflowInfo)
{
    opticflowInfo->name = "opencvopticflow";
    opticflowInfo->author = "binarymillenium";
    opticflowInfo->plugin_type = F0R_PLUGIN_TYPE_FILTER;
    opticflowInfo->color_model = F0R_COLOR_MODEL_BGRA8888;
    opticflowInfo->frei0r_version = FREI0R_MAJOR_VERSION;
    opticflowInfo->major_version = 0;
    opticflowInfo->minor_version = 1;
    opticflowInfo->num_params =  3;
    opticflowInfo->explanation = "track image features";
}

void f0r_get_param_info(f0r_param_info_t* info, int param_index)
{
    switch(param_index)
    {
        case 0:
            info->name = "find features";
            info->type = F0R_PARAM_DOUBLE;
            info->explanation = "find features";
            break;
		case 1:
            info->name = "circle size";
            info->type = F0R_PARAM_DOUBLE;
            info->explanation = "size of tracked dots";
            break;
		case 2:
            info->name = "num points";
            info->type = F0R_PARAM_DOUBLE;
            info->explanation = "number of features to find";
            break;

    }

}

void f0r_update(f0r_instance_t instance, double time,
        const uint32_t* inframe, uint32_t* outframe)
{
    assert(instance);

    opticflow_instance_t* inst = (opticflow_instance_t*)instance;


    unsigned char* dst = (unsigned char*)outframe;
    const unsigned char* src = (unsigned char*)inframe;


	/// does this really need to be repeated every frame?
    if( !inst->frame_copy ) {
		inst->frame_copy = cvCreateImage( cvSize(inst->width,inst->height),
				8, 3 );
	}

	if (!inst->image) {
		/* allocate all the buffers */
		inst->image = cvCreateImage( cvGetSize(inst->frame_copy), 8, 3 );
		inst->image->origin = inst->frame_copy->origin;
		inst->grey = cvCreateImage( cvGetSize(inst->frame_copy), 8, 1 );
		inst->prev_grey = cvCreateImage( cvGetSize(inst->frame_copy), 8, 1 );
		inst->pyramid = cvCreateImage( cvGetSize(inst->frame_copy), 8, 1 );
		inst->prev_pyramid = cvCreateImage( cvGetSize(inst->frame_copy), 8, 1 );
		inst->points[0] = (CvPoint2D32f*)cvAlloc(MAX_COUNT*sizeof(inst->points[0][0]));
		inst->points[1] = (CvPoint2D32f*)cvAlloc(MAX_COUNT*sizeof(inst->points[0][0]));
		inst->status = (char*)cvAlloc(MAX_COUNT);
		inst->flags = 0;
		inst->night_mode = 1;

		cvCopy( inst->frame_copy, inst->image, 0 );
		cvCvtColor( inst->image, inst->grey, CV_BGR2GRAY );

		if( inst->night_mode )
			cvZero( inst->image );

	}



	unsigned char* ipli = (unsigned char*)inst->frame_copy->imageData;
	int step = inst->frame_copy->widthStep;

     int m = 3;
	/// convert input into format opencv will understand
    for (unsigned i = 0; (i < inst->height); i++) {
        for (unsigned j = 0; (j < inst->width); j++) { 
			
			ipli[i*step+j*m+2] = src[2];
            ipli[i*step+j*m+1] = src[1];
            ipli[i*step+j*m+0] = src[0];

            //ipli += 4;
            src += 4;
        }
    }

    detect_and_draw( inst );

    ipli = (unsigned char*)inst->frame_copy->imageData;
  
  	/// convert opencv output to frei0r format
    for (unsigned i = 0; (i < inst->height); i++) {
        for (unsigned j = 0; (j < inst->width); j++) { 
            dst[2] = ipli[2];
            dst[1] = ipli[1]; 
            dst[0] = ipli[0];

            ipli += m;
            dst += 4;
        }
    }

    cvReleaseImage( &(inst->frame_copy) );

}

void detect_and_draw( f0r_instance_t instance )
{
    	opticflow_instance_t* inst = (opticflow_instance_t*)instance;

        int i, k, c;

        cvCopy( inst->frame_copy, inst->image, 0 );
        cvCvtColor( inst->image, inst->grey, CV_BGR2GRAY );

        if( inst->night_mode )
            cvZero( inst->image );
	
		if (inst->need_to_init) {	
				/* automatic initialization */
				IplImage* eig = cvCreateImage( cvGetSize(inst->grey), 32, 1 );
				IplImage* temp = cvCreateImage( cvGetSize(inst->grey), 32, 1 );
				double quality = 0.01;
				double min_distance = 10;

				inst->count = inst->set_count;
				cvGoodFeaturesToTrack( inst->grey, eig, temp, inst->points[1], &inst->count,
						quality, min_distance, 0, 3, 0, 0.04 );
				cvFindCornerSubPix( inst->grey, inst->points[1], inst->count,
						cvSize(WIN_SIZE,WIN_SIZE), cvSize(-1,-1),
						cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03));
				cvReleaseImage( &eig );
				cvReleaseImage( &temp );
				
				inst->need_to_init = 0;
				//inst->add_remove_pt = 0;

				for( i = k = 0; i < inst->count; i++ ) {
					inst->points[1][k++] = inst->points[1][i];
					cvCircle( inst->image, cvPointFrom32f(inst->points[1][i]), inst->circ_size, CV_RGB(255,255,255), -1, 8,0);
				}
		}
		
		else if( inst->count > 0 )
        {
            cvCalcOpticalFlowPyrLK( inst->prev_grey, inst->grey, inst->prev_pyramid, inst->pyramid,
                inst->points[0], inst->points[1], inst->count, cvSize(WIN_SIZE,WIN_SIZE), 3, inst->status, 0,
                cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03), inst->flags );
            inst->flags |= CV_LKFLOW_PYR_A_READY;
            for( i = k = 0; i < inst->count; i++ )
            {
				#if 0
                if( inst->add_remove_pt )
                {
                    double dx = inst->pt.x - inst->points[1][i].x;
                    double dy = inst->pt.y - inst->points[1][i].y;

                    if( dx*dx + dy*dy <= 25 )
                    {
                        inst->add_remove_pt = 0;
                        continue;
                    }
                }
				#endif
                
                if( !inst->status[i] )
                    continue;
                
                inst->points[1][k++] = inst->points[1][i];
                cvCircle( inst->image, cvPointFrom32f(inst->points[1][i]), inst->circ_size, CV_RGB(255,255,255), -1, 8,0);
            }
            inst->count = k;
        }

        #if 0
		if( inst->add_remove_pt && inst->count < MAX_COUNT )
        {
            inst->points[1][inst->count++] = cvPointTo32f(inst->pt);
            cvFindCornerSubPix( inst->grey, inst->points[1] + inst->count - 1, 1,
                cvSize(WIN_SIZE,WIN_SIZE), cvSize(-1,-1),
                cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03));
            inst->add_remove_pt = 0;
        }
		#endif

        CV_SWAP( inst->prev_grey, inst->grey, inst->swap_temp );
        CV_SWAP( inst->prev_pyramid, inst->pyramid, inst->swap_temp );
        CV_SWAP( inst->points[0], inst->points[1], inst->swap_points );
        //cvShowImage( "LkDemo", inst->image );


    cvCopy( inst->image, inst->frame_copy, 0 );

    
    return;
}
