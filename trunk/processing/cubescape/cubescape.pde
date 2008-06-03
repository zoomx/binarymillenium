/**
* cubescape
* binarymillenium
*
*/

import processing.opengl.*;

final int MAP_X = 30;
final int MAP_Y = 80;
final float SIZE = 1.0;

Cube[][] cubes = new Cube[MAP_X][MAP_Y];

void setup() {
   size(640,480, OPENGL);
  background(0); 
  
  //frustum(-width/2, width/2, -height/2, height/2, -100, 500.0);
  float fov = PI/3.0;
float cameraZ = (height/2.0) / tan(PI * fov / 360.0);
perspective(fov, float(width)/float(height), 
            0.1, 200);
  
  
    for (int i = 0; i < MAP_X; i++) {
  for (int j = 0; j < MAP_Y; j++) {

    
    cubes[i][j] = new Cube(SIZE,0.0,SIZE,
                          i*SIZE - MAP_X/2, 0, j*SIZE);
    
  
  }} 
  
  update_map();

}

float t =0.0;
int skipx= 0;
int skipy = 0;

void update_map() {
  
  final int MAXSKIP = 1;
   final float div = 9.0;
   
  for (int i = skipx; i < MAP_X; i+=MAXSKIP) {
  for (int j = skipy; j < MAP_Y; j+=MAXSKIP) {
    float field_height = noise((float)i/div,(float)(j+t*300.0)/div,t);
    
    field_height *= 15.0*SIZE*field_height;
    
    cubes[i][j].h =field_height;
    
  
  }}  
  
  t+=0.001;
  
  skipx = (int)random(MAXSKIP);
  skipy = (int)random(MAXSKIP);
}

void draw(){
  background(0); 
  fill(200);

  //set up some different colored lights
  pointLight(51, 102, 255, 65, 60, 100); 
  pointLight(200, 40, 60, -65, -60, -150);

  //raise overall light in scene 
  ambientLight(70, 70, 10); 
  
   translate(width/2, height/2 + height/90.0 + mouseY/180.0, width/2+mouseX/50.0);
  
  for (int i = 0; i < MAP_X; i++) {
  for (int j = 0; j < MAP_Y; j++) {
    cubes[i][j].drawCube();
  }
  }
  
  update_map();
  
}

/** from spacejunk example */
//simple Cube class, based on Quads
class Cube {

  //properties
  float w, h, d;
  float shiftX, shiftY, shiftZ;

  //constructor
  Cube(float w, float h, float d, 
       float shiftX, float shiftY, float shiftZ){
    this.w = w;
    this.h = h;
    this.d = d;
    this.shiftX = shiftX;
    this.shiftY = shiftY;
    this.shiftZ = shiftZ;
  }

  /*main cube drawing method, which looks 
   more confusing than it really is. It's 
   just a bunch of rectangles drawn for 
   each cube face*/
  void drawCube(){
    noStroke();
    beginShape(QUADS);
    //front face
    vertex(-w/2 + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, h + shiftY, -d/2 + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, -d/2 + shiftZ); 

    //back face
    vertex(-w/2 + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(w + shiftX, h + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, d + shiftZ);

    //left face
    vertex(-w/2 + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(-w/2 + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, -d/2 + shiftZ); 

    //right face
    vertex(w + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(w + shiftX, h + shiftY, d + shiftZ); 
    vertex(w + shiftX, h + shiftY, -d/2 + shiftZ); 

    //top face
    vertex(-w/2 + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, -h/2 + shiftY, d + shiftZ); 

    //bottom face
    vertex(-w/2 + shiftX, h + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, h + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, h + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, d + shiftZ); 

    endShape(); 

/**
    //add some rotation to each box for pizazz.
    rotateY(radians(1));
    rotateX(radians(1));
    rotateZ(radians(1));
    */
  }
}
