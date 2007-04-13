/*
 * Copyright (C) 2006 binarymillenium
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Mir is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <ctime>
#include <sstream>

#include <osgDB/ReadFile>
#include <osgUtil/Optimizer>
#include <osgProducer/Viewer>
#include <osg/CoordinateSystemNode>
#include <osg/PositionAttitudeTransform>
#include <osgDB/WriteFile>

#include <osgProducer/Viewer>
#include <osgProducer/ViewerEventHandler>
#include <osgUtil/SmoothingVisitor>
#include <osg/Geode>


#include "GliderManipulator.hpp"
#include "line.hpp"
#include "bone.hpp"

bone::bone()
{ 
    root = new osg::PositionAttitudeTransform;
    att = new osg::PositionAttitudeTransform;
    pos = new osg::PositionAttitudeTransform;

    objpos = new osg::PositionAttitudeTransform;
    objposNoAtt = new osg::PositionAttitudeTransform;
    
    #ifdef VECS2
    objposScene = new osg::PositionAttitudeTransform;
    #endif


    rotX = 0;
    rotY = 0;
    rotZ = 0;

    rotXvel = 0;
    rotYvel = 0;
    rotZvel = 0;

   // osg::Node*
   // / I think these two files need to be the same
    object = (osgDB::readNodeFile("cyl3.obj"));
    objposNoAtt->addChild(object);
    
    #ifdef VECS2
    object2 = (osgDB::readNodeFile("cyl2.obj"));
    objposScene->addChild(object2);
    #endif


    att->addChild(objpos);
    att->addChild(pos);
    
    root->addChild(att);
    root->addChild(objposNoAtt);

    parent = NULL;

	osg::Group* group = dynamic_cast<osg::Group*>(object);
	osg::Geode* geode = dynamic_cast<osg::Geode*>(group->getChild(0));
	 
	if(!geode) {
		osg::notify(osg::WARN) << "failed to load mesh " << std::endl;
		return;
	}

    osg::Geometry* mesh = dynamic_cast<osg::Geometry*>(geode->getDrawable(0));

    if(!mesh) {
        osg::notify(osg::WARN) << mesh << ": mesh " << 
            " was expected to contain a single drawable" << std::endl;
        return;
    }

    vecs     = dynamic_cast<osg::Vec3Array*>( mesh->getVertexArray() );
    origVecs = new osg::Vec3Array(*vecs, osg::CopyOp::DEEP_COPY_ALL);

    osg::BoundingBox bnd;
    bnd = mesh->getBound();

    for (unsigned i = 0; i < vecs->getNumElements(); i++) {
	
       float zMin = bnd.zMin();
       float zMax = bnd.zMax();

        float weight = 1.0-( zMax - (*vecs)[i].z() )/(zMax-zMin);
        //std::cout << weight << std::endl;
        //if (weight > 0.5) { weight = 2.0*(weight-0.5); } else {weight = 0;} 
        
        //float min = 0.3;
        //if (weight > min) { weight = (1.0/(1.0-min))*(weight-min); } else {weight = 0;} 
        //weight *= 0.001;
        //weight =1;

        parentWeights.push_back( weight*weight );
    }

    /// useful but causing mem dumps
    if (0) {
        springLine.start = osg::Vec3(0,0,0);
        //springLine.end   = ->getPosition();

        springLine.color2 = osg::Vec3(1.0,0.1,0.12);

        drawableGeode = new osg::Geode();
        drawableGeode->addDrawable(&springLine);

        att->addChild(drawableGeode);
    }
}


void bone::update(float preIncr)
{
    
    {
        float incr = preIncr;

        float reduceVel = 1.0;
        //rotY -= 0.001; 

        float inc_scale = 1.0;
        float post_scale = 6e4;
        rotXvel += 2.0*M_PI * (perlinNoise(inc_scale*incr) - 0.5)/post_scale;
        //rotX += rotXvel;

        rotYvel += 2.0*M_PI * (perlinNoise(inc_scale*incr+1e5) - 0.5)/post_scale;
        rotY += rotYvel;

        rotZvel += 2.0*M_PI * (perlinNoise(inc_scale*incr +2e5) - 0.5)/post_scale;
        rotZ += rotZvel;

        /// joint limits could be per bone, and somewhat random
        float limit = M_PI*0.25;
        if (rotX >= limit) { rotX = limit - M_PI/100.0; rotXvel = -rotXvel*reduceVel; }
        if (rotX <= 0)      {rotX = 0 + M_PI/100.0;     rotXvel = -rotXvel*reduceVel; }

        limit = M_PI*0.9;
        if (rotY >= limit) { rotY =  limit - M_PI/100.0; rotYvel = -rotYvel*reduceVel; }
        if (rotY <= -limit) {rotY = -limit + M_PI/100.0; rotYvel = -rotYvel*reduceVel; }

        if (rotZ >= limit) { rotZ =  limit - M_PI/100.0; rotZvel = -rotZvel*reduceVel; }
        if (rotZ <= -limit) {rotZ = -limit + M_PI/100.0; rotZvel = -rotZvel*reduceVel; }

        rotXvel *= 0.999;
        rotYvel *= 0.999;
        rotZvel *= 0.999;
        osg::Quat quat = osg::Quat(
                rotX, osg::Vec3(1,0,0),
                rotY, osg::Vec3(0,1,0),
                rotZ, osg::Vec3(0,0,1) 
                );
        att->setAttitude(quat);
    } 
    
    if (parent == NULL) return;

	osg::Group* group = dynamic_cast<osg::Group*>(object);
	osg::Geode* geode = dynamic_cast<osg::Geode*>(group->getChild(0));

#ifdef VECS2
    osg::Vec3Array* vecs2 = new osg::Vec3Array(*vecs, osg::CopyOp::DEEP_COPY_ALL);
#endif

    bool doBones = true;
    if (doBones) {
        //osg::Matrixd rot(att->getAttitude() );
        //osg::Matrixd rot2(objpos->getAttitude() );

        //osg::Matrixd rot1 = objpos->getWorldMatrices()[0];
        //osg::Vec3 cenDiff = rot2.preMult(osg::Vec3(0,0,0)) - rot1.preMult(osg::Vec3(0,0,0)); 
        #ifdef VECS2
        osg::Matrixd rot2 = objposNoAtt->getWorldMatrices()[0];
        #endif

        /// do the position mixing
        for (unsigned i = 0; i < vecs->getNumElements() &&
                parentWeights.size() ; i++) {
            osg::Vec3 pos =  (*origVecs)[i];
           
            //osg::Vec3d parentPos = rot.preMult( (*origVecs)[i] );
            //parentPos = rot2.preMult( parentPos );
            //osg::Vec3d newPos = parentPos*parentWeights[i] + (*origVecs)[i]*(1.0-parentWeights[i]);
            //(*vecs)[i] = newPos;
            //osg::Vec3d diff = rot2.preMult(pos) - rot1.preMult(pos);
            //(*vecs)[i] = pos;// + diff; //*parentWeights[i];

            /// for some reason the rotations are mismatched for X & Z but not Y
            /// is there some rotation between att and root that doesn't matter for Y?
            /// it's the rotation put on by objpos
            osg::Quat slerped;

            slerped.slerp(parentWeights[i], att->getAttitude(), root->getAttitude()); 

            osg::Vec3 slerpedPos = (slerped)*pos;
            (*vecs)[i] = slerpedPos; 

            //(*vecs)[i] = pos; 
           
            #ifdef VECS2
            /// this is basically it, but there's a discontinuity 
            /// problem with the rotation passing through PI/2
            ///
            (*vecs2)[i] = rot2.preMult(slerpedPos);
            //(*vecs2)[i] = rot2.preMult(slerpedPos);
            #endif 
        }

    }


    {
        osg::Group* group = dynamic_cast<osg::Group*>(object);
        osg::Geode* geode = dynamic_cast<osg::Geode*>(group->getChild(0));

        if(!geode) {
            osg::notify(osg::WARN) << "failed to load mesh " << std::endl;
            return;
        }

        osg::Geometry* mesh = dynamic_cast<osg::Geometry*>(geode->getDrawable(0));

        if(!mesh) {
            osg::notify(osg::WARN) << mesh << ": mesh " << 
                " was expected to contain a single drawable" << std::endl;
            return;
        }


        mesh->setVertexArray(vecs);

        osgUtil::SmoothingVisitor sv;
        sv.smooth(*mesh);
    }

    /// temp to do same for object2
    #ifdef VECS2
    {
        osg::Group* group = dynamic_cast<osg::Group*>(object2);
        osg::Geode* geode = dynamic_cast<osg::Geode*>(group->getChild(0));

        if(!geode) {
            osg::notify(osg::WARN) << "failed to load mesh " << std::endl;
            return;
        }

        osg::Geometry* mesh = dynamic_cast<osg::Geometry*>(geode->getDrawable(0));
        
        if(!mesh) {
            osg::notify(osg::WARN) << mesh << ": mesh " << 
                " was expected to contain a single drawable" << std::endl;
            return;
        }

        mesh->setVertexArray(vecs2);

        osgUtil::SmoothingVisitor sv;
        sv.smooth(*mesh);
    }
    #endif

}


