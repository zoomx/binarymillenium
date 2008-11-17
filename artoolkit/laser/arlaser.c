/**
 * binarymillenium 2008
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

//
// Camera configuration.
//
#ifdef _WIN32
char			*vconf = "Data\\WDM_camera_flipV.xml";
#else
char			*vconf = "";
#endif

int             xsize, ysize;
int             thresh = 100;
int             count = 0;

char           *cparam_name    = "../calib_camera2/newparam.dat";
ARParam         cparam;

char           *patt_name      = "patt.hiro";
int             patt_id;
double          patt_width     = 80.0;
double          patt_center[2] = {0.0, 0.0};
double          patt_trans[3][4];

static void   init(void);
static void   cleanup(void);
static void   keyEvent( unsigned char key, int x, int y);
static void   mainLoop(void);
static void   draw( void );

void findMarkers(void);
float dmnop(float* x, float* y, float* z, int m, int n, int o, int p);

static void   keyEvent( unsigned char key, int x, int y)
{
    /* quit if the ESC key is pressed */
    if( key == 0x1b ) {
        fprintf(stderr,"*** %f (frame/sec)\n", (double)count/arUtilTimer());
        cleanup();
        exit(0);
    }
}

char* cur_filename;
ARUint8 *dataPtr;

int singleLoop = 1;


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
	///


	return dptr;
}



int main(int argc, char **argv)
{
	int one = 1;
	glutInit(&one,argv);
	init();
	
	cur_filename = argv[1];

	fprintf(stderr,"%d %s,\n", argc, cur_filename);
	fprintf(stdout,"%s,\t",cur_filename);

	if (argc > 2) {
		fprintf(stderr,"showing graphics\n");
		singleLoop = 0;	
	}

	////

	dataPtr	    = loadImage(cur_filename);


	///
	ARParam  wparam;
	
    /* open the video path */
    //if( arVideoOpen( vconf ) < 0 ) exit(0);
    /* find the size of the window */
    //if( arVideoInqSize(&xsize, &ysize) < 0 ) exit(0);
    //fprintf(stderr,"Image size (x,y) = (%d,%d)\n", xsize, image->rows);

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
	///



    //arVideoCapStart();

	findMarkers();



	if (singleLoop) {
		//mainLoop();
	} else {
    	argMainLoop( NULL, NULL /*keyEvent*/, mainLoop );
	}
}

void findMarkers(void) 
{
    ARMarkerInfo    *marker_info;
    int             marker_num;
    int             j, k;
	/* grab a vide frame */
    //if( (dataPtr = (ARUint8 *)arVideoGetImage()) == NULL ) {
    
	//if( count == 0 ) arUtilTimerReset();
    //count++;

    argDrawMode2D();
    argDispImage( dataPtr, 0,0 );

    /* detect the markers in the video frame */
    if( arDetectMarker(dataPtr, thresh, &marker_info, &marker_num) < 0 ) {
        cleanup();
        exit(0);
    }


    /* check for object visibility */
    k = -1;
    for( j = 0; j < marker_num; j++ ) {
        if( patt_id == marker_info[j].id ) {
            if( k == -1 ) k = j;
            else if( marker_info[k].cf < marker_info[j].cf ) k = j;
        }
    }
  	
  if( k == -1 ) {
        argSwapBuffers();
		//fprintf(stderr,"no visible objects\n");
      
	  	#if 0
	   int i;
		for (i = 0; i < 4; i ++) {
			for (j = 0; j < 3; j++) {
				fprintf("0,\t");	
			}
			//fprintf("\n");
		}
		fprintf("\n");
		#endif
	   
	   //return;
	   int i;
		for (i = 0; i < 12; i++) {
				fprintf(stdout, "0,\t");	
		}
		fprintf(stdout,"\n");


	   //
    } else {
		//fprintf("patt_trans\n");

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

		//draw();
	}
}

/* main loop */
int maincount = 0;

static void mainLoop(void)
{
	//maincount++;
	//if (maincount > 2) exit(0);
	
    argDrawMode2D();
    argDispImage( dataPtr, 0,0 );


	draw();

    argSwapBuffers();

	sleep(1);

	return; // (0);
}

static void init( void )
{
    }

/* cleanup function called when program exits */
static void cleanup(void)
{
    arVideoCapStop();
    arVideoClose();
    argCleanup();
}

static void draw( void )
{
    double    gl_para[16];
    GLfloat   mat_ambient[]     = {0.0, 0.0, 1.0, 1.0};
    GLfloat   mat_flash[]       = {0.0, 0.0, 1.0, 1.0};
    GLfloat   mat_flash_shiny[] = {50.0};
    GLfloat   light_position[]  = {100.0,-200.0,200.0,0.0};
    GLfloat   ambi[]            = {0.1, 0.1, 0.1, 0.1};
    GLfloat   lightZeroColor[]  = {0.9, 0.9, 0.9, 0.1};
    
    argDrawMode3D();
    argDraw3dCamera( 0, 0 );
    glClearDepth( 1.0 );
    glClear(GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    
    /* load the camera transformation matrix */
    argConvGlpara(patt_trans, gl_para);
    glMatrixMode(GL_MODELVIEW);
    glLoadMatrixd( gl_para );

    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glLightfv(GL_LIGHT0, GL_POSITION, light_position);
    glLightfv(GL_LIGHT0, GL_AMBIENT, ambi);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightZeroColor);
    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_flash);
    glMaterialfv(GL_FRONT, GL_SHININESS, mat_flash_shiny);	
    glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);
    glMatrixMode(GL_MODELVIEW);
    glTranslatef( 0.0, 0.0, -25.0 );
    //glutSolidCube(60.0);
    glDisable( GL_LIGHTING );
	/// the position of the laser in the block is below the fiducial
	glTranslatef( 0.0, 0.0, 0.0 );
	glBegin(GL_LINES);
	glVertex3f(0.0,-100.0,0.0);
	glVertex3f(0.0,900.0,0.0);
	
	glEnd();

    glDisable( GL_DEPTH_TEST );
}
