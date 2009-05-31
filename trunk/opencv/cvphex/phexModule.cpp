#include "cv.h"

#include "phexModule.hpp"

phexModule::phexModule(float x, float y, float imWidth, float imHeight, float w, float h)
{
	pos.x = x;
	pos.y =y;
	pos.width = w;
	pos.height = h;

	dirty = false;
}

phexModule::~phexModule()
{
}

bool phexModule::update()
{
	changed = false;

	/// TBD later keep a mask object that says which inputs are really being used
	/// might have inputs connected but ignore them
	for (unsigned i = 0; i< inputImages.size(); i++) {
		if (inputImages[i]->dirty) {
			changed = true;
			return changed;
		}
	}
	
	for (unsigned i = 0; i< inputNumbers.size(); i++) {
		if (inputNumbers[i]->dirty) {
			changed = true;
			return changed;
		}
	}

	return changed;
}

void phexModule::draw(IplImage* output, bool isSelected)
{
	dirty = changed;

	if (dirty)
		cvRectangle(output, cvPoint(pos.x,pos.y), 
			cvPoint(pos.x + pos.width, pos.y + pos.height), cvScalar(0,255,0),2);
		
	if (isSelected) {
		cvRectangle(output, cvPoint(pos.x,pos.y), 
			cvPoint(pos.x + pos.width-1, pos.y + pos.height-1), cvScalar(255,255,0),2);
	}
}



