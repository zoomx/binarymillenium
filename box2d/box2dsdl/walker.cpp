/*
  (c) Lucas Walter 2013

  a walking robot/animal box2d simulation

    This is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this.  If not, see <http://www.gnu.org/licenses/>.
 
*/

#include <iostream>
#include <vector>

#include <SDL2/SDL.h>
#include <Box2D/Box2D.h>

#include <cstdio>

using namespace std;

bool drawGrid(
  SDL_Renderer* renderer,
  int r, int g, int b,
  int ox,
  int oy,
  int sc
  ) 
{ 
  SDL_SetRenderDrawColor(renderer, r, g, b, 255);

  const int mx = 30;
  for (int x = -mx; x <= mx; x++) {
    //SDL_SetRenderDrawColor(renderer, 255*(float)abs(x)/mx, g, b, 255);
    SDL_RenderDrawLine(renderer, 
            sc * x + ox, -sc * (-mx) + oy ,
            sc * x + ox, -sc * (mx) + oy
            );

  }
  for (int y = -30; y <= 30; y++) {
   // SDL_SetRenderDrawColor(renderer, r,g,255*(float)abs(y)/mx, 255);
    SDL_RenderDrawLine(renderer, 
            sc * (-mx) + ox, -sc * y + oy ,
            sc * (mx) + ox, -sc * y + oy
            );
  }

  return true;
}

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
      360,                      //    int h: height, in pixels
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

  SDL_SetRenderDrawColor(renderer, 100, 100, 250, 255);
  SDL_RenderClear(renderer);

  // swap buffers or equivalent
  SDL_RenderPresent(renderer);
  
  /////////////////////////////////////////////////////

  // BOX2D stuff

  std::vector<b2Body*> all_bodies;
  std::vector<b2RevoluteJoint*> all_rev_joints;

	b2Vec2 gravity(0.0f, -1.0f);

	b2World the_world(gravity);

	b2BodyDef ground_body_def;
	ground_body_def.position.Set(0.0f, -10.0f);

	b2Body* ground_body = the_world.CreateBody(&ground_body_def);
  all_bodies.push_back(ground_body);

	b2PolygonShape ground_box;

	ground_box.SetAsBox(50.0f, 10.0f);

	ground_body->CreateFixture(&ground_box, 0.0f);

  // the main trunk 
  {
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(0.0f, 4.0f);
    b2Body* body = the_world.CreateBody(&bodyDef);
    all_bodies.push_back(body);

    b2PolygonShape dynamic_box;
    dynamic_box.SetAsBox(4.0f, 1.0f, bodyDef.position, 0.0);

    b2FixtureDef fixture_def;
    fixture_def.shape = &dynamic_box;
    
    fixture_def.density = 1.0f;
    fixture_def.friction = 0.3f;
    fixture_def.restitution = 0.6f;

    body->CreateFixture(&fixture_def);
  }

  // add legs
  {
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(1.0f, 5.0f);
    b2Body* body = the_world.CreateBody(&bodyDef);
    all_bodies.push_back(body);

    b2PolygonShape dynamic_box;
    dynamic_box.SetAsBox(1.0f, 1.0f, bodyDef.position, 0.0);

    b2FixtureDef fixture_def;
    fixture_def.shape = &dynamic_box;
    
    fixture_def.density = 1.0f;
    fixture_def.friction = 0.3f;
    fixture_def.restitution = 0.6f;

    body->CreateFixture(&fixture_def);
  
    // join last two bodies together 
    b2RevoluteJoint* joint;
    {
      b2RevoluteJointDef joint_def;
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
      joint_def.Initialize(b2a, b2b, pj); 

      joint = (b2RevoluteJoint*)the_world.CreateJoint(&joint_def);
      all_rev_joints.push_back(joint);
      //b2Vec2 t1 = joint->GetAnchorA(); 
      //b2Vec2 t2 = joint->GetAnchorB();
      //std::cout << t1.x << " " << t1.y << ", " << t2.x << " " << t2.y << std::endl;
    }
  }

	float32 time_step = 1.0f / 60.0f;
	int32 velocity_iterations = 6;
	int32 position_iterations = 2;

  int event_pending = 0;
  SDL_Event event;

  float ox = 320;
  float oy = 300;
  float sc = 20.0;

  /////////////////////////////////////
  bool do_loop = true;
	while (do_loop)
  {
		the_world.Step(time_step, velocity_iterations, position_iterations);

    SDL_SetRenderDrawColor(renderer, 50, 50, 100, 255);
    SDL_RenderClear(renderer);

    drawGrid(renderer, 10,10,10, ox, oy, sc);
    
    for (int i = 0; i < all_bodies.size(); i++) {
      drawBody(renderer, all_bodies[i], 255,255,155, ox, oy, sc);
    }
    
    // draw joint crosshairs
    for (int i = 0; i < all_rev_joints.size(); i++) {
      b2Joint* joint = all_rev_joints[i];
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

	SDL_DestroyWindow(window); 
  SDL_Quit(); 

	return 0;
}
