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
		/// where to begin with inputImages	
		int inputImOffset;

		std::vector<phexModule*> inputNumbers;

		bool dirty;

		CvRect pos;

		phexModule(float x, float y, float w=50.0, float h=50.0);

		~phexModule();

		virtual bool update();
		virtual void draw(IplImage* output,CvFont* font,  bool isSelected = false, bool isTarget = false);

		virtual void changeValue(int index, float offset) {}
	
		int type;
		int typeMax;
		
		

		virtual void changeType(int offset);
		virtual void changeImOffset(int offset);

	protected:
		
		bool changed;
};

#endif // PHEX_MODULE_HPP
