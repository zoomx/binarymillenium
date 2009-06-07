#include <iostream>

#include "cv.h"

#include "phexModule.hpp"

phexModule::phexModule(float x, float y, float w, float h)
{
	if ((x < 0) || (y<0) || (w < 1) || (h <1)) {
		std::cerr << "phexModule bad roi  " << x << " " << y << " " << w << " " << h << std::endl;
		return;
	}
	pos.x = x;
	pos.y =y;
	pos.width = w;
	pos.height = h;
	
	inputImOffset = 0;

	typeMax = 1;
	type = 0;

	dirty = false;
}

phexModule::~phexModule()
{
}

bool phexModule::update()
{
	if (changed) {
//		std::cout << "changed 0 " << std::endl;
		return changed;
	}

	/// TBD later keep a mask object that says which inputs are really being used
	/// might have inputs connected but ignore them
	for (unsigned i = 0; i < inputImages.size(); i++) {
		if (inputImages[i]->dirty) {
//		std::cout << "changed 1 " << std::endl;
			changed = true;
			return changed;
		}
	}
	
	for (unsigned i = 0; i < inputNumbers.size(); i++) {
		if (inputNumbers[i]->dirty) {
//		std::cout << "changed 2 " << std::endl;
			changed = true;
			return changed;
		}
	}

	return changed;
}

void phexModule::draw(IplImage* output, CvFont* font, bool isSelected, bool isTarget)
{
	dirty = changed;
	changed = false;


	/// draw lines that connect modules
	int numConnected = inputImages.size();
	for (unsigned i = 0; i< numConnected; i++) {
		float frct = pos.height/(float)(numConnected+1);
		
		phexModule* connectedModule = inputImages[i];

		CvScalar col = cvScalar(70,0,255);
		if (i == inputImOffset)
			col = cvScalar(150,0,205);

		if (connectedModule) {
			cvLine(output, cvPoint(pos.x, pos.y + frct*(i+1)),
						   cvPoint(connectedModule->pos.x + connectedModule->pos.width,
						   		   connectedModule->pos.y + connectedModule->pos.height/2), 
							col,2);
		}
	}



	if (dirty) {
		cvRectangle(output, cvPoint(pos.x+1,pos.y+1), 
			cvPoint(pos.x + pos.width-1, pos.y + pos.height-1), cvScalar(0,255,0),2);
	}	

	if (isSelected) {
		cvRectangle(output, cvPoint(pos.x,pos.y), 
			cvPoint(pos.x + pos.width-1, pos.y + pos.height-1), cvScalar(255,255,0),2);
	}
	if (isTarget) {
		cvLine(output, cvPoint(pos.x, pos.y), cvPoint(pos.x-2, pos.y + pos.height/2), cvScalar(255,50,110),2);
	}
}

void phexModule::changeType(int offset)
{
	type = (typeMax+type+offset)%typeMax;		
}

void phexModule::changeImOffset(int offset)
{
	int max = inputImages.size();
	if (max < 2) return;
	inputImOffset = (max+inputImOffset+offset)%max;		
}

