#ifndef PHEX_IMAGE_HPP
#define PHEX_IMAGE_HPP

#include <vector>

#include "cv.h"

#include "phexModule.hpp"

class phexImage;

class phexImage : public phexModule 
{
	public:
		std::vector<IplImage*> images;	

		// rotation map matrix
		CvMat* map;

		IplConvKernel* kern;

		phexImage(float x, float y, float imWidth=320, float imHeight=240, float w=50.0, float h=50.0);

		~phexImage();

		virtual void draw(IplImage* output, CvFont* font, bool isSelected = false);
		virtual bool update();
		virtual void changeValue(int index, float offset);

	private:
		
};

#endif //PHEX_IMAGE_HPP
