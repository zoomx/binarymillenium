#include "line.hpp"

void line::drawImplementation(osg::State& ) const
{
	 {
	glPushAttrib(GL_ENABLE_BIT);

	glDisable(GL_LIGHTING);

	/// TBD make width a parameter
	glLineWidth(2.0f);
	glBegin(GL_LINE_STRIP);

	    glColor3f(color[0],color[1],color[2]);
	    glVertex3d( start[0],start[1],start[2]);

	    if (color2 != osg::Vec3d()) glColor3f(color2[0],color2[1],color2[2]);
    	glVertex3d( end[0],end[1],end[2]);

	glEnd();

	glPopAttrib();

	}
}



