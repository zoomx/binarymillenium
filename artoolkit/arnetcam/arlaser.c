/**
 * binarymillenium 2008-2009
 *
 *
 * Licensed under the latest version of the GNU GPL
 *
 *
 */

#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netinet/in.h>
#include <errno.h>
#include <time.h>

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
//#include <math.h>

#include <curl/curl.h>

struct send_marker_info {
    int id;
    float area;
    float cf;
    float x;
    float y;
    float rot;
};

void findMarkers(ARUint8* dataPtr, int sock, struct sockaddr_in* host ); 
ARUint8* loadImage(char* filename, int *xsize, int *ysize);
int             xsize, ysize;

   ARParam         cparam;

size_t write_data(void *buffer, size_t size, size_t nmemb, void *file) { 
    return fwrite(buffer, size, nmemb, (FILE*) file);

}

int main(int argc, char **argv)
{
    ARUint8 *dataPtr;

    int sock;
    struct sockaddr_in host;
    unsigned int echolen, clientlen;
    int received = 0;

    if ((sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
        fprintf(stderr,"Failed to create socket\n");
        perror("socket");
        return -1;
    }

    /// the port where the modified net ctrl is sent to flightgear
    memset(&host, 0, sizeof(host));       /* Clear struct */
    host.sin_family = AF_INET;                  /* Internet/IP */
    host.sin_addr.s_addr = inet_addr("127.0.0.1");  /* IP address */
    host.sin_port = htons(5600);       /* server port */

    bind(sock, (struct sockaddr*)&host, sizeof(host));

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
   
    

    int one = 1;
    //glutInit(&one,argv);

    CURL *curl_handle;
    FILE *curl_file;
    curl_file = fopen("images/test.jpg","w");

    curl_handle = curl_easy_init();

    if (curl_handle == NULL) {
        fprintf(stderr, "curl_easy_init failed");
        exit(0);
    }
    //curl_easy_setopt(curl_handle, CURLOPT_URL, "http://binarymillenium.googlecode.com/svn/trunk/artoolkit/arnetcam/images/arboard1angle.jpg");
    curl_easy_setopt(curl_handle, CURLOPT_URL, "http://192.168.1.57/now.jpg");
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, write_data); 
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, curl_file); 

    CURLcode rv;

    rv = curl_easy_perform(curl_handle);
    printf("%d\n", rv);
    
    cur_filename = "images/test.jpg";

    if (argc > 2) {
        sprintf(path,"%s/", argv[2]);
    } else {
        sprintf(path, "");
    }

    fprintf(stderr,"%d %s,\n", argc, cur_filename);

    /// make this get an image with curl
	dataPtr	    = loadImage(cur_filename,&xsize,&ysize);

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
   fprintf(stderr,"patt.hiro %d\n", patt_id);

    sprintf(buffer,"%spatt.sample1",path);
    if( (patt_id=arLoadPatt(buffer)) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
        exit(0);
    }
   fprintf(stderr,"patt.sample1 %d\n", patt_id);

    sprintf(buffer,"%spatt.sample2",path);
    if( (patt_id=arLoadPatt(buffer)) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
        exit(0);
    }
   fprintf(stderr,"patt.sample2 %d\n", patt_id);


    sprintf(buffer,"%spatt.kanji",path);
    if( (patt_id=arLoadPatt(buffer)) < 0 ) {
        fprintf(stderr,"pattern load error !!\n");
        exit(0);
    }
   fprintf(stderr,"patt.kanji %d\n", patt_id);


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
	findMarkers(dataPtr,sock, &host);

    argCleanup();
}

void findMarkers(ARUint8* dataPtr, int sock, struct sockaddr_in* host) 
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

        double ox,oy;
        arParamIdeal2Observ(cparam.dist_factor ,  marker_info[k].pos[0], marker_info[k].pos[1], &ox, &oy);

        float rot = atan2(  marker_info[k].vertex[0][1] - marker_info[k].pos[1] , 
                            marker_info[k].vertex[0][0] - marker_info[k].pos[0] );

        //char buffer[100];

        struct send_marker_info to_send;
        
        to_send.id = marker_info[k].id;
        to_send.area = (float)marker_info[k].area/(float)(xsize*ysize);
        to_send.cf = marker_info[k].cf;
        to_send.x = ox/(float)xsize;
        to_send.y = oy/(float)ysize;
        to_send.rot = rot;
        
        int received = sendto(sock, (void*) &to_send, sizeof(to_send), 0,
                (struct sockaddr *) host, sizeof(*host));

        if (received <0) {
            perror("sendto");
        } 

        printf("%d, %d sent\n", to_send.id, received);


        /// print rotation matrix
        if (0) {
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
	}
}




