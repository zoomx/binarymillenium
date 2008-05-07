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
#include "ode/ode.h"
#include "drawstuff/drawstuff.h"

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

#define NUM 7			/* number of boxes */
#define SIDE (0.3)		/* side length of a box */
#define MASS (1.0)		/* mass of a box */
#define RADIUS (0.1732f)	/* sphere radius */


/* dynamics and collision objects */

static dWorldID world;
static dSpaceID space;
static dBodyID body[NUM];
static dJointID joint[NUM-1];
static dJointGroupID contactgroup;
static dGeomID sphere[NUM];


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
  dsSetViewpoint (xyz,hpr);
}

static int fallen = 0;

/* simulation loop */

static void simLoop (int pause)
{
  int i;
  if (!pause) {
    static double angle = 0;
    angle += 0.05;
    //dBodyAddForce (body[NUM-1],0,0,1.5*(sin(angle)+1.0));

    dSpaceCollide (space,0,&nearCallback);
    dWorldStep (world,0.04);

    /* remove all contact joints */
    dJointGroupEmpty (contactgroup);
 
 	const dReal* t_rot = dBodyGetRotation(body[5]);
 	const dReal* h_rot = dBodyGetRotation(body[4]);
	
	static int j = 0;
	j++;

 	if (fallen == 0) {

		dReal k1_angle = dJointGetHingeAngle(joint[0]);
		dReal k2_angle = dJointGetHingeAngle(joint[2]);
	
		//if (j%20 ==0)	printf("%g %g \n", k1_angle, k2_angle);	

		dJointAddHingeTorque(joint[0], -0.12*k1_angle);
		dJointAddHingeTorque(joint[2], -0.121*k2_angle);

		dReal h1_angle = dJointGetHingeAngle(joint[1]);
		dJointAddHingeTorque(joint[1], -0.2*h1_angle);
		
		dReal h2_angle = dJointGetHingeAngle(joint[3]);
		dJointAddHingeTorque(joint[3], -0.2*h2_angle);
		
		dReal t_angle = dJointGetHinge2Angle1(joint[4]);
		//dReal t_angle2= dJointGetHinge2Angle2(joint[4]);
		dJointAddHinge2Torques(joint[4], -0.221*t_angle,0);
		
	
		const dReal* torso_vel = dBodyGetLinearVel(body[5]);	
		
		float sc = 4.5;
		float hc = 6.5;
		//if (torso_vel[1] < 0.0) {
			/// continue to spread legs apart
			if (h1_angle < h2_angle) { 
				dJointAddHingeTorque(joint[0],  sc*torso_vel[1]);
				dJointAddHingeTorque(joint[1], -hc*torso_vel[1]);
				dJointAddHingeTorque(joint[2], -sc*torso_vel[1]);
				dJointAddHingeTorque(joint[3],  hc*torso_vel[1]);
			} else {
				dJointAddHingeTorque(joint[0], -sc*torso_vel[1]);
				dJointAddHingeTorque(joint[1],  hc*torso_vel[1]);
				dJointAddHingeTorque(joint[2],  sc*torso_vel[1]);
				dJointAddHingeTorque(joint[3], -hc*torso_vel[1]);
			}
		//} else {

		//}

		if ((t_rot[5] < 0.2) &&(h_rot[5] < 0.2)) {
		//	fallen = 1;
		//	printf("fallen\n");
		}
	} else {
		dJointAddHinge2Torques(joint[4], 0.1,0);
		dJointAddHingeTorque(joint[3], 0.1);
		dJointAddHingeTorque(joint[1], 0.1);
		
		dJointAddHingeTorque(joint[2], -0.15);
		dJointAddHingeTorque(joint[0], -0.15);

		if ((t_rot[5] > 0.8) &&(h_rot[5] > 0.8)) {
			fallen = 0;
		}

	}
//	if (j%20 ==0)	printf("%g %g %g\n", t_rot[8], t_rot[9], t_rot[10]);	
  
  }

  dsSetColor (1,1,0);
  dsSetTexture (DS_WOOD);

  const dReal ss[3] = {SIDE, SIDE, SIDE*2};
  const dReal sships[3] = {2*SIDE, SIDE, SIDE*0.7};
  const dReal sstorso[3] = {2*SIDE, SIDE, 2*SIDE};
  const dReal sshead[3] = {SIDE, SIDE, SIDE};
  for (i=0; i<NUM; i++) {
  	if (i == 4)
  		dsDrawBox(dBodyGetPosition(body[i]),dBodyGetRotation(body[i]),sships);
  	else if (i == 5)
  		dsDrawBox(dBodyGetPosition(body[i]),dBodyGetRotation(body[i]),sstorso);
  	else if (i == 6)
  		dsDrawBox(dBodyGetPosition(body[i]),dBodyGetRotation(body[i]),sshead);
	else
  		dsDrawBox(dBodyGetPosition(body[i]),
				      	   		  dBodyGetRotation(body[i]),ss);
  
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
  fn.command = 0;
  fn.stop = 0;
  fn.path_to_textures = "../../drawstuff/textures";
  if(argc==2)
    {
        fn.path_to_textures = argv[1];
    }

  /* create world */
  dInitODE();
  world = dWorldCreate();
  space = dHashSpaceCreate (0);
  contactgroup = dJointGroupCreate (1000000);
  dWorldSetGravity (world,0,0,-0.2);
  dCreatePlane (space,0,0,1,0);

  for (i=0; i<NUM; i++) {
    body[i] = dBodyCreate (world);
    dMassSetBox (&m,1,SIDE,SIDE,SIDE*2);

	if (i < 4) {
    	sphere[i] = dCreateBox (space,SIDE,SIDE,SIDE*2);
    	dMassAdjust (&m,MASS);
	} else if (i == 4) {
    	sphere[i] = dCreateBox (space,SIDE*2,SIDE,SIDE*0.7);
    	dMassAdjust (&m,MASS*0.7);
	} else if (i == 5) {
    	sphere[i] = dCreateBox (space,SIDE*2,SIDE,SIDE*2);
    	dMassAdjust (&m,MASS*1.1);
	} else if (i == 6) {
    	sphere[i] = dCreateBox (space,SIDE,SIDE,SIDE);
    	dMassAdjust (&m,MASS/2);
	} else {
   	 	sphere[i] = dCreateBox (space,SIDE,SIDE,SIDE);
    	dMassAdjust (&m,MASS);
   	}

	dBodySetMass (body[i],&m);
    
	dGeomSetBody (sphere[i],body[i]);
  }
	
 k = -1;

  /// bottom of left leg
  dBodySetPosition (body[0],k+SIDE*0.6,-k,SIDE*1.1);
  dBodySetPosition (body[1],k+SIDE*0.6,-k,SIDE*3.2);
  
  dBodySetPosition (body[2],k-SIDE*0.6,-k,SIDE*1.1);
  dBodySetPosition (body[3],k-SIDE*0.6,-k,SIDE*3.2);
 	
  dBodySetPosition (body[4],k,-k,SIDE*4.7);
  
  dBodySetPosition (body[5],k,-k,SIDE*6.2);
  
  dBodySetPosition (body[6],k,-k,SIDE*8.2);

    joint[0] = dJointCreateHinge (world,0);
	dJointAttach(joint[0], body[0],body[1]);
	dJointSetHingeAnchor (joint[0],k+SIDE*0.6,-k,2.2*SIDE);
    dJointSetHingeAxis(joint[0],1,0,0);
	dJointSetHingeParam(joint[0],dParamLoStop,-1.9);
	dJointSetHingeParam(joint[0],dParamHiStop,0.1);

    joint[1] = dJointCreateHinge (world,0);
	dJointAttach(joint[1], body[1],body[4]);
	dJointSetHingeAnchor (joint[1],k+SIDE*0.6,-k,4.3*SIDE);
    dJointSetHingeAxis (joint[1],1,0,0);
	dJointSetHingeParam(joint[1],dParamLoStop,-1.0);
	dJointSetHingeParam(joint[1],dParamHiStop,1.3);


    joint[2] = dJointCreateHinge (world,0);
	dJointAttach(joint[2], body[2],body[3]);
	dJointSetHingeAnchor (joint[2],k-SIDE*1.1,-k,2.2*SIDE);
    dJointSetHingeAxis(joint[2],1,0,0);
	dJointSetHingeParam(joint[2],dParamLoStop,-1.9);
	dJointSetHingeParam(joint[2],dParamHiStop,0.1);

    joint[3] = dJointCreateHinge (world,0);
	dJointAttach(joint[3], body[3],body[4]);
	dJointSetHingeAnchor (joint[3],k-SIDE*1.1,-k,4.3*SIDE);
    dJointSetHingeAxis (joint[3],1,0,0);
	dJointSetHingeParam(joint[3],dParamLoStop,-1.0);
	dJointSetHingeParam(joint[3],dParamHiStop,1.3);

    joint[4] = dJointCreateHinge2 (world,0);
	dJointAttach(joint[4], body[4],body[5]);
	dJointSetHinge2Anchor (joint[4],k,-k,4.8*SIDE);
    dJointSetHinge2Axis1 (joint[4],1,0,0);
    dJointSetHinge2Axis2 (joint[4],0,0,1);
	dJointSetHinge2Param(joint[4],dParamLoStop,-0.3);
	dJointSetHinge2Param(joint[4],dParamHiStop,1.3);
	dJointSetHinge2Param(joint[4],dParamLoStop2, -0.1);
	dJointSetHinge2Param(joint[4],dParamHiStop2,  0.1);


    joint[5] = dJointCreateUniversal (world,0);
	dJointAttach(joint[5], body[5],body[6]);
	dJointSetUniversalAnchor (joint[5],k,-k,7.2*SIDE);
	dJointSetUniversalAxis1(joint[5], 1,0,0);
	dJointSetUniversalAxis2(joint[5], 0,1,0);
	dJointSetUniversalParam(joint[5],dParamLoStop, -0.7);
	dJointSetUniversalParam(joint[5],dParamHiStop,  0.7);
	dJointSetUniversalParam(joint[5],dParamLoStop2, -0.7);
	dJointSetUniversalParam(joint[5],dParamHiStop2,  0.7);

/* run simulation */
  dsSimulationLoop (argc,argv,600,400,&fn);

  dJointGroupDestroy (contactgroup);
  dSpaceDestroy (space);
  dWorldDestroy (world);
  dCloseODE();
  return 0;
}
