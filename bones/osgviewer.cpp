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

namespace {


double perlinNoise(float x, int period);
double perlinNoise(float x);


float randomf(float min = -0.5f, float max = 0.5f)
{
    float src = (rand()%1000000)/1e6;

    return src*(max-min)+min;
}


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

bone()
{ 
    root = new osg::PositionAttitudeTransform;
    att = new osg::PositionAttitudeTransform;
    pos = new osg::PositionAttitudeTransform;

    objpos = new osg::PositionAttitudeTransform;
    objposNoAtt = new osg::PositionAttitudeTransform;
    
    #if 0
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
    object = (osgDB::readNodeFile("cyl1.obj"));
    objposNoAtt->addChild(object);
    
    #if 0
    object2 = (osgDB::readNodeFile("cyl1.obj"));
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


void update(float preIncr)
{
    float incr = preIncr;

    float reduceVel = 0.8;
    //rotY -= 0.001; 
    //rotXvel += 2.0*M_PI * (perlinNoise(50*incr) - 0.5)/2e5;
    //rotX += rotXvel;

    rotYvel += 2.0*M_PI * (perlinNoise(50*incr+1e5) - 0.5)/2e5;
    //rotYvel *= 0.99;
    rotY += rotYvel;
  
    //rotZvel += 2.0*M_PI * (perlinNoise(50*incr +2e5) - 0.5)/2e5;
    //rotZ += rotZvel;

    /// joint limits could be per bone, and somewhat random
    const float limit = M_PI*0.9;
    if (rotY >= limit) { rotY =  limit - M_PI/100.0; rotYvel = -rotYvel*reduceVel; }
    if (rotY <= -limit) {rotY = -limit + M_PI/100.0; rotYvel = -rotYvel*reduceVel; }
   
    if (rotX >= limit) { rotX =  limit - M_PI/100.0; rotXvel = -rotYvel*reduceVel; }
    if (rotX <= -limit) {rotX = -limit + M_PI/100.0; rotXvel = -rotYvel*reduceVel; }
   
    if (rotZ >= limit) { rotZ =  limit - M_PI/100.0; rotXvel = -rotYvel*reduceVel; }
    if (rotZ <= -limit) {rotZ = -limit + M_PI/100.0; rotXvel = -rotYvel*reduceVel; }
    
    osg::Quat quat = osg::Quat(
            rotX, osg::Vec3(1,0,0),
            rotY, osg::Vec3(0,1,0),
            rotZ, osg::Vec3(0,0,1) );
    att->setAttitude(quat);
    

    if (parent == NULL) return;

	osg::Group* group = dynamic_cast<osg::Group*>(object);
	osg::Geode* geode = dynamic_cast<osg::Geode*>(group->getChild(0));

#if 0
    osg::Vec3Array* vecs2 = new osg::Vec3Array(*vecs, osg::CopyOp::DEEP_COPY_ALL);
#endif
    bool doBones = true;
    if (doBones) {
        //osg::Matrixd rot(att->getAttitude() );
        //osg::Matrixd rot2(objpos->getAttitude() );

        #if 0
        osg::Matrixd rot1 = objpos->getWorldMatrices()[0];
        osg::Matrixd rot2 = objposNoAtt->getWorldMatrices()[0];

        osg::Vec3 cenDiff = rot2.preMult(osg::Vec3(0,0,0)) - rot1.preMult(osg::Vec3(0,0,0)); 
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
            osg::Quat slerped;
            slerped.slerp(parentWeights[i], att->getAttitude(), root->getAttitude()); 

            osg::Vec3 slerpedPos = slerped*pos;
            (*vecs)[i] = slerpedPos; 
           // (*vecs)[i] = pos; 
           
           #if 0
            /// this is basically it, but there's a discontinuity 
            /// problem with the rotation passing through PI/2
            ///
            (*vecs2)[i] = rot2.preMult(slerpedPos);
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
    #if 0
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




///////////////////////////////////////////////////////////////////

    osg::PositionAttitudeTransform* pos;
    /// position of object, should be halfway between origin of att and pos
    osg::PositionAttitudeTransform* objpos;
    osg::PositionAttitudeTransform* objposNoAtt;
  #if 0
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

std::vector<bone*> allBones;


bone* makeRandomBone(int numChildren)
{
    bone* newBone = new bone;
   
    /// this should be handled elsewhere
    allBones.push_back(newBone);

    //osg::Vec3 pos = osg::Vec3(0.7+random(),random(),random() )*15.0f;
    osg::Vec3 pos = osg::Vec3(1.0,0,0 )*15.0f;
    //osg::Vec3 pos = osg::Vec3(0.0,1.0,1.0)*15.0f;
    newBone->pos->setPosition(pos);
    newBone->springLine.end = pos;

    if (1) {
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
        
        newBone->objpos->setAttitude(attitude);
        //newBone->objpos->setPosition(pos*0.5f);
         
        newBone->objposNoAtt->setAttitude(attitude);
        //newBone->objposNoAtt->setPosition(pos*0.5f);
        

       
        /// setScale doesn't work well with the bone position
        /// mixing.
        //newBone->objpos->setScale(osg::Vec3(pos.length()/12.0,pos.length()/12.0,pos.length()/2.2)); 
        //newBone->objpos->setScale(osg::Vec3(pos.length()/4.0,pos.length()/4.0,pos.length()/2.0)); 
        osg::Vec3 scale = osg::Vec3(pos.length()/6.0,pos.length()/6.0,pos.length()/2.0); 
     
	    for (unsigned i = 0; i < newBone->origVecs->getNumElements(); i++) {
            osg::Vec3 temp = (*(newBone->origVecs))[i];
            temp = osg::Vec3(temp.x()*scale.x(), temp.y()*scale.y(), temp.z()*scale.z());
            
            (*(newBone->origVecs))[i] = temp - osg::Vec3(0,0,pos.length()/2.0);
        }
    
    }


    //for (int i = 0; i< numChildren; i++) {
    //    bone* childBone = makeRandomBone(rand()%numChildren);
    for (int i = 0; ((i < 1) && (i < numChildren)); i++) {
        bone* childBone = makeRandomBone(numChildren-1);
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
	viewer.setClearColor(osg::Vec4(0.0,0.0,0.0,1.0) );

	scene = new osg::Group;

	osg::StateSet* rootStateSet = new osg::StateSet;
	scene->setStateSet(rootStateSet);

	srand((unsigned)time(0));

    // pass the loaded scene graph to the viewer.
    viewer.setSceneData(scene);

    bone* rootBone = makeRandomBone(numLimbs);
    std::cout << "allBones.size() " << allBones.size() << std::endl;
   
    /// duplicate the bones thing all over
    for (unsigned i = 0; i < 1; i++) {
        osg::PositionAttitudeTransform* randPlace = new osg::PositionAttitudeTransform;
        randPlace->setPosition(osg::Vec3(randomf(),randomf(),0.0 )*50.0f );
        randPlace->addChild(rootBone->root);
        scene->addChild(randPlace);

    }

    #if 0
    for (unsigned i = 0; i < allBones.size(); i++) {
        scene->addChild(allBones[i]->objposScene);
    }
    #endif

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
        
        


		if (0) {
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

