#ifndef MODULE_HPP
#define MODULE_HPP

#include <vector>

#include "cv.h"

class module;

class module 
{

	public:
		/// list of input objects
		//inport
		std::vector<module*> inputModules;

		///
		//outport
		std::vector<IplImage*> images;	
		bool dirty;

		CvRect pos;
	
		IplConvKernel* kern;

		module(float x, float y, float imWidth=320, float imHeight=240, float w=10.0, float h=10.0);

		~module();

		void update();

		void draw(IplImage* output);


	private:

};

#endif //MODULE_HPP
