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

//#define VECS2
#define MAKETREE

double perlinNoise(float x, int period);
double perlinNoise(float x);

	double noise(int x)
    {
		//return (rand()%1000)/5e2- 1.0;
		x = (x<<13) ^ x;
	    return ( 1.0 - ( (x * (x * x * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);
	}
	/// from http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
	double perlinNoise(float x, int period)
	{
	
		/// find the lower and higher frequency points
		int nlx = period * (int)(x/period);
		int nhx = period + nlx;

	
		float fx = (x-nlx)/(float)(nhx-nlx);
		if (nhx-nlx == 0) fx = 0;
		/// cosine interpolation
		float fxt = cos(fx*M_PI);
		fx = (1.0-fxt)*0.5;

        double a = noise(nlx);
        double b = noise(nhx);
        
		return fx*(b-a)+a;
	}


    /// return a 0-1 float or a -.5 to .5 float?
    double perlinNoise(float x)
    {
       return (      perlinNoise(x,128) +  
                 0.5*perlinNoise(x,64) +
                 0.2*perlinNoise(x,32)  +
                0.06*perlinNoise(x,16)  );
    }


namespace {
float randomf(float min = -0.5f, float max = 0.5f)
{
    float src = (rand()%1000000)/1e6;

    return src*(max-min)+min;
}

std::vector<bone*> allBones;

bone* makeRandomBone(const int numChildren, const osg::Vec3 pos, const float size)
{
    bone* newBone = new bone;
   
    /// this should be handled elsewhere
    allBones.push_back(newBone);

    float actual_size =size; // pos.length(); 
    //osg::Vec3 pos = osg::Vec3(0.0,1.0,1.0)*15.0f;
    newBone->pos->setPosition(pos);
    newBone->springLine.end = pos;

    if (1) {
        /// TBD I think this may be the source of the problems with non-Y
        /// axis rotations- but what can I do?  Messing around with most of these
        /// just flips the rotation 180 degrees.
        /// is it possible that my method just doesn't work with the kind of attitude
        /// transformation below?  Instead of this, manipulate the vertex data instead?
        
        /// lookAt
        osg::Vec3 out = pos;
        out.normalize();

        osg::Vec3 up = osg::Vec3(0,1,0);
        osg::Vec3 right = out^up;
        right.normalize();

        up = right^out;
        up.normalize(); 

        osg::Matrixd temp;
        temp.makeLookAt(osg::Vec3(0,0,0),pos,up);
        temp.invert(temp);
        osg::Quat attitude;
        attitude.set(temp);
        
        //newBone->objpos->setAttitude(attitude);
         
        //newBone->objposNoAtt->setAttitude(attitude);
        
        /// handle this manually with vertices instead
        //newBone->objpos->setPosition(pos*0.5f);
        //newBone->objposNoAtt->setPosition(pos*0.5f);
        

       
        /// setScale doesn't work well with the bone position
        /// mixing.
        //newBone->objpos->setScale(osg::Vec3(pos.length()/12.0,pos.length()/12.0,pos.length()/2.2)); 
        //newBone->objpos->setScale(osg::Vec3(pos.length()/4.0,pos.length()/4.0,pos.length()/2.0)); 
        osg::Vec3 scale = osg::Vec3(pos.length()/6.0,pos.length()/6.0,pos.length()/2.0); 
	    for (unsigned i = 0; i < newBone->origVecs->getNumElements(); i++) {
            osg::Vec3 temp = (*(newBone->origVecs))[i];
            temp = osg::Vec3(temp.x()*scale.x(), temp.y()*scale.y(), temp.z()*scale.z());
           
            
            temp = temp - osg::Vec3(0,0,pos.length()/2.0);
            /// this is looking like it works
            temp = attitude*temp;
            
            (*(newBone->origVecs))[i] = temp;
        }
    
    }


    #ifdef MAKETREE
    for (int i = 0; i< numChildren; i++) {
        //osg::Vec3 pos = osg::Vec3(size/10.0+random(),random(),random() )*size;
        float angle_offset = M_PI*randomf();
        float angle = ((float)i/(float)numChildren)*2.0*M_PI + angle_offset;
        osg::Vec3 pos = osg::Vec3(cos(angle)*size,sin(angle)*size, 3.0f*size );
        bone* childBone = makeRandomBone(numChildren-1, pos, actual_size*0.7);
    #else
    for (int i = 0; ((i < 1) && (i < numChildren)); i++) {
        osg::Vec3 pos = osg::Vec3(1.0,0,0 )*15.0f;
        bone* childBone = makeRandomBone(numChildren-1,pos, size*0.9);
    #endif
        childBone->parent = newBone;
        newBone->children.push_back(childBone);
        newBone->pos->addChild(childBone->root);
    }

    return newBone;
}


void screenCapture(osgProducer::Viewer* viewer, const std::string filename)
{
    typedef std::list< osg::ref_ptr<osgGA::GUIEventHandler> > EventHandlerList;

    //std::cout << "looking for viewer->EventHandler " << std::endl;
    for (EventHandlerList::iterator itr = viewer->getEventHandlerList().begin();
            itr != viewer->getEventHandlerList().end();
            ++itr) {

        osgProducer::ViewerEventHandler* viewerEventHandler = 
            dynamic_cast<osgProducer::ViewerEventHandler*>(itr->get());

        if (viewerEventHandler) {
            //std::cout << "viewerEventHandler " << std::endl;

            Producer::CameraConfig* cfg = viewerEventHandler->getOsgCameraGroup()->getCameraConfig();

            //for( unsigned int i = 0; i < cfg->getNumberOfCameras(); ++i ) {
            /// TBD is number of cameras ever 0?
            Producer::Camera *cam = cfg->getCamera(0);

            int x,y;
            unsigned int width, height;
            cam->getProjectionRectangle(x,y,width,height);
            osg::ref_ptr<osg::Image> image = new osg::Image;
            image->readPixels(x,y,width,height, GL_RGB, GL_UNSIGNED_BYTE);
            osgDB::writeImageFile(*image, filename.c_str());
            
            //}
        }
    }
}

	osg::Group* scene; 
/// gravitational constant 
/// m^3/(kg s^2) = N m^2/kg^2
const double G = 6.6742e-11;

double gravity(const double m1,const double m2,	const double r)
{
	return G*m1*m2/pow(r,2);
}

osg::Vec3 gravity(const double m1,const double m2,	const osg::Vec3 r)
{
	return r/r.length() * gravity(m1,m2,r.length());
}



osg::Vec3 getIntersection(osg::Node* object, osg::Vec3 startPoint, osg::Vec3d testPoint )
{
	osg::Vec3 rv = osg::Vec3(0,0,0); 
	{
		osgUtil::IntersectVisitor iv;
		osg::ref_ptr<osg::LineSegment> segDown = new osg::LineSegment;

		segDown->set(startPoint,testPoint);
		iv.addLineSegment(segDown.get());

		object->accept(iv);

		if (iv.hits())
		{
			osgUtil::IntersectVisitor::HitList& hitList = iv.getHitList(segDown.get());
			
			if (!hitList.empty())
			{
				rv = hitList.front().getWorldIntersectPoint();
			}
		}
	}

	return rv;
}


osg::Node* createLights(osg::StateSet* rootStateSet, osg::Vec4 pos, osg::Vec4 diffuse, int lightNum)
{
	osg::Group* lightGroup = new osg::Group;

	// create a local light.
	osg::Light* sunLight = new osg::Light;
	sunLight->setLightNum(lightNum);
	sunLight->setPosition(pos);
	sunLight->setAmbient(osg::Vec4(0.001f,0.001f,0.002f,1.0f));
	sunLight->setDiffuse(diffuse);
	sunLight->setConstantAttenuation(1.0f);
	sunLight->setLinearAttenuation(0.0f);
	sunLight->setQuadraticAttenuation(0.0f);

	osg::LightSource* lightS2 = new osg::LightSource;	
	lightS2->setLight(sunLight);
	lightS2->setLocalStateSetModes(osg::StateAttribute::ON); 

	lightS2->setStateSetModes(*rootStateSet,osg::StateAttribute::ON);

	//mt->addChild(lightS2);

	lightGroup->addChild(lightS2);

	return lightGroup;
}

}  // end namespace

void updateBones(float preIncr)
{

    for (unsigned j = 0; j < allBones.size(); j++) {
                 
            allBones[j]->update(preIncr + j*1000.0);
     }
}

int main( int argc, char **argv )
{

    // use an ArgumentParser object to manage the program arguments.
    osg::ArgumentParser arguments(&argc,argv);
    
    // set up the usage document, in case we need to print out how to use this program.
    arguments.getApplicationUsage()->setApplicationName(arguments.getApplicationName());
    arguments.getApplicationUsage()->setDescription(arguments.getApplicationName()+" is the standard OpenSceneGraph example which loads and visualises 3d models.");
    arguments.getApplicationUsage()->setCommandLineUsage(arguments.getApplicationName()+" [options] filename ...");
    arguments.getApplicationUsage()->addCommandLineOption("--image <filename>","Load an image and render it on a quad");
    arguments.getApplicationUsage()->addCommandLineOption("--dem <filename>","Load an image/DEM and render it on a HeightField");
    arguments.getApplicationUsage()->addCommandLineOption("-h or --help","Display command line paramters");
    arguments.getApplicationUsage()->addCommandLineOption("--help-env","Display environmental variables available");
    arguments.getApplicationUsage()->addCommandLineOption("--help-keys","Display keyboard & mouse bindings available");
    arguments.getApplicationUsage()->addCommandLineOption("--help-all","Display all command line, env vars and keyboard & mouse bindigs.");
    
    
    int numLimbs = 3; 
    while (arguments.read("--limbs", numLimbs)) {}
    
    // construct the viewer.
    osgProducer::Viewer viewer(arguments);

    // set up the value with sensible default event handlers.
    viewer.setUpViewer(osgProducer::Viewer::STANDARD_SETTINGS);

#if 0
    unsigned int pos = viewer.addCameraManipulator(new GliderManipulator());
	viewer.selectCameraManipulator(pos);
#endif

	// get details on keyboard and mouse bindings used by the viewer.
	viewer.getUsage(*arguments.getApplicationUsage());

	// if user request help write it out to cout.
	bool helpAll = arguments.read("--help-all");
	unsigned int helpType = ((helpAll || arguments.read("-h") || arguments.read("--help"))? osg::ApplicationUsage::COMMAND_LINE_OPTION : 0 ) |
		((helpAll ||  arguments.read("--help-env"))? osg::ApplicationUsage::ENVIRONMENTAL_VARIABLE : 0 ) |
		((helpAll ||  arguments.read("--help-keys"))? osg::ApplicationUsage::KEYBOARD_MOUSE_BINDING : 0 );
	if (helpType)
	{
		arguments.getApplicationUsage()->write(std::cout, helpType);
		return 1;
	}

	// report any errors if they have occured when parsing the program aguments.
	if (arguments.errors())
	{
		arguments.writeErrorMessages(std::cout);
		return 1;
	}



	osg::Timer_t start_tick = osg::Timer::instance()->tick();



	// any option left unread are converted into errors to write out later.
	arguments.reportRemainingOptionsAsUnrecognized();

	// report any errors if they have occured when parsing the program aguments.
	if (arguments.errors())
	{
		arguments.writeErrorMessages(std::cout);
	}

	osg::Timer_t end_tick = osg::Timer::instance()->tick();

	std::cout << "Time to load = "<<osg::Timer::instance()->delta_s(start_tick,end_tick)<<std::endl;

	// optimize the scene graph, remove rendundent nodes and state etc.
	osgUtil::Optimizer optimizer;

	/// set background color to black
	viewer.setClearColor(osg::Vec4(0.95,0.95,0.95,1.0) );

	scene = new osg::Group;

	osg::StateSet* rootStateSet = new osg::StateSet;
	scene->setStateSet(rootStateSet);

	srand((unsigned)time(0));

    // pass the loaded scene graph to the viewer.
    viewer.setSceneData(scene);

    bone* rootBone = makeRandomBone(numLimbs,osg::Vec3(0.0,10.0,0.0),15.0f);
    std::cout << "allBones.size() " << allBones.size() << std::endl;
   
    /// duplicate the bones thing all over
    for (unsigned i = 0; i < 25; i++) {
        osg::PositionAttitudeTransform* randPlace = new osg::PositionAttitudeTransform;
        /// just having random positions looks pretty cool
        randPlace->setPosition(osg::Vec3(randomf(),randomf(),randomf() )*200.0f );

        osg::Quat quat = osg::Quat(
                        randomf(0,M_PI), osg::Vec3(1,0,0),
                        randomf(0,M_PI), osg::Vec3(0,1,0),
                        randomf(0,M_PI), osg::Vec3(0,0,1)
                            );
        randPlace->setAttitude(quat);

        randPlace->addChild(rootBone->root);
        scene->addChild(randPlace);

    }

    #ifdef VECS2
    for (unsigned i = 0; i < allBones.size(); i++) {
        scene->addChild(allBones[i]->objposScene);
    }
    #endif


    if (1) {
        osg::StateSet* ss = scene->getOrCreateStateSet();
        osg::Program* BlockyProgram = new osg::Program;
        BlockyProgram->setName( "blocky" );
        osg::Shader* BlockyVertObj = new osg::Shader( osg::Shader::VERTEX );
        osg::Shader* BlockyFragObj = new osg::Shader( osg::Shader::FRAGMENT );
        BlockyProgram->addShader( BlockyFragObj );
        BlockyProgram->addShader( BlockyVertObj );
        ss->setAttributeAndModes(BlockyProgram, osg::StateAttribute::ON);

        BlockyVertObj->loadShaderSourceFromFile("shaders/blocky.vert");
        BlockyFragObj->loadShaderSourceFromFile("shaders/blocky.frag");
   
    //for unsigned i = 0
   //viewer.getSceneHandlerList()[0]->getSceneView()->setActiveUniforms(osgUtil::SceneView::VIEW_MATRIX_INVERSE_UNIFORM); 
    }


    // create the windows and run the threads.
    viewer.realize();

	int i = 0;

    float preIncr = 0.0;

    while( !viewer.done())
    {
        // wait for all cull and draw threads to complete.
        viewer.sync();

        // update the scene by traversing it with the the update visitor which will
        // call all node update callbacks and animations.
        viewer.update();
         
        // fire off the cull and draw traversals of the scene.
        viewer.frame();
   
   		usleep(500);

        preIncr += 0.005;
        updateBones(preIncr);
        
        


		if (1) {
			std::stringstream imageName;
			imageName << "images/image_" << i << ".jpg";
			screenCapture(&viewer, imageName.str());
			i++;
		}
	}
    
    // wait for all cull and draw threads to complete before exit.
    viewer.sync();

    // run a clean up frame to delete all OpenGL objects.
    viewer.cleanup_frame();

    // wait for all the clean up frame to complete.
    viewer.sync();

    return 0;
}

