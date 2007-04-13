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

//#define VECS2
#define MAKETREE


double perlinNoise(float x, int period);
double perlinNoise(float x);



class bone 
{
public:

    float rotX; 
    float rotY;
    float rotZ;

    float rotXvel; 
    float rotYvel;
    float rotZvel;



	osg::Vec3Array* vecs;

bone();
    
void update(float preIncr);
   
   osg::PositionAttitudeTransform* pos;
    /// position of object, should be halfway between origin of att and pos
    osg::PositionAttitudeTransform* objpos;
    osg::PositionAttitudeTransform* objposNoAtt;
  
    #ifdef VECS2
    osg::PositionAttitudeTransform* objposScene;
    osg::Node* object2;
    #endif
    
    osg::PositionAttitudeTransform* att;
    osg::PositionAttitudeTransform* root;


	osg::Vec3Array* origVecs;

    bone* parent;
    std::vector<bone*> children;

    osg::Node* object;

    std::vector<float> parentWeights;

	/// a line to show the spring
	line springLine;
	osg::Geode* drawableGeode;
	
};

