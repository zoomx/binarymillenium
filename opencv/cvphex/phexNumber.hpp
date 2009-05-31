#ifndef MODULE_HPP
#define MODULE_HPP

#include <vector>

#include "cv.h"

#include "phexModule.hpp"

class phexNumber;

class phexNumber : public phexModule 
{

	public:

		///
		//outport
		std::vector<float> values;	

		phexNumber(float x, float y, float imWidth=320, float imHeight=240, float w=50.0, float h=50.0);

		~phexNumber();

		virtual void draw(IplImage* output,bool isSelected = false);
		virtual bool update();

	private:
};

#endif //MODULE_HPP
