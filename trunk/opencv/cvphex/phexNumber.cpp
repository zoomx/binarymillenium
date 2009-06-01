#include "cv.h"

#include "phexNumber.hpp"

phexNumber::phexNumber(float x, float y, float imWidth, float imHeight, float w, float h) :
		   phexModule(x, y, imWidth, imHeight, w, h)
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

void phexNumber::draw(IplImage* output, bool isSelected)
{
	phexModule::draw(output, isSelected);

	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	/// write some text here, what the number is 
	cvResetImageROI(output);

}



