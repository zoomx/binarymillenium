

 import processing.opengl.*;
 
 import javax.media.opengl.*;


int vtWidth = 60;

boolean feedbackImage = false;
boolean perturbMode = false;
boolean redblockMode = true;

PImage baseImage;
PImage fbImage = createImage(100,100, RGB);
  
float rotx = 0;//PI/4;
float roty = 0;//PI/4;

float roffsetv = 0;
float roffset = 0;

int baseX = 2;
int baseY = 2;

float radius = 0.3; 
float radiusv = 0.0; 

int xdupe = 2;
int ydupe = 2;


//GL gl;


class block {
  
 float x;
float y;
float z;
  
  color col;
  
  void draw() {
    
    float tx,ty,tz;
    float angle = x/(float)width*2*PI;
    
   // tx = (radius*1.5+z)*cos(angle+roffset);
   // ty = y;
   // tz = (radius*1.5+z)*sin(angle+roffset);  
  
    pushMatrix();
    
    fill(col);
    rotateY(angle);
    translate(radius*1.5*92,0,0);
    rotateY(PI/2);
    float d = 20.0;
    rect(0,y,d,d);
    
    popMatrix();  
    
  }
}

final int NUM_BLOCKS = 10;
block allBlocks[];

class Prx {
  
  float x;
  float y;
  float z;
  
  float vx;
  float vy;
  float vz;
  
  float fz;
  
  
  /// transformed coords
  float tx;
  float ty;
  float tz;
  
  void update(float angle) {
   
   vz += fz;
   fz = 0;
   
   z += vz;
   
   vz *= 0.99;
    
   

   
   tx = (radius+z) *cos(angle+roffset);
   ty = y;
   tz = (radius+z) *sin(angle+roffset);
   
    
  }
  
};

Prx vt[][] = new Prx[vtWidth][vtWidth];

void particlesUpdate() {
 
 for (int i = 0; i < vtWidth; i++) {
  for (int j = 0; j< vtWidth; j++) {
    
    int il = i-1;
    if (il < 0) il += vtWidth; 
    int ir = i+1;
    if (ir > vtWidth -1) ir -= vtWidth;
    
    int jl = j-1;
    if (jl < 0) jl += vtWidth;
    int jr = j+1;
    if (jr > vtWidth -1) jr -= vtWidth;
    
    vt[i][j].fz += ((vt[il][j].z - vt[i][j].z) +
                    (vt[ir][j].z - vt[i][j].z) + 
                    (vt[i][jl].z - vt[i][j].z) +
                    (vt[i][jr].z - vt[i][j].z)) * 0.01;
    
  }} 
  
  
   for (int i = 0; i < vtWidth; i++) {
  for (int j = 0; j< vtWidth; j++) {
    
    vt[i][j].update(2*PI*i/(vtWidth-1));
  }}
}



void setup() {
  
  allBlocks = new block[NUM_BLOCKS];
  
  for (int i = 0; i < allBlocks.length; i++) {
    allBlocks[i] = new block();  
    
    allBlocks[i].x = (int)(random(0,width/20))*20;
    allBlocks[i].y = (int)(random(0,height/20))*20-height/2;
    
    allBlocks[i].col = color(255,0,0);
  }
  
   for (int i = 0; i < vtWidth; i++) {
   for (int j = 0;j < vtWidth; j++) { 
      
     vt[i][j] = new Prx();
     
     vt[i][j].x = (float)i/(float)(vtWidth-1) - 0.5;
     vt[i][j].y = (float)j/(float)(vtWidth-1) - 0.5;
     vt[i][j].z = 0.0;
  }}
  
  textureMode(NORMALIZED);
   
  fbImage = loadImage("bm.jpg");
  baseImage = createImage(width,height,  RGB);
  baseImage.copy(fbImage, 0,0,fbImage.width, fbImage.height, 0,0, baseImage.width, baseImage.height);
 
  //size(baseImage.width,baseImage.height, OPENGL); 
  size(800,600, P3D); // texture feedback is way faster in p3d than opengl 

 // PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
 // gl = pgl.gl; 
  
 
 /*
 baseImage.loadPixels();
   for (int i = 0; i < baseImage.width*baseImage.height; i++) {
     color c1 = baseImage.pixels[i];
      baseImage.pixels[i] = color(red(c1),blue(c1),green(c1),28);
  }
  
  */

 
 //frameRate(10);
}

int srcX = 0;
int srcY = 0;

float distance = 410;



 boolean rotateMode = false;

void mouseDragged() {
  
  
  if (perturbMode) {
    
   if ( (mouseButton == RIGHT)) {
     srcX = mouseX;
     srcY = mouseY;
   }
   
    if (lightMode) {
      lx += (pmouseX - mouseX)*0.5;
      ly += (mouseY - pmouseY)*0.5;
    } else {
    int x = (vtWidth-1)*mouseX/width;
    int y = (vtWidth-1)*mouseY/width;
    
    if ((x >=0) && (y >=0) && (x< vtWidth) && ( y < vtWidth)) {
      
      if (mouseButton == RIGHT) {
        vt[x][y].fz += 0.008;
      }
      if (mouseButton == LEFT) {
        vt[x][y].fz -= 0.006;
      }
    }
    
  } 
  
  } else  if (rotateMode) {
    if (mouseButton == LEFT) {
  float rate = 0.003;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
  
    } else {
    distance += (pmouseY-mouseY) * 1;
    }
  
  } else {
    
    baseY += (mouseY-pmouseY) * 0.2;
    
    baseX += (mouseX-pmouseX) * 0.2;
    
  }
}



boolean lightMode = false;
float lx,ly;

void keyPressed() {
  
    if (key == 'p') {
     perturbMode = !perturbMode; 
      
    }
  
   if (key == 'r') {
     rotateMode = !rotateMode; 
    
  }
  if (key == 'f') {
     feedbackImage = !feedbackImage; 
    
  }
   if (key == 'l') {
     
    lightMode = !lightMode; 
   }
   
 if (key == 'a') {
    roffsetv += PI/2000;
 } 
  
 if (key == 'd') {
    roffsetv -= PI/1910;
 } 
 
 if (key == 'j') {
   radiusv += 0.0001;
 }
 
 if (key == 'l') {
   radiusv -= 0.00008;
 }
 
}

void draw() { 
  
  radius += radiusv;
  radiusv *= 0.99;
  roffset += roffsetv;
   roffsetv *= 0.999;
  
  background(0);
  
  
  
  
  particlesUpdate();
   
  /*
  fbImage.copy(baseImage,srcX,srcY,fbImage.width, fbImage.height, 0,0, fbImage.width, fbImage.height);
    
  //fbImage.loadPixels();
 
 if (mousePressed && (mouseButton == LEFT)) {
     baseImage.blend(fbImage,0,0,fbImage.width, fbImage.height, mouseX-fbImage.width,mouseY-fbImage.height, fbImage.width, fbImage.height, BLEND);
  
  }
I*/

  background(255);
  image(baseImage,-baseX,-baseY,width+baseX*2,height+baseY*2);
  
  
  
 
  //image(baseImage,0,0,width,height);
  
  // gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
   
  noStroke();
  translate(width/2.0, height/2.0, distance);
  
  ambientLight(220, 220, 220);
  pointLight(150, 150, 150, // Color
             lx, ly, 0); // Position
  
   rotateX(rotx);
  rotateY(roty);
  pushMatrix();
 
  scale(100);
  // texture repeating doesn't work in processing?
  TexturedCube(baseImage,1,1); // 10,10);// width/baseImage.width, height/baseImage.height);
  popMatrix();
 
  
  for (int i = 0; i < allBlocks.length; i++) {
    allBlocks[i].draw();  
  }
 
 
 if (feedbackImage) { 
  loadPixels();
  
  
  if (false) {
  /// copy full image
  
  int dx = width/baseImage.width;
  int dy = height/baseImage.height;
  
  for (int i = 0; i < width; i+= dx) {
  for (int j = 0; j < height; j+= dy) {
     
      int bpixind = (i/dx)*baseImage.height+(j/dy);   
      int pixind = i*height + j;
      
      if ((pixind < width*height) && (bpixind < baseImage.width*baseImage.height))
        baseImage.pixels[bpixind] = pixels[pixind];
  }}
  
  
  
  if (false) {
  for (int i = 0; i < baseImage.width; i++) {
  for (int j = 0; j < baseImage.height; j++) {
     
      int bpixind = i*baseImage.height+j;   
      int pixind = (srcX+i)*height + (srcY+j);
      
      if ((pixind < width*height) && (bpixind < baseImage.width*baseImage.height))
        baseImage.pixels[bpixind] = pixels[pixind];
  }}
}
  
  } else {
    arraycopy(pixels,baseImage.pixels); // too slow at high res
  }
  baseImage.updatePixels();
  
}
  
  
}


/////////////////////////////////////////////////////////////////////

void TexturedCube(PImage tex,int tx, int ty) {
  
  fill(255);
  beginShape(QUADS);
  texture(tex);
//  gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT);  
//gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_REPEAT); 

  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)
  
  //stroke(255,255,255);
  
  
  for (int i = 0; i < vtWidth-1; i++) {
  for (int j = 0; j < vtWidth-1; j++) {  
    
    if (i < vtWidth/2) {
     vertex(vt[i]  [j].tx, vt[i]  [j].ty,  vt[i]  [j].tz ,       (float)i/(float)(vtWidth/2-1),      (float)j/(float)(vtWidth-1) );
     vertex(vt[i+1][j].tx, vt[i+1][j].ty,  vt[i+1][j].tz ,       (float)(i+1)/(float)(vtWidth/2-1),      (float)j/(float)(vtWidth-1) );
     vertex(vt[i+1][j+1].tx, vt[i+1][j+1].ty,  vt[i+1][j+1].tz , (float)(i+1)/(float)(vtWidth/2-1),  (float)(j+1)/(float)(vtWidth-1) );
     vertex(vt[i]  [j+1].tx, vt[i]  [j+1].ty,  vt[i]  [j+1].tz , (float)i/(float)(vtWidth/2-1),  (float)(j+1)/(float)(vtWidth-1) );
     
    } else {
     /// draw reversed 
     vertex(vt[i]  [j].tx, vt[i]  [j].ty,  vt[i]  [j].tz ,       (float)(vtWidth-i)/(float)(vtWidth/2-1),      (float)j/(float)(vtWidth-1) );
     vertex(vt[i+1][j].tx, vt[i+1][j].ty,  vt[i+1][j].tz ,       (float)(vtWidth-i-1)/(float)(vtWidth/2-1),      (float)j/(float)(vtWidth-1) );
     vertex(vt[i+1][j+1].tx, vt[i+1][j+1].ty,  vt[i+1][j+1].tz , (float)(vtWidth-i-1)/(float)(vtWidth/2-1),  (float)(j+1)/(float)(vtWidth-1) );
     vertex(vt[i]  [j+1].tx, vt[i]  [j+1].ty,  vt[i]  [j+1].tz , (float)(vtWidth-i)/(float)(vtWidth/2-1),  (float)(j+1)/(float)(vtWidth-1) );
     
    }
    
   }}
  // +Z "front" face
  
  /*
  vertex(-1, -1,  1, 0, 0);
  vertex( 1, -1,  1, tx, 0);
  vertex( 1,  1,  1, tx, ty);
  vertex(-1,  1,  1, 0, ty);

  // -Z "back" face
  vertex( 1, -1, -1, 0, 0);
  vertex(-1, -1, -1, tx, 0);
  vertex(-1,  1, -1, tx, ty);
  vertex( 1,  1, -1, 0, ty);

  // +Y "bottom" face
  vertex(-1,  1,  1, 0, 0);
  vertex( 1,  1,  1, tx, 0);
  vertex( 1,  1, -1, tx, ty);
  vertex(-1,  1, -1, 0, ty);

  stroke(255,255,20);
  // -Y "top" face
  vertex(-1, -1, -1, 0, 0);
  vertex( 1, -1, -1, tx, 0);
  vertex( 1, -1,  1, tx, ty);
  vertex(-1, -1,  1, 0, ty);

  // +X "right" face
  vertex( 1, -1,  1, 0, 0);
  vertex( 1, -1, -1, tx, 0);
  vertex( 1,  1, -1, tx, ty);
  vertex( 1,  1,  1, 0, ty);

  // -X "left" face
  vertex(-1, -1, -1, 0, 0);
  vertex(-1, -1,  1, tx, 0);
  vertex(-1,  1,  1, tx, ty);
  vertex(-1,  1, -1, 0, ty);
*/
  endShape();
}

