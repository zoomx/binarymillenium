#include "cv.h"

#include "phexImage.hpp"

phexImage::phexImage(float x, float y, float imWidth, float imHeight, float w, float h) :
		   phexModule(x, y, imWidth, imHeight, w, h)
{
}

phexImage::~phexImage()
{
}

bool phexImage::update()
{
	if (phexModule::update()) {

	}

}

void phexImage::draw(IplImage* output, bool isSelected)
{
	phexModule::draw(output, isSelected);

	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	/// write some text here, what the number is 
	cvResetImageROI(output);

}



