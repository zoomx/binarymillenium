/**
 * GNU GPL
 *
 *
 *
 * binarymillenium May 2009
 */

#include <stdio.h>

#include "cv.h"
#include "highgui.h"
#include <math.h>

int levels = 3;
CvSeq* contours = 0;

CvMemStorage* storage;
IplImage* img_gray = NULL;
IplImage* img_src = NULL;
IplImage* img = NULL;

int thresh = 128;

void on_trackbar(int pos)
{
    IplImage* cnt_img = cvCreateImage( cvSize(img->width,img->height), 8, 3 );
    CvSeq* _contours = contours;
    
	cvZero( cnt_img );
    //cvDrawContours( cnt_img, _contours, CV_RGB(255,0,0), CV_RGB(0,255,0), _levels, 1, CV_AA, cvPoint(0,0) );
    cvDrawContours( cnt_img, _contours, CV_RGB(255,0,0), CV_RGB(0,255,0), levels);
    cvShowImage( "contours", cnt_img );
    cvReleaseImage( &cnt_img );
}


void on_trackbar_thresh(int thresh)
{
	cvCvtColor(img_src, img_gray, CV_BGR2GRAY);
	cvThreshold(img_gray, img, thresh, 255, CV_THRESH_BINARY);

    cvShowImage( "image", img );

    cvFindContours( img, storage, &contours, sizeof(CvContour),CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);//, cvPoint(0,0) );

	on_trackbar(levels);
}

void interp(CvPoint last_point, CvPoint cur_point, float blank_counts, int onoff)
{
	/// always draw the first and last points
	if (blank_counts < 1.01) blank_counts = 1.01;
	for (float f = 0.0; f < 1.0; f+= 1.0/blank_counts) {
			float x1 = last_point.x/(float)img_src->width;
			float x2 =  cur_point.x/(float)img_src->width;
			float y1 = last_point.y/(float)img_src->height;
			float y2 =  cur_point.y/(float)img_src->height;

			
			/// the first column is x, then y, then whether to turn off the lasers
			printf("%g, %g, %d, %d, %d\n", (x2-x1)*f+x1, (y2-y1)*f + y1, onoff,onoff,onoff);
		}
}

int main( int argc, char** argv )
{
    storage = cvCreateMemStorage(0);
    //IplImage* img_src_pre = cvLoadImage("test1.jpg", CV_LOAD_IMAGE_COLOR );
	img_src = cvLoadImage("test2.png", CV_LOAD_IMAGE_COLOR );
	cvSmooth(img_src,img_src,CV_GAUSSIAN,3);
	//img_src = cvCreateImage(cvSize(img_src_pre->width/2, img_src_pre->height/2), 8,3);
    //cvResize(img_src_pre,img_src, CV_INTER_LINEAR);
	img_gray = cvCreateImage(cvSize(img_src->width, img_src->height), 8,1);
	img = cvCreateImage(cvSize(img_src->width, img_src->height), 8,1);
	//cvAdaptiveThreshold(img_gray, img, 255, CV_ADAPTIVE_THRESH_MEAN_C,CV_THRESH_BINARY, 7, 0);

    cvNamedWindow( "image", 1 );
	on_trackbar_thresh(thresh);

	// TBD are there are bunch of sequences strung together?
	// think so, need to use h_next and find all of them
	
	
	CvSeq* cur_cont = contours;
	CvPoint last_point;
	CvPoint cur_point;
	last_point.x = 0;
	last_point.y = 0;
	while (cur_cont != NULL) {

		int count = cur_cont->total;
		if (count > 20) {		
		CvPoint* points = (CvPoint*)malloc(count*sizeof(CvPoint));
		cvCvtSeqToArray(cur_cont, points, CV_WHOLE_SEQ);

		// need to generate a transition between the last point and current
		// point
		cur_point.x = points[0].x;
		cur_point.y = points[0].y;
		/// TBD what's the minimum time we can turn off the lasers?
		float blank_counts = 500.0;
		interp(last_point,cur_point,blank_counts, 0);	

		for (int i = 0; i < count -1; i++) {
			float disp_counts = blank_counts/count;
			interp(points[i],points[i+1],disp_counts, 1);	

		}

		last_point.x = points[count-1].x;
		last_point.y = points[count-1].y;
		}
		cur_cont = cur_cont->h_next;
	}

    // comment this out if you do not want approximation
    //contours = cvApproxPoly( contours, sizeof(CvContour), storage, CV_POLY_APPROX_DP, 3, 1 );

    cvNamedWindow( "contours", 1 );
    cvCreateTrackbar( "levels+3", "contours", &levels, 100, on_trackbar );
	cvCreateTrackbar( "threshold", "contours", &thresh, 255, on_trackbar_thresh );
    
    on_trackbar(0);
    cvWaitKey(0);
    cvReleaseMemStorage( &storage );
    cvReleaseImage( &img );

    return 0;
}

#ifdef _EiC
main(1,"");
#endif
