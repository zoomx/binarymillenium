#include "cv.h"

#include "module.hpp"

module::module(float x, float y, float imWidth, float imHeight, float w, float h)
{
	pos.x = x;
	pos.y =y;
	pos.width = w;
	pos.height = h;

	dirty = false;

	kern = cvCreateStructuringElementEx( 3, 3, 1, 1, CV_SHAPE_RECT, NULL );

	for (unsigned i = 0; i < 2; i++) {
		images.push_back(cvCreateImage(cvSize(imWidth,imHeight),8,3));
	}
}

module::~module()
{
	for (unsigned i = 0; i < images.size(); i++) {
		cvReleaseImage(&images[i]);	
	}
}

void module::update()
{
	if ((inputModules.size() >= 1) && (inputModules[0]->dirty)) {
		cvMorphologyEx(inputModules[0]->images[0], images[0], images[1] ,
					   kern,CV_MOP_OPEN, 1 );
		changed = true;
	} else {
		changed = false;
	}

}

void module::draw(IplImage* output, bool isSelected)
{
	dirty = changed;
	

	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	cvResize(images[0], output);
	cvResetImageROI(output);


	if (dirty)
		cvRectangle(output, cvPoint(pos.x,pos.y), 
			cvPoint(pos.x + pos.width, pos.y + pos.height), cvScalar(0,255,0),2);
		
	if (isSelected) {
		cvRectangle(output, cvPoint(pos.x,pos.y), 
			cvPoint(pos.x + pos.width-1, pos.y + pos.height-1), cvScalar(255,255,0),2);
	}
}



