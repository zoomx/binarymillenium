#include "cv.h"

#include "phexNumber.hpp"

phexNumber::phexNumber(float x, float y, float w, float h) :
		   phexModule(x, y, w, h)
{
}

phexNumber::~phexNumber()
{
}

bool phexNumber::update()
{
	if (phexModule::update()) {

	}
}

void phexNumber::draw(IplImage* output,CvFont* font, bool isSelected)
{
	phexModule::draw(output, font, isSelected);

	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	/// write some text here, what the number is 
	cvResetImageROI(output);

}



