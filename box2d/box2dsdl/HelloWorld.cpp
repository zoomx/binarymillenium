/*
* Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

#include <iostream>
#include <vector>

#include <SDL2/SDL.h>
#include <Box2D/Box2D.h>

#include <cstdio>

using namespace std;

bool drawBody(
  SDL_Renderer* renderer,
  b2Body* body, 
  int r, int g, int b,
  int ox,
  int oy,
  int sc
  ) 
{ 
  SDL_SetRenderDrawColor(renderer, r, g, b, 255);
  //http://box2d.org/forum/viewtopic.php?f=3&t=1933
  for( b2Fixture *fixture = body->GetFixtureList(); fixture; fixture = fixture->GetNext() )
  {
    if( fixture->GetType() == b2Shape::e_polygon )
    {
      b2PolygonShape *poly = (b2PolygonShape*)fixture->GetShape();

      const int count = poly->GetVertexCount();

      for( int i = 0; i < count; i++ )
      {
        int ind0 = (i + 1) % count ;
        b2Vec2 p0 = body->GetWorldPoint(  poly->GetVertex( ind0 ) );
        b2Vec2 p1 = body->GetWorldPoint(  poly->GetVertex(i) );

#if 0
        std::cout << i << " " << ind0 << " " 
          << p0.x << " " << p0.y << " "
          << p1.x << " " << p1.y << " "
          << std::endl;
#endif

        SDL_RenderDrawLine(renderer, 
            sc * p0.x + ox, -sc * p0.y + oy ,
            sc * p1.x + ox, -sc * p1.y + oy
            );

      }
      //verts now contains the_world co-ords of all the verts
    }
  }
}

#if 0
float random()
{
  return std::rand() / static_cast<float>(RAND_MAX);
}
#endif
float randomRange( float low, float high )
{
  float range = high - low;
  return static_cast<float>(random()/static_cast<float>(RAND_MAX) * range) + low;
}


// This is a simple example of building and running a simulation
// using Box2D. Here we create a large ground box and a small dynamic
// box.
// There are no graphics for this example. Box2D is meant to be used
// with your rendering engine in your game engine.
int main(int argc, char** argv)
{

    //std::srand(std::time(0));

  /// SDL stuff
  SDL_Init(SDL_INIT_VIDEO);
  SDL_Window *window;

  window = SDL_CreateWindow( 
      "An SDL2 window",         //    const char* title
      0, //SDL_WINDOWPOS_UNDEFINED,  //    int x: initial x position
      0, //SDL_WINDOWPOS_UNDEFINED,  //    int y: initial y position
      640,                      //    int w: width, in pixels
      480,                      //    int h: height, in pixels
      SDL_WINDOW_SHOWN          //    Uint32 flags: window options, see docs
      );

  // Check that the window was successfully made
  if(window==NULL){   
    // In the event that the window could not be made...
    std::cout << "Could not create window: " << SDL_GetError() << '\n';
    SDL_Quit(); 
    return 1;
  }

  SDL_Renderer* renderer;

  renderer = SDL_CreateRenderer(window, -1, 0);

  // Select the color for drawing. It is set to red here.
  SDL_SetRenderDrawColor(renderer, 100, 100, 250, 255);

  // Clear the entire screen to our selected color.
  SDL_RenderClear(renderer);

  // Up until now everything was drawn behind the scenes.
  // This will show the new, red contents of the window.
  SDL_RenderPresent(renderer);
  
  SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
  /////////////////////////////////////////////////////


  // BOX2D stuff
	
  B2_NOT_USED(argc);
	B2_NOT_USED(argv);

  std::vector<b2Body*> all_bodies;
  std::vector<b2Joint*> all_joints;

	// Define the gravity vector.
	b2Vec2 gravity(0.0f, -10.0f);

	// Construct a the_world object, which will hold and simulate the rigid bodies.
	b2World the_world(gravity);

	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0.0f, -10.0f);

	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the the_world.
	b2Body* groundBody = the_world.CreateBody(&groundBodyDef);
  all_bodies.push_back(groundBody);

	// Define the ground box shape.
	b2PolygonShape groundBox;

	// The extents are the half-widths of the box.
	groundBox.SetAsBox(50.0f, 10.0f);

	// Add the ground fixture to the ground body.
	groundBody->CreateFixture(&groundBox, 0.0f);

  {
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(0.0f, 4.0f);
    b2Body* body = the_world.CreateBody(&bodyDef);
    all_bodies.push_back(body);

    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(1.0f, 1.0f, bodyDef.position, 0.0);

    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.6f;

    body->CreateFixture(&fixtureDef);
  }

  {
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(1.0f, 5.0f);
    b2Body* body = the_world.CreateBody(&bodyDef);
    all_bodies.push_back(body);

    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(1.0f, 1.0f, bodyDef.position, 0.0);

    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    fixtureDef.restitution = 0.6f;

    body->CreateFixture(&fixtureDef);
  }
  
  // join last two bodies together 
  b2RevoluteJoint* joint;
  {
    b2RevoluteJointDef jointDef;
    b2Body* b2a = all_bodies[all_bodies.size()-1];
    b2Body* b2b = all_bodies[all_bodies.size()-2];
    b2Vec2 pa = b2a->GetPosition();
    b2Vec2 pb = b2b->GetPosition();
    b2Vec2 pj = pa + pb;
    // there seems to be a scale factor of 2 in joint position vs. body position, I don't get it
    pj; // = 0.5 * pj;
    std::cout
      << pa.x << " " << pa.y << ", " 
      << pb.x << " " << pb.y << ", "
      << pj.x << " " << pj.y << std::endl;
    jointDef.Initialize(b2a, b2b, pj); 

    joint = (b2RevoluteJoint*)the_world.CreateJoint(&jointDef);
    //b2Vec2 t1 = joint->GetAnchorA(); 
    //b2Vec2 t2 = joint->GetAnchorB();
    //std::cout << t1.x << " " << t1.y << ", " << t2.x << " " << t2.y << std::endl;
  }

	float32 timeStep = 1.0f / 60.0f;
	int32 velocityIterations = 6;
	int32 positionIterations = 2;

  int event_pending = 0;
  SDL_Event event;

  float ox = 320;
  float oy = 400;
  float sc = 20.0;

  /////////////////////////////////////
  bool do_loop = true;
	while (do_loop)
  {
		the_world.Step(timeStep, velocityIterations, positionIterations);

    SDL_SetRenderDrawColor(renderer, 100, 100, 250, 255);
    SDL_RenderClear(renderer);

    for (int i = 0; i < all_bodies.size(); i++) {
      drawBody(renderer, all_bodies[i], 255,255,155, ox, oy, sc);
    }
    
    // draw joint crosshairs
    {
      b2Vec2 t1 = joint->GetAnchorA(); 
      b2Vec2 t2 = joint->GetAnchorB();
      b2Vec2 t3 = joint->GetAnchorB();
   
    SDL_RenderDrawLine(renderer, 
            sc * t1.x + ox, -sc * t1.y + oy ,
            sc * t1.x + ox, -sc * t1.y + oy
            );

      SDL_RenderDrawLine(renderer, 
            sc * t1.x + ox - 10, -sc * t1.y + oy ,
            sc * t1.x + ox + 10, -sc * t1.y + oy
            );
      SDL_RenderDrawLine(renderer, 
            sc * t2.x + ox, -sc * t2.y + oy - 10 ,
            sc * t2.x + ox, -sc * t2.y + oy + 10
            );
    }

    SDL_RenderPresent(renderer);
    SDL_Delay(10);  
    
    {
      event_pending = SDL_PollEvent(&event);

      if (event_pending == 0) continue;
    
      if (event.type == SDL_KEYDOWN) {
        if (event.key.keysym.sym == SDLK_q) do_loop = false;
        if (event.key.keysym.sym == SDLK_ESCAPE) do_loop = false;

        if (event.key.keysym.sym == SDLK_r) {
          const float x1 = randomRange(0, 10.0);
          const float y1 = randomRange(0, 10.0);
          const float a1 = randomRange(0, M_PI);
          //std::cout << "x1 " << x1 <<std::endl;
          all_bodies[1]->SetTransform(b2Vec2(0.0f + x1, 4.0 + y1), a1);
        }
       
        const float fr = 3.0;
        
        if (event.key.keysym.sym == SDLK_UP) {
          oy += 6.0*sc/fr;
        }
        if (event.key.keysym.sym == SDLK_DOWN) {
          oy -= 5.9*sc/fr;
        }
        if (event.key.keysym.sym == SDLK_RIGHT) {
          ox -= 5.9*sc/fr;
        }
        if (event.key.keysym.sym == SDLK_LEFT) {
          ox += 6.0*sc/fr;
        }
        if (event.key.keysym.sym == SDLK_t) {
          sc *= 1.05;
        }
        if (event.key.keysym.sym == SDLK_g) {
          sc *= 0.97;
        }

      } // keydown
    } // key stuff

  } // event loop

    
	// When the the_world destructor is called, all bodies and joints are freed. This can
	// create orphaned pointers, so be careful about your the_world management.

   
    
  // The window is open: enter program loop (see SDL_PollEvent)
  
  // Close and destroy the window
  SDL_DestroyWindow(window); 
  
  // Clean up SDL2 and exit the program
  SDL_Quit(); 


	return 0;
}
