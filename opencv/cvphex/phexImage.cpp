#include <iostream>

#include "cv.h"

#include "phexImage.hpp"

phexImage::phexImage(float x, float y, float imWidth, float imHeight, float w, float h) :
			phexModule(x, y, imWidth, imHeight, w, h)
{

	kern = cvCreateStructuringElementEx( 3, 3, 1, 1, CV_SHAPE_RECT, NULL );

	{
		map = cvCreateMat(2,3,CV_32FC1);
		cvmSet(map,0,0, 1.0);
		cvmSet(map,0,1, 0.0);
		cvmSet(map,0,2, imWidth/2);
		cvmSet(map,1,0, 0.0);
		cvmSet(map,1,1, 1.0);
		cvmSet(map,1,2, imHeight/2);
	}

	for (unsigned i = 0; i < 2; i++) {
		images.push_back(cvCreateImage(cvSize(imWidth,imHeight),8,3));
	}

	typeMax = 2;
}

phexImage::~phexImage()
{
	for (unsigned i = 0; i < images.size(); i++) {
		cvReleaseImage(&images[i]);	
	}
}

void phexImage::changeValue(int index, float offset)
{
	int i = int(index/3);
	int j = index%3;
	if ((i < 2) && (j <3)) {
		cvmSet(map,i,j, cvmGet(map,i,j) + offset);
		changed = true;
	//	std::cout << "changed " << offset << std::endl;
	}
}

bool phexImage::update()
{
	//if (changed) std::cout << "update " << std::endl;
	if (phexModule::update()) {

		if (type == 0) {
			if (inputImages.size() < 1) { return false; }
			phexImage* in1 = dynamic_cast<phexImage*>(inputImages[0]);
			if (in1 == NULL) { return false; }
			if (in1->images.size() < 1) { return false; }

			cvGetQuadrangleSubPix(in1->images[0], images[0], map);
		} else if (type == 1) {
			/// TBD do something else here if some of these fail, like
			/// add image to itself
			if (inputImages.size() < 2) { return false; }
			phexImage* in1 = dynamic_cast<phexImage*>(inputImages[0]);
			phexImage* in2 = dynamic_cast<phexImage*>(inputImages[1]);
			if (in1 == NULL) { return false; }
			if (in2 == NULL) { return false; }
			if (in1->images.size() < 1) { return false; }
			if (in2->images.size() < 1) { return false; }
		
			cvAddWeighted(in1->images[0], cvmGet(map,0,0), 
						  in2->images[0], cvmGet(map,0,1), 
						  cvmGet(map,0,2), images[0] );
			//		cvMorphologyEx(inputModules[0]->images[0], images[0], images[1] ,
			//					   kern,CV_MOP_OPEN, 1 );
		}
	}
}

void phexImage::draw(IplImage* output, bool isSelected)
{

	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	cvResize(images[0], output);
	cvResetImageROI(output);

	/// draw lines that connect modules
	int numConnected = inputImages.size();
	for (unsigned i = 0; i< numConnected; i++) {
		phexImage* connectedModule = dynamic_cast<phexImage*>(inputImages[i]);
		if (connectedModule) {
			cvLine(output, cvPoint(pos.x,pos.y+ (float)i/(float)numConnected),
						   cvPoint(connectedModule->pos.x+ connectedModule->pos.width,
						   		   connectedModule->pos.y+ connectedModule->pos.height/2), cvScalar(100,0,255),2);
		}
	}

	phexModule::draw(output,isSelected);
}

