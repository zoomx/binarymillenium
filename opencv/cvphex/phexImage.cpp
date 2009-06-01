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
		cvmSet(map,0,2, 0.0);
		cvmSet(map,1,0, 0.0);
		cvmSet(map,1,1, 1.0);
		cvmSet(map,1,2, 0.0);
	}

	for (unsigned i = 0; i < 2; i++) {
		images.push_back(cvCreateImage(cvSize(imWidth,imHeight),8,3));
	}
}

phexImage::~phexImage()
{
	for (unsigned i = 0; i < images.size(); i++) {
		cvReleaseImage(&images[i]);	
	}
}

bool phexImage::update()
{
	if (phexModule::update()) {
		cvGetQuadrangleSubPix(dynamic_cast<phexImage*>(inputImages[0])->images[0], images[0], map);
		//		cvAddWeighted(images[0], add_alpha, images[1], 
		//						add_beta, add_gamma, images[images.size()-1] );

		//		cvMorphologyEx(inputModules[0]->images[0], images[0], images[1] ,
		//					   kern,CV_MOP_OPEN, 1 );

	}
}

void phexImage::draw(IplImage* output, bool isSelected)
{

	cvResetImageROI(output);
	cvSetImageROI(output,pos);
	cvResize(images[0], output);
	cvResetImageROI(output);
	
	phexModule::draw(output,isSelected);
}

