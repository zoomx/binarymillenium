#ifndef LINE_HPP
#define LINE_HPP

#include <osg/Drawable>
#include <osg/Vec3d>

class line : public osg::Drawable
{
	public:
		line()
		{
			setSupportsDisplayList(false);
			color = osg::Vec3d(0.26f,0.21f,0.66f);
		}

		line(const line& theMoveTarget,
				const osg::CopyOp& copyop=osg::CopyOp::SHALLOW_COPY):
			osg::Drawable(theMoveTarget,copyop) {}

		/// define all the standard clonetype pure virtuals
		META_Object(theMoveTarget,line)

		/// universe coordinates
		osg::Vec3d start;
		osg::Vec3d end;

		osg::Vec3d color;
		osg::Vec3d color2;

		virtual void drawImplementation(osg::State&) const;
    
            // we need to set up the bounding box of the data too, so that the scene graph knows where this
                    // objects is, for both positioning the camera at start up, and most importantly for culling.
                            virtual osg::BoundingBox computeBound() const
                                    {
                                                osg::BoundingBox bbox;
                  bbox.expandBy(start);
                  bbox.expandBy(end);

                  return bbox;
           }
};


#endif // LINE_HPP

