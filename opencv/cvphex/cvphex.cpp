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

#include "phexModule.hpp"
#include "phexNumber.hpp"
#include "phexImage.hpp"

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

	std::vector<phexModule*> phexModules;

	{
		phexImage* first = new phexImage(20,20,width,height);
		cvReleaseImage(&first->images[0]);
		IplImage* in1 = (cvLoadImage("images/test.jpg", CV_LOAD_IMAGE_COLOR));
		first->images[0] = resize(in1,width,height);
		first->dirty = true;
	
		phexModules.push_back(first);
	}

	/// add a few more image modules
	for (unsigned i = 1; i < 9; i++) {
		int x = 20 + 90*(i%3);
		int y = 20 + 90*int(i/3);
		phexImage* newIm = new phexImage(x,y,width,height);	
		//newIm->inputImages.push_back(dynamic_cast<phexImage*>(phexModules[i-1]));
		newIm->inputImages.push_back(phexModules[i-1]);
		phexModules.push_back(newIm);	
	}

	phexModules[4]->inputImages.push_back(phexModules[6]);
	phexModules[4]->changeType(1);

	/// now add some number modules

	unsigned phexModuleSelected = 0;

	while (running) {
		

		cvShowImage("output",dynamic_cast<phexImage*>(phexModules[8])->images[0]);

		{
			// blank background
			cvRectangle(gui, cvPoint(0,0), cvPoint(gui->width, gui->height), cvScalar(0,0,0),CV_FILLED);
			/// update
			for (unsigned i = 0; i < phexModules.size(); i++) {
				phexModules[i]->update();
			}
			/// gui output
			for (unsigned i = 0; i < phexModules.size(); i++) {
				phexModules[i]->draw(gui, &font, phexModuleSelected == i);
			}
			cvShowImage("gui",gui);
		}

		/// simultaneous keypresses aren't handled, only the last press and holds
		/// probably should use SDL for io
		/// but keyboards aren't ideal for a lot of simultaneous io anyway
		int key = cvWaitKey(33);
		// the last_key doesn't quite work like it seems it should, but does slow
		//  down event processing so it doesn't block drawing
		if ((key >= 0) && (last_key < 0)) {
			if (key == 'q') {
				running = false;
			} else if (key == '1') {
				phexModuleSelected = (phexModuleSelected - 1)%phexModules.size();
			} else if (key == '2') {
				phexModuleSelected = (phexModuleSelected + 1)%phexModules.size();
			
			} else if (key == '3') {
				phexModules[phexModuleSelected]->changeType(-1);
			} else if (key == '4') {
				phexModules[phexModuleSelected]->changeType(1);
			
			} else if (key == '5') {
				phexModules[phexModuleSelected]->changeImOffset(-1);
			} else if (key == '6') {
				phexModules[phexModuleSelected]->changeImOffset(1);
			
			} else if (key == 'u') {
				phexModules[phexModuleSelected]->changeValue(0, 0.1);
			} else if (key == 'i') {
				phexModules[phexModuleSelected]->changeValue(0,-0.1);
			} else if (key == 'j') {
				phexModules[phexModuleSelected]->changeValue(1, 0.1);
			} else if (key == 'k') {
				phexModules[phexModuleSelected]->changeValue(1,-0.1);
			} else if (key == 'n') {
				phexModules[phexModuleSelected]->changeValue(2, 10);
			} else if (key == 'm') {
				phexModules[phexModuleSelected]->changeValue(2,-10);
			}	
		
		/*		if (key == 'd') {
					type = (type-1)%NUM_TYPES;
				} else if (key == 'f') {
					type = (type+1)%NUM_TYPES;
				}
				*/
			usleep(10000);
		}
		last_key = key;
	}

}


