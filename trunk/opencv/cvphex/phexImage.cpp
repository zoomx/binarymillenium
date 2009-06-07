#include <iostream>
#include <sstream>

#include "cv.h"

#include "phexImage.hpp"

phexImage::phexImage(float x, float y, float imWidth, float imHeight, float w, float h) :
			phexModule(x, y, w, h)
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

	typeMax = 3;
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

		unsigned lenIm = inputImages.size();
		if (lenIm < 1) { return false; }
		phexImage* in1 = dynamic_cast<phexImage*>(inputImages[inputImOffset%lenIm]);
		if (in1->images.size() < 1) { return false; }
		if (in1 == NULL) { return false; }

		if (type == 0) {
			cvGetQuadrangleSubPix(in1->images[0], images[0], map);
		} else if (type == 1) {
			/// if there is only one input, it will add to itself
			phexImage* in2 = dynamic_cast<phexImage*>(inputImages[(inputImOffset+1)%lenIm]);
			if (in2 == NULL) { return false; }
			if (in2->images.size() < 1) { return false; }
		
			cvAddWeighted(in1->images[0], cvmGet(map,0,0), 
						  in2->images[0], cvmGet(map,0,1), 
						  cvmGet(map,0,2), images[0] );
		} else if (type == 2) {
			if (images.size() == 1) images.push_back(cvCreateImage(cvSize(images[0]->width,images[0]->height),8,3));

			cvMorphologyEx(in1->images[0], images[0], images[1], kern,CV_MOP_OPEN, 1 );
		}
	}
}

void phexImage::draw(IplImage* output, CvFont* font, bool isSelected)
{

	/// TBD, have this be done only intermittently, or when cpu load is low
	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	/// compare to CV_INTER_AREA
	cvResize(images[0], output, CV_INTER_NN);
	cvResetImageROI(output);
	
	std::ostringstream txt;
	txt << "" << type << "," << inputImOffset;	
	cvPutText (output,txt.str().c_str(),cvPoint(pos.x,pos.y-10), font, cvScalar(55,255,100));




	phexModule::draw(output,font,isSelected);
}

