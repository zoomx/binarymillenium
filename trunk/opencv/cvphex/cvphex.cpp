/**
 * GNU GPL
 * binarymillenium June 2009
 */


//#include <math.h>

#include <vector>
#include <iostream>
#include <sstream>

#include "cv.h"
#include "highgui.h"

int width  = 320;
int height = 240;

bool running = true;
float add_alpha = 0.5;
float add_beta = 0.5;
float add_gamma = 0.0;


IplImage* resize(IplImage* in, int width, int height)
{
	IplImage* out = cvCreateImage(cvSize(width,height), 8, 3 );
	cvResize(in,out);
	cvReleaseImage(&in);
	return out;
}
/*
void on_mouse( int event, int x, int y, int flags, void* param ) {
	if (event == 
}
*/

int main() {

	std::vector<IplImage*> images;
	
	IplImage* in1 = (cvLoadImage("images/test.jpg", CV_LOAD_IMAGE_COLOR));
	IplImage* in2 = (cvLoadImage("images/circle.png", CV_LOAD_IMAGE_COLOR));
	
	images.push_back( resize(in1,width,height) );
	images.push_back( resize(in2,width,height) );
	// temp
	images.push_back(cvCreateImage(cvSize(width,height),8,3)); 
	/// the output
	images.push_back(cvCreateImage(cvSize(width,height),8,3)); 
	//images.push_back(cvCreateImage(cvSize(width,height),8,3)); 

	float scale = 0.2;
	IplImage* gui = cvCreateImage(cvSize(images.size()*width*scale, height), 8,3);

	CvFont font;
	{
	double hScale=0.4;
	double vScale=0.4;
	int    lineWidth=1;
	cvInitFont(&font,CV_FONT_HERSHEY_SIMPLEX, hScale,vScale,0,lineWidth);
	}

	IplConvKernel* kern = cvCreateStructuringElementEx( 3, 3, 1, 1,CV_SHAPE_RECT, NULL );

	cvNamedWindow("output",1);
	cvNamedWindow("gui",1);

	int last_key = 0;

	const int NUM_TYPES = 2;
	unsigned int type = 0;

	while (running) {

		if (type == 0) {
			cvAddWeighted(images[0], add_alpha, images[1], 
							add_beta, add_gamma, images[images.size()-1] );
		} else if (type == 1) {
			cvMorphologyEx(images[0], images[images.size()-1], images[1], 
							kern,CV_MOP_OPEN, int(fabs(add_alpha*10)) );
		}


		cvShowImage("output",images[images.size()-1]);
	
		{
			cvRectangle(gui, cvPoint(0,0), cvPoint(gui->width, gui->height), cvScalar(0,0,0),CV_FILLED);
		/// gui output
		for (unsigned i = 0; i< images.size(); i++) {
			CvRect roi;
			roi.width = width*scale;
			roi.height= height*scale;
			roi.x = i*roi.width;
			roi.y = 0;
			cvSetImageROI(gui,roi);
			/// TBD use nearest neighbor later for speed
			cvResize(images[i],gui);
			cvResetImageROI(gui);
		}
		std::ostringstream txt;
		txt << "add_beta =" << add_beta << ", add_alpha =" << add_alpha;	
		cvPutText (gui,txt.str().c_str(),cvPoint(0,height*scale+10), &font, cvScalar(255,255,200));
		cvShowImage("gui",gui);
		}

		/// simultaneous keypresses aren't handled, only the last press and holds
		/// probably should use SDL for io
		/// but keyboards aren't ideal for a lot of simultaneous io anyway
		int key = cvWaitKey(5);
		if (key >= 0) {
			if (key == 'u') {
				add_beta += 0.02;
			} else if (key == 'i') {
				add_beta -= 0.0199;
			} else if (key == 'j') {
				add_alpha += 0.02;
			} else if (key == 'k') {
				add_alpha -= 0.0199;
			}
		
			/// one time ops
			if (key != last_key) {
				if (key == 'd') {
					type = (type-1)%NUM_TYPES;
				} else if (key == 'f') {
					type = (type+1)%NUM_TYPES;
				}
			}
			//std::cout << add_beta << " " << add_alpha << std::endl;
		}
		last_key = key;
	}

}


