/**
* cubescape
* binarymillenium
*
*/

import processing.opengl.*;

final int MAP_X = 30;
final int MAP_Y = 20;
final float CSIZE = 3.5;

Cube[][] ground = new Cube[MAP_X][MAP_Y];
Cube[][] clouds = new Cube[MAP_X][MAP_Y];


void setup_cubes(Cube[][] cubes,float y_off, color c) {
      for (int i = 0; i < MAP_X; i++) {
  for (int j = 0; j < MAP_Y; j++) {

    
    cubes[i][j] = new Cube(0.66*CSIZE, 1.5*CSIZE,0.66*CSIZE,
                          i*CSIZE - CSIZE*MAP_X/2, y_off, -j*CSIZE+80);
    
  cubes[i][j].c =c;
  }} 
}

void setup() {
  
  frameRate(30);
   size(640,480, OPENGL);
    //size(640,480, P3D);
  background(0); 
  
  //frustum(-width/2, width/2, -height/2, height/2, -100, 500.0);
  float fov = PI/3.0;
float cameraZ = (height/2.0) / tan(PI * fov / 360.0);
perspective(fov, float(width)/float(height), 
            0.1, 200);
  
  
  setup_cubes(ground,25, color(10,2550,0));
  setup_cubes(clouds,-19, color(255,255,255));

  
  update_map();

}

float t = 0.0;
int skipx = 0;
int skipy = 0;
float movex = 0;
float movex_clouds=0;

void update_map() {
  
  movex+= 0.05;
  movex_clouds+= 0.1;
  
  final int MAXSKIP = 1;
   final float div = 9.0;
      final float div2 = 19.0;
   
  for (int i = skipx; i < MAP_X; i+=MAXSKIP) {
  for (int j = skipy; j < MAP_Y; j+=MAXSKIP) {
    
    float field_height = noise((float)i/div+movex,(float)j/div,t);
    field_height = 0.6*field_height + 0.4* noise((float)i/div2+movex,(float)j/div2,t);
    
    field_height = CSIZE*2.0 +15.0*CSIZE*field_height;
    
    ground[i][j].h = CSIZE +field_height;
    
    ///
    
    field_height = noise((float)(i+1000)/div+movex_clouds,(float)j/div,2*t);
    field_height = 0.6*field_height + 0.4*noise((float)i/div2 + movex,(float)j/div2,2*t);
    
    field_height =  20.0*CSIZE*(field_height - 0.5);
    
    clouds[i][j].h = field_height;
    
  }}  
  
  t+=0.003;
  
  skipx = (int)random(MAXSKIP);
  skipy = (int)random(MAXSKIP);
}

void draw(){
  background(0); 
  //background(color(30,10,255));
  
  /// draw sky
  
  float s = 500;
  float d = -500;
    beginShape(QUADS);

    fill(color(200,200,255));
    vertex(-s,d,s); 
    vertex(-s,d,-s);
    fill(color(30,10,255));
    vertex( s,d,-s);
    vertex( s,d,s);
    endShape();


  //set up some different colored lights
  pointLight(255, 255, 255, 100, -500, -500); 
  
   pointLight(95, 95, 95, 0, 500, 0); 
  //pointLight(255, 255, 60, -65, -60, -150);

  //raise overall light in scene 
  ambientLight(150, 150, 150); 
  
  // translate(width/2, height/2 + height/60.0  + mouseY/180.0, width/2+mouseX/50.0);
  translate(width/2, height/2 + height/60.0 , width/2);
  
  for (int i = 0; i < MAP_X; i++) {
  for (int j = 0; j < MAP_Y; j++) {
    ground[i][j].drawCube();
    clouds[i][j].drawCube();
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
  
  color c;

  //constructor
  Cube(float w, float h, float d, 
       float shiftX, float shiftY, float shiftZ){
    this.w = w;
    this.h = h;
    this.d = d;
    this.shiftX = shiftX;
    this.shiftY = shiftY;
    this.shiftZ = shiftZ;
    
    c = color(255,255,255);
  }

  /*main cube drawing method, which looks 
   more confusing than it really is. It's 
   just a bunch of rectangles drawn for 
   each cube face*/
  void drawCube(){
    
    if (h > 0) {
    fill(c);
    stroke(color(red(c)/2,green(c)/2,blue(c)/2));
   // noStroke();
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
    
    }

/**
    //add some rotation to each box for pizazz.
    rotateY(radians(1));
    rotateX(radians(1));
    rotateZ(radians(1));
    */
  }
}
