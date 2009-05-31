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

#include "module.hpp"

int width  = 320;
int height = 240;

bool running = true;
//float add_alpha = 0.5;
//float add_beta = 0.5;
//float add_gamma = 0.0;


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
	//IplImage* in2 = (cvLoadImage("images/circle.png", CV_LOAD_IMAGE_COLOR));

	float scale = 0.2;
	IplImage* gui = cvCreateImage(cvSize(width, height), 8,3);

	CvFont font;
	{
		double hScale=0.4;
		double vScale=0.4;
		int    lineWidth=1;
		cvInitFont(&font,CV_FONT_HERSHEY_SIMPLEX, hScale,vScale,0,lineWidth);
	}

	cvNamedWindow("output",1);
	cvNamedWindow("gui",1);

	int last_key = 0;

	const int NUM_TYPES = 2;
	unsigned int type = 0;

	std::vector<module*> modules;

	modules.push_back(new module(5,5));
	cvReleaseImage(&modules[0]->images[0]);
	modules[0]->images[0] =  resize(in1,width,height);
	modules[0]->dirty = true;

	for (unsigned i = 1; i < 4; i++) {
		modules.push_back(new module(i*60,5));	

		modules[i]->inputModules.push_back(modules[i-1]);
	}
	
	unsigned moduleSelected = 0;

	while (running) {

	//		cvAddWeighted(images[0], add_alpha, images[1], 
	//						add_beta, add_gamma, images[images.size()-1] );


		cvShowImage("output",modules[modules.size()-1]->images[0]);

		{
			// blank background
			cvRectangle(gui, cvPoint(0,0), cvPoint(gui->width, gui->height), cvScalar(0,0,0),CV_FILLED);
			/// update
			for (unsigned i = 0; i < modules.size(); i++) {
				modules[i]->update();
			}
			/// gui output
			for (unsigned i = 0; i < modules.size(); i++) {
				modules[i]->draw(gui, moduleSelected == i);
			}
			/*	std::ostringstream txt;
				txt << "add_beta =" << add_beta << ", add_alpha =" << add_alpha;	
				cvPutText (gui,txt.str().c_str(),cvPoint(0,height*scale+10), &font, cvScalar(255,255,200));
				*/
			cvShowImage("gui",gui);
		}

		/// simultaneous keypresses aren't handled, only the last press and holds
		/// probably should use SDL for io
		/// but keyboards aren't ideal for a lot of simultaneous io anyway
		int key = cvWaitKey(5);
		if (key >= 0) {
			if (key == 'q') {
				running = false;
			} else if (key == 'u') {
				moduleSelected = (moduleSelected + 1)%modules.size();
			} else if (key == 'i') {
				moduleSelected = (moduleSelected - 1)%modules.size();
			} /*else if (key == 'j') {
				add_alpha += 0.02;
			} else if (key == 'k') {
				add_alpha -= 0.0199;
			}
		*/
			/// one time ops
			if (key != last_key) {
		/*		if (key == 'd') {
					type = (type-1)%NUM_TYPES;
				} else if (key == 'f') {
					type = (type+1)%NUM_TYPES;
				}
				*/
			}
		}
		last_key = key;
	}

}


