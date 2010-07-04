/*************************************************************************
 *                                                                       *
 * Open Dynamics Engine, Copyright (C) 2001,2002 Russell L. Smith.       *
 * All rights reserved.  Email: russ@q12.org   Web: www.q12.org          *
 *                                                                       *
 * This library is free software; you can redistribute it and/or         *
 * modify it under the terms of EITHER:                                  *
 *   (1) The GNU Lesser General Public License as published by the Free  *
 *       Software Foundation; either version 2.1 of the License, or (at  *
 *       your option) any later version. The text of the GNU Lesser      *
 *       General Public License is included with this library in the     *
 *       file LICENSE.TXT.                                               *
 *   (2) The BSD-style license that is included with this library in     *
 *       the file LICENSE-BSD.TXT.                                       *
 *                                                                       *
 * This library is distributed in the hope that it will be useful,       *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the files    *
 * LICENSE.TXT and LICENSE-BSD.TXT for more details.                     *
 *                                                                       *
 *************************************************************************/

/* exercise the C interface */

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <vector>

#include "ode/ode.h"
#include "drawstuff/drawstuff.h"
#include "texturepath.h"

#include "utility.h"

#ifdef _MSC_VER
#pragma warning(disable:4244 4305)  // for VC++, no precision loss complaints
#endif

/* select correct drawing functions */

#ifdef dDOUBLE
#define dsDrawBox dsDrawBoxD
#define dsDrawSphere dsDrawSphereD
#define dsDrawCylinder dsDrawCylinderD
#define dsDrawCapsule dsDrawCapsuleD
#endif


/* some constants */

#define NUM 10			/* number of boxes */
#define SIDE (0.2)		/* side length of a box */
#define MASS (1.0)		/* mass of a box */
#define RADIUS (0.1732f)	/* sphere radius */


/* dynamics and collision objects */

static dWorldID world;
static dSpaceID space;
static dJointGroupID contactgroup;

/* this is called by dSpaceCollide when two objects in space are
 * potentially colliding.
 */

static void nearCallback (void *data, dGeomID o1, dGeomID o2)
{
  /* exit without doing anything if the two bodies are connected by a joint */
  dBodyID b1,b2;
  dContact contact;

  b1 = dGeomGetBody(o1);
  b2 = dGeomGetBody(o2);
  if (b1 && b2 && dAreConnected (b1,b2)) return;

  contact.surface.mode = 0;
  contact.surface.mu = 0.1;
  contact.surface.mu2 = 0;
  if (dCollide (o1,o2,1,&contact.geom,sizeof(dContactGeom))) {
    dJointID c = dJointCreateContact (world,contactgroup,&contact);
    dJointAttach (c,b1,b2);
  }
}


/* start simulation - set viewpoint */

static void start()
{
  static float xyz[3] = {2.1640f,-1.3079f,1.7600f};
  static float hpr[3] = {125.5000f,-17.0000f,0.0000f};

  dAllocateODEDataForThread(dAllocateMaskAll);
  dsSetViewpoint (xyz,hpr);
}

struct odePart {
  int id;
  dGeomID geom;
  dBodyID body;
  float len[3];
};

std::vector<odePart> allParts;
/* simulation loop */

static void simLoop (int pause)
{
  int i;
  if (!pause) {
    static double angle = 0;
    angle += 0.05;
    //dBodyAddForce (body[NUM-1],0,0,1.5*(sin(angle)+1.0));

    dSpaceCollide (space,0,&nearCallback);
    dWorldStep (world,0.05);

    /* remove all contact joints */
    dJointGroupEmpty (contactgroup);
  }

  dsSetColor (1,1,0);
  dsSetTexture (DS_WOOD);
  for (i=0; i< allParts.size(); i++) {
    dsDrawBox (dBodyGetPosition(allParts[i].body), dBodyGetRotation(allParts[i].body),allParts[i].len);
  }
}

static void command(int cmd)
{
  static int curBody = 0;
  float forceVal = 10;
  
  switch(cmd) {
    case '1':
      curBody -= 1;
      curBody %= allParts.size();
      std::cout << "body " << curBody << " selected" << std::endl;
      break;

    case '2':
      curBody += 1;
      curBody %= allParts.size();
      std::cout << "body " << curBody << " selected" << std::endl;
      break;
    
    case 'w':
      dBodyAddForce(allParts[curBody].body, 0,0,forceVal);
      break;

    case 'a':
      dBodyAddForce(allParts[curBody].body, -forceVal,0,0);
      break;
    case 'd':
      dBodyAddForce(allParts[curBody].body, -forceVal,0,0);
      break;
  }
}

int main (int argc, char **argv)
{
  int i;
  dReal k;
  dMass m;

  /* setup pointers to drawstuff callback functions */
  dsFunctions fn;
  fn.version = DS_VERSION;
  fn.start = &start;
  fn.step = &simLoop;
  fn.command = &command;
  fn.stop = 0;
  fn.path_to_textures = DRAWSTUFF_TEXTURE_PATH;

  string filename = "spec.txt";
  if (argc > 1) filename = argv[1]; 

  std::ifstream parts(filename.c_str());
  if (!parts) {
    std::cerr << "file " << filename << " not found " << std::endl;
    return -1;
  }

  /* create world */
  dInitODE2(0);
  world = dWorldCreate();
  space = dHashSpaceCreate (0);
  contactgroup = dJointGroupCreate (1000000);
  dWorldSetGravity (world,0,0,-0.5);
  dCreatePlane (space,0,0,1,0);


  std::string lines;
  while (getline(parts,lines)) {
      vector<string> tokens = tokenize(tokenize(tokenize(tokenize(lines,"\t"),"\n"),"\r")," ");

      #if 0
      for (int i = 0; i < tokens.size(); i++) {
        std::cout << i << ":" << tokens[i] << " ";
      }
      std::cout << std::endl;
      #endif

      if ((tokens.size() >0)
              && (tokens[0].size() >0)
              && (tokens[0][0] != '#')
              ) {

      if (tokens[0].compare("body") == 0) {
        if (tokens.size() == 9) {
          odePart newPart;       
          newPart.id = atoi(tokens[1].c_str());
          newPart.body = dBodyCreate(world);
          float posx = atof(tokens[2].c_str());
          float posy = atof(tokens[3].c_str());
          float posz = atof(tokens[4].c_str());
          newPart.len[0] = atof(tokens[5].c_str());
          newPart.len[1] = atof(tokens[6].c_str());
          newPart.len[2] = atof(tokens[7].c_str());
          dBodySetPosition(newPart.body, posx,posy,posz);
          dMassSetBox(&m, 1,  newPart.len[0], newPart.len[1], newPart.len[2]);
          dMassAdjust(&m, atof(tokens[8].c_str()));
          newPart.geom = dCreateBox(space, newPart.len[0], newPart.len[1], newPart.len[2]);
          dGeomSetBody(newPart.geom, newPart.body);
          allParts.push_back(newPart);
          std::cout << "new part " << newPart.id << " " << posx << " " << posy << " " << posz << std::endl;
        } else {
          std::cerr << "wrong number of tokens" << std::endl;
        }
      } // body
      else if (tokens[0].compare("joint") == 0) {
          /// ball joint
        int bodyId1 = atoi(tokens[1].c_str());
        int bodyId2 = atoi(tokens[2].c_str());
        std::cout << "attaching ball joint between " << bodyId1 << " and " << bodyId2 << std::endl;
        dJointID newJoint = dJointCreateBall(world,0);
        dBodyID body1 = allParts[allParts[bodyId1].id].body;
        dBodyID body2 = allParts[allParts[bodyId2].id].body;
        dJointAttach(newJoint, body1, body2 );
        dJointSetBallAnchor(newJoint, atof(tokens[3].c_str()), atof(tokens[4].c_str()), atof(tokens[5].c_str()) );
      } else if (tokens[0].compare("uni") == 0) {
        /// universal joint
        int bodyId1 = atoi(tokens[1].c_str());
        int bodyId2 = atoi(tokens[2].c_str());
        std::cout << "attaching universal joint between " << bodyId1 << " and " << bodyId2 << std::endl;
        dJointID newJoint = dJointCreateUniversal(world,0);
        dBodyID body1 = allParts[allParts[bodyId1].id].body;
        dBodyID body2 = allParts[allParts[bodyId2].id].body;
        dJointAttach(newJoint, body1, body2 );

        float anchx = atof(tokens[3].c_str());
        float anchy = atof(tokens[4].c_str());
        float anchz = atof(tokens[5].c_str());
        dJointSetUniversalAnchor(newJoint, anchx, anchy, anchz);          

        float axisx = atof(tokens[6].c_str());
        float axisy = atof(tokens[7].c_str());
        float axisz = atof(tokens[8].c_str());
        dJointSetUniversalAxis1(newJoint, axisx, axisy,axisz);

        axisx = atof(tokens[9].c_str());
        axisy = atof(tokens[10].c_str());
        axisz = atof(tokens[11].c_str());
        dJointSetUniversalAxis2(newJoint, axisx, axisy,axisz);

        float lostop = atof(tokens[12].c_str());
        dJointSetUniversalParam(newJoint, dParamLoStop, lostop);
        float histop = atof(tokens[13].c_str());
        dJointSetUniversalParam(newJoint, dParamHiStop, histop);

        /// TBD not supported yet?
        lostop = atof(tokens[14].c_str());
        dJointSetUniversalParam(newJoint, dParamLoStop2, lostop);
        histop = atof(tokens[15].c_str());
        dJointSetUniversalParam(newJoint, dParamLoStop2, lostop);

      } else if (tokens[0].compare("hinge") == 0) {
        /// hinge joint
        int bodyId1 = atoi(tokens[1].c_str());
        int bodyId2 = atoi(tokens[2].c_str());
        std::cout << "attaching hinge joint between " << bodyId1 << " and " << bodyId2 << std::endl;
        dJointID newJoint = dJointCreateHinge(world,0);
        dBodyID body1 = allParts[allParts[bodyId1].id].body;
        dBodyID body2 = allParts[allParts[bodyId2].id].body;
        dJointAttach(newJoint, body1, body2 );

        float anchx = atof(tokens[3].c_str());
        float anchy = atof(tokens[4].c_str());
        float anchz = atof(tokens[5].c_str());
        dJointSetHingeAnchor(newJoint, anchx, anchy, anchz);          

        float axisx = atof(tokens[6].c_str());
        float axisy = atof(tokens[7].c_str());
        float axisz = atof(tokens[8].c_str());
        dJointSetHingeAxis(newJoint, axisx, axisy, axisz);          
        
        float lostop = atof(tokens[9].c_str());
        dJointSetHingeParam(newJoint, dParamLoStop, lostop);
        float histop = atof(tokens[10].c_str());
        dJointSetHingeParam(newJoint, dParamHiStop, histop);

      } else {
        std::cout << "not using line: " << lines << std::endl;
      }
    } else { // tokens
      std::cout << "comment or invalid line: " << lines << std::endl;

    }
  } // getline

  /* run simulation */
  dsSimulationLoop (argc,argv,352,288,&fn);

  dJointGroupDestroy (contactgroup);
  dSpaceDestroy (space);
  dWorldDestroy (world);
  dCloseODE();
  return 0;
}
