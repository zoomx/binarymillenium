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
#include <sstream>
#include <vector>

#include <SDL2/SDL.h>
#include <Box2D/Box2D.h>

#include <cstdio>

using namespace std;

std::vector<SDL_Surface*> surfaces;

static void
ScreenShot(SDL_Renderer *renderer, const int ind=0)
{
    SDL_Rect viewport;
    SDL_Surface *surface;

    if (!renderer) {
        return;
    }

    SDL_RenderGetViewport(renderer, &viewport);
    surface = SDL_CreateRGBSurface(0, viewport.w, viewport.h, 24,
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
                    0x00FF0000, 0x0000FF00, 0x000000FF,
#else
                    0x000000FF, 0x0000FF00, 0x00FF0000,
#endif
                    0x00000000);
    if (!surface) {
        fprintf(stderr, "Couldn't create surface: %s\n", SDL_GetError());
        return;
    }

    if (SDL_RenderReadPixels(renderer, NULL, surface->format->format,
                             surface->pixels, surface->pitch) < 0) {
        fprintf(stderr, "Couldn't read screen: %s\n", SDL_GetError());
        return;
    }
   
   surfaces.push_back(surface);
}

void saveSurfaces() 
{
  
  for (int ind = 0; ind < surfaces.size(); ind++) {
    stringstream ss;
    ss << "screen_" << ind << ".bmp";
    std::cout << ss.str() << std::endl;
    if (SDL_SaveBMP(surfaces[ind], ss.str().c_str()) < 0) {
      fprintf(stderr, "Couldn't save screenshot.bmp: %s\n", SDL_GetError());
      return;
    }
  }
}


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

void reverseMotor(b2RevoluteJoint* joint)
{

  float vel = joint->GetMotorSpeed();
  
  if (vel >= 0) joint->SetMotorSpeed(-0.2);
  else joint->SetMotorSpeed(0.2);
}
void increaseMotor(b2RevoluteJoint* joint)
{
  float vel = joint->GetMotorSpeed();
  //std::cout << "j " << vel << std::endl;
  
  vel = 100;
  #if 0
  if (vel <= 0) 
    vel *= 1.1; 
  else 
    vel *= 0.9;
  vel -= 0.2;
  #endif
  joint->SetMotorSpeed(vel);
}

void decreaseMotor(b2RevoluteJoint* joint)
{
  float vel = joint->GetMotorSpeed();
  //std::cout << "k " << vel << std::endl;
  if (vel >= 0) 
    vel *= 1.1;
  else 
    vel *= 0.9;
  vel += 0.2;
  vel = -100;
  joint->SetMotorSpeed(vel);
}

bool addLeg(
      b2World& the_world,
      b2Body* trunk, 
      b2Body*& leg, 
      b2RevoluteJoint*& joint,
      const float bx, const float by, const float jx, const float jy,
      const float min_angle = -0.13f,
      const float max_angle = 0.13f,
      const float max_torque = 95.0f,
     
      const float hw = 0.75f,
      const float hh = 1.5f,
      const float friction = 0.5f,
      const bool enable_motor = true,
      const float density = 1.0f
      )
  {
    b2BodyDef body_def;
    body_def.type = b2_dynamicBody;
    body_def.position.Set(bx, by);
    leg = the_world.CreateBody(&body_def);

    b2PolygonShape dynamic_box;
    dynamic_box.SetAsBox(hw, hh, body_def.position, 0.0);

    b2FixtureDef fixture_def;
    fixture_def.filter.categoryBits = 0x0002;
    fixture_def.filter.maskBits = 0x0005;
    fixture_def.shape = &dynamic_box;
    
    fixture_def.density = density;
    fixture_def.friction = friction;
    fixture_def.restitution = 0.2f;

    leg->CreateFixture(&fixture_def);
 
    // now attach with joint
    b2RevoluteJointDef joint_def;
    
    joint_def.Initialize(trunk, leg, b2Vec2(2*jx,2*jy)); 
    joint_def.lowerAngle = min_angle * b2_pi; // -90 degrees
    joint_def.upperAngle = max_angle * b2_pi; // 45 degrees
    joint_def.enableLimit = true; //enable_motor; //true;
    joint_def.maxMotorTorque = max_torque;
    joint_def.motorSpeed = 0.0f;
    joint_def.enableMotor = true; //enable_motor;
    joint = (b2RevoluteJoint*)the_world.CreateJoint(&joint_def);
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

  {
    b2BodyDef ground_body_def;
    ground_body_def.position.Set(0.0f, -10.0f);

    b2Body* ground_body = the_world.CreateBody(&ground_body_def);
    all_bodies.push_back(ground_body);

    b2PolygonShape ground_box;

    ground_box.SetAsBox(50.0f, 10.0f);

    ground_body->CreateFixture(&ground_box, 0.0f);
  }

  // the main trunk
  b2Body* trunk;
  {
    b2BodyDef body_def;
    body_def.type = b2_dynamicBody;
    body_def.position.Set(0.0f, 4.6f);
    trunk = the_world.CreateBody(&body_def);

    b2PolygonShape dynamic_box;
    dynamic_box.SetAsBox(3.7f, 1.2f, body_def.position, 0.0);

    b2FixtureDef fixture_def;
    fixture_def.shape = &dynamic_box;
    
    fixture_def.density = 1.0f;
    fixture_def.friction = 0.3f;
    fixture_def.restitution = 0.6f;

    trunk->CreateFixture(&fixture_def);
  }

  // add legs
  {
    b2Body* leg;
    b2Body* calf;
    b2Body* foot;
    b2RevoluteJoint* joint;
   
    float hip_y = 4.0f;
    float hip_cy = 3.5f;
    float knee_y = 2.7f;
    float knee_cy = 2.0f;
    const float ankle_y = 1.5f;
    const float ankle_cy = 1.25f;
    const float pos_x1 = 1.7f;
    const float pos_x2 = -pos_x1;
    const float friction = 1.0f;
    
    vector<float> pos_x;
    pos_x.push_back(pos_x1);
    pos_x.push_back(pos_x1-0.1);
    pos_x.push_back(-pos_x1+0.1);
    pos_x.push_back(-pos_x1);
    for (int i = 0; i < pos_x.size(); i++) {
      // thigh
      addLeg(the_world, trunk, leg, joint, pos_x[i], hip_cy, pos_x[i], hip_y, 
          -0.13f, 0.27f,
          204.0f); 
      all_bodies.push_back(leg);
      all_rev_joints.push_back(joint);

      // foreleg 
      addLeg(the_world, leg, calf, joint, pos_x[i], knee_cy, pos_x[i], knee_y, -0.65f,0.0f,
        20.0f); 
      all_bodies.push_back(calf);
      all_rev_joints.push_back(joint);
      
      // foot
      const float foot_torque = 35.0;
      const float foot_angle = 0.4;
      addLeg(the_world, calf, foot, joint, pos_x[i], ankle_cy, pos_x[i], ankle_y, 
          -foot_angle, foot_angle, 
          foot_torque, 
          1.0, 0.5, friction, 
          false ); 
      all_bodies.push_back(foot);
      all_rev_joints.push_back(joint);
    } 
  } // legs
  /*
   * const float bx, const float by, const float jx, const float jy,
      const float min_angle = -0.13f,
      const float max_angle = 0.13f,
      const float max_torque = 95.0f,
     
      const float hw = 0.75f,
      const float hh = 1.5f,
      const float friction = 0.5f,
      const bool enable_motor = true,
      const float density = 1.0f
      
   */
  // preserve indices by adding this now
  all_bodies.push_back(trunk);

  // head
  {
  b2Body* head;
   b2RevoluteJoint* joint;
   
  addLeg(the_world, trunk, head, joint, 2.4, 5.0, 2.0, 5.0, 
      -0.13, 0.13, 10.0f, 
      1.9f, 0.8f, // hw hh
      0.5f,
      false, // motor 
      2.2 // density
      ); // -0.13f, 0.20f,
      all_bodies.push_back(head);
      all_rev_joints.push_back(joint);
  }

	float32 time_step = 1.0f / 60.0f;
	int32 velocity_iterations = 6;
	int32 position_iterations = 2;

  int event_pending = 0;
  SDL_Event event;

  float ox = 220;
  float oy = 300;
  float sc = 20.0;
  
  vector<bool> center_feet;
  center_feet.resize(4);
  for (int i = 0; i < 4; i++) center_feet[i] = true;
  /////////////////////////////////////
  int ind = 0;
  bool do_loop = true;
	while (do_loop)
  {
		the_world.Step(time_step, velocity_iterations, position_iterations);

    SDL_SetRenderDrawColor(renderer, 50, 50, 100, 255);
    SDL_RenderClear(renderer);

    drawGrid(renderer, 10,10,10, ox, oy, sc);
    
    for (int i = 0; i < all_bodies.size(); i++) {
      drawBody(renderer, all_bodies[i], 255,(55 * (i%2)) +200,255, ox, oy, sc);
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
    //ScreenShot(renderer, ind + 100000); 
    ind += 1; 
    //SDL_Delay(10); 
    #if 0
    std::cout << "angle " 
      << all_rev_joints[bind]->GetJointAngle() << " "
      << all_bodies[bind+1]->GetAngle() << " "
      //<< all_rev_joints[5]->GetJointAngle()
      << std::endl;
    #endif
   
    const float motor_vel  = 0.2f;
    for (int i = 0 ; i<4; i++) {
      const int bind = i*3 + 2;
      if (center_feet[i]) {
        float angle = all_bodies[bind+1]->GetAngle();
        all_rev_joints[bind]->SetMotorSpeed(-0.5f * angle);
        
        float knee_angle =
            all_bodies[bind-1]->GetAngle() - 
            all_bodies[bind]->GetAngle();

        //all_rev_joints[bind-1]->SetMotorSpeed(-0.2f * angle);
        all_rev_joints[bind-1]->SetMotorSpeed(motor_vel);
      } else {
        all_rev_joints[bind]->SetMotorSpeed(-motor_vel);
        all_rev_joints[bind-1]->SetMotorSpeed(-motor_vel);
      }
    }

    bool used_key = true;
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
       
        /////////////////////////////////////
        if (event.key.keysym.sym == SDLK_j) {
          if (center_feet[0]) {
          //all_rev_joints[0]->SetMotorSpeed(-50);
          center_feet[0] = false;
          } else {
            center_feet[0] = true;
          }
        } 
        if (event.key.keysym.sym == SDLK_k) {
          if (center_feet[1]) {
            center_feet[1] = false;
          } else center_feet[1] = true;
        }
        if (event.key.keysym.sym == SDLK_l) {
          if (center_feet[2]) {
            center_feet[2] = false;
          } else center_feet[2] = true;
        } 
        if (event.key.keysym.sym == SDLK_SEMICOLON) {
          if (center_feet[3]) {
            center_feet[3] = false;
          } else center_feet[3] = true;
        } 

        if (event.key.keysym.sym == SDLK_a) {
          reverseMotor(all_rev_joints[0]); 
        } 
        if (event.key.keysym.sym == SDLK_s) {reverseMotor(all_rev_joints[3]); } 
        if (event.key.keysym.sym == SDLK_d) {reverseMotor(all_rev_joints[6]); } 
        if (event.key.keysym.sym == SDLK_f) {reverseMotor(all_rev_joints[9]); } 
       
        if (event.key.keysym.sym == SDLK_n) {
          for (int i = 0; i< center_feet.size() ; i++) {
            center_feet[i] = !center_feet[i];
          }
        }
        
        if (event.key.keysym.sym == SDLK_m) {
          reverseMotor(all_rev_joints[0]); 
          reverseMotor(all_rev_joints[3]); 
          reverseMotor(all_rev_joints[6]); 
          reverseMotor(all_rev_joints[9]); 
        } 
       #if 0
        if (event.key.keysym.sym == SDLK_n) {
          center_feet = true;
        //  b2RevoluteJoint* joint = all_rev_joints[bind]; 
        //  joint->SetMotorSpeed(-50);
        } else  
          if (event.key.keysym.sym == SDLK_m) {
            center_feet = false;
     //     b2RevoluteJoint* joint = all_rev_joints[bind]; 
       //   joint->SetMotorSpeed(50);
        } else {
          used_key = false;
        } 
        #endif
      
      } // keydown
    } // key stuff

    #if 0
    if (!used_key) {
      b2RevoluteJoint* joint = all_rev_joints[bind]; 
      joint->SetMotorSpeed(0);
    }
    #endif

  } // event loop

  saveSurfaces();

	SDL_DestroyWindow(window); 
  SDL_Quit(); 

	return 0;
}
