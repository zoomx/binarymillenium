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
					   
		dirty = true;
	} else {
		dirty = false;
	}

}

void module::draw(IplImage* output)
{
	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	cvResize(images[0], output);
	cvResetImageROI(output);
}



