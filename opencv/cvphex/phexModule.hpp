#ifndef PHEX_MODULE_HPP
#define PHEX_MODULE_HPP

#include <vector>

#include "cv.h"

//class phexModule;

class phexModule 
{

	public:
		/// list of input objects
		//inport
		std::vector<phexModule*> inputImages;
		std::vector<phexModule*> inputNumbers;

		bool dirty;

		CvRect pos;

		phexModule(float x, float y, float imWidth=320, float imHeight=240, float w=50.0, float h=50.0);

		~phexModule();

		virtual bool update();
		virtual void draw(IplImage* output,bool isSelected = false);

		virtual void changeValue(int index, float offset) {}

	protected:
		
		bool changed;
};

#endif // PHEX_MODULE_HPP
