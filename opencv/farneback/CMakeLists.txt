cmake_minimum_required(VERSION 2.4.6)
cmake_policy(SET CMP0003 OLD)

set(PROJECT_NAME fback)

#set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/build )
#set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/build )

include_directories( . )
#include_directories( $ENV{HG_CLONE_DIR}/external/include )
include_directories( $ENV{HOME}/other/install/include )


include_directories(${CMAKE_CURRENT_BINARY_DIR})

###############################################################################

set(CMAKE_FIND_LIBRARY_SUFFICES ".a;.so")

find_package(OpenCV REQUIRED)


set(SOME_LIBS  
${OpenCV_LIBS}
 )


###############################################################################

add_executable(${PROJECT_NAME}
fback.cpp
)

target_link_libraries(${PROJECT_NAME} 
${SOME_LIBS} 
)


