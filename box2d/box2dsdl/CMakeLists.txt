cmake_minimum_required(VERSION 2.8)


include_directories($ENV{HOME}/other/install/include)
link_directories($ENV{HOME}/other/install/lib)

#find_package(SDL)
#find_program(SDLC sdl2-config)
#execute_process ( 
#  COMMAND sdl2-config --libs
#  OUTPUT_VARIABLE SDL_LIBS
#  )

add_executable(walker walker.cpp)
target_link_libraries (walker 
  Box2D
  SDL2
  )
