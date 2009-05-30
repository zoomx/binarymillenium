/**
 * GNU GPL
 * binarymillenium June 2009
 */


//#include <math.h>

#include <vector>

#include "cv.h"
#include "highgui.h"

int width  = 320;
int height = 240;

IplImage* resize(IplImage* in, int width, int height)
{
	IplImage* out = cvCreateImage(cvSize(width,height), 8, 3 );
	cvResize(in,out);
	cvReleaseImage(&in);

	return out;
}

bool running = true;
float add_alpha = 0.5;
float add_beta = 0.5;
float add_gamma = 0.0;

int main() {

	std::vector<IplImage*> images;
	
	IplImage* in1 = (cvLoadImage("images/plus.png", CV_LOAD_IMAGE_COLOR));
	IplImage* in2 = (cvLoadImage("images/circle.png", CV_LOAD_IMAGE_COLOR));
	
	images.push_back( resize(in1,width,height) );
	images.push_back( resize(in2,width,height) );
	/// the output
	images.push_back(cvCreateImage(cvSize(width,height),8,3)); 
	//images.push_back(cvCreateImage(cvSize(width,height),8,3)); 

	cvNamedWindow("output",1);
	cvNamedWindow("gui",1);

	while (running) {
		cvAddWeighted(images[0], add_alpha, images[1], add_beta, add_gamma, images[2] );
		
		cvShowImage("output",images[images.size()-1]);
		cvWaitKey(5);
	}

}


