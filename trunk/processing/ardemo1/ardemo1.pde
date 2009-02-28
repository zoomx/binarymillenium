

 import processing.opengl.*;
 
 import javax.media.opengl.*;


int vtwidth = 80;
float vt[][][] = new float[vtwidth][vtwidth][3];

PImage baseImage;
PImage fbImage = createImage(100,100, RGB);
  
float rotx = 0;//PI/4;
float roty = 0;//PI/4;

GL gl;

void setup() {
  
   for (int i = 0; i < vtwidth; i++) {
   for (int j = 0;j < vtwidth; j++) {  
     vt[i][j][0] = (float)i/(float)(vtwidth-1) - 0.5;
     vt[i][j][1] = (float)j/(float)(vtwidth-1) - 0.5;
     vt[i][j][2] = 0.0;
  }}
  
  textureMode(NORMALIZED);
   
  fbImage = loadImage("bm.jpg");
  baseImage = createImage(100,100,  RGB);
  baseImage.copy(fbImage, 0,0,fbImage.width, fbImage.height, 0,0, baseImage.width, baseImage.height);
 
  //size(baseImage.width,baseImage.height, OPENGL); 
  size(600,600, OPENGL); 

  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
  gl = pgl.gl; 
  
 
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

float distance = 440;

/*
void mouseDragged() {
  
  if (mouseButton == LEFT) {
  float rate = 0.003;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
  
  } else {
    distance += (pmouseY-mouseY) * 1;
  }
}

*/



void draw() { 
  
   if (mousePressed && (mouseButton == RIGHT)) {
     srcX = mouseX;
     srcY = mouseY;
   }
  
  if (mousePressed) { 
    int x = (vtwidth-1)*mouseX/width;
    int y = (vtwidth-1)*mouseY/width;
    
    if ((x< vtwidth) && ( y < vtwidth)) {
      
      if (mouseButton == RIGHT) {
        vt[x][y][2] = vt[x][y][2] + 0.004;
      }
      if (mouseButton == LEFT) {
        vt[x][y][2] = vt[x][y][2] - 0.004;
      }
    }
  } 
  
   
  /*
  fbImage.copy(baseImage,srcX,srcY,fbImage.width, fbImage.height, 0,0, fbImage.width, fbImage.height);
    
  //fbImage.loadPixels();
 
 if (mousePressed && (mouseButton == LEFT)) {
     baseImage.blend(fbImage,0,0,fbImage.width, fbImage.height, mouseX-fbImage.width,mouseY-fbImage.height, fbImage.width, fbImage.height, BLEND);
  
  }

  image(baseImage,0,0,width,height);
  */
  
  background(255);
 
  //image(baseImage,0,0,width,height);
  
   gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
   
   noStroke();
  translate(width/2.0, height/2.0, distance);
  rotateX(rotx);
  rotateY(roty);
  scale(90);
  // texture repeating doesn't work in processing?
  TexturedCube(baseImage,1,1); // 10,10);// width/baseImage.width, height/baseImage.height);
  
 
 
 if (false) { 
  loadPixels();
  
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
  
  //arraycopy(pixels,baseImage.pixels); // too slow at high res
  baseImage.updatePixels();
  
}
  
  
}


void TexturedCube(PImage tex,int tx, int ty) {
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
  
  for (int i = 0; i < vtwidth-1; i++) {
  for (int j = 0; j < vtwidth-1; j++) {  
     vertex(vt[i]  [j]  [0], vt[i]  [j]  [1],  vt[i]  [j]  [2] ,     (float)i/(float)(vtwidth-1),      (float)j/(float)(vtwidth-1) );
     vertex(vt[i+1][j]  [0], vt[i+1][j]  [1],  vt[i+1][j]  [2] , (float)(i+1)/(float)(vtwidth-1),      (float)j/(float)(vtwidth-1) );
     vertex(vt[i+1][j+1][0], vt[i+1][j+1][1],  vt[i+1][j+1][2] , (float)(i+1)/(float)(vtwidth-1),  (float)(j+1)/(float)(vtwidth-1) );
     vertex(vt[i]  [j+1][0], vt[i]  [j+1][1],  vt[i]  [j+1][2] ,     (float)i/(float)(vtwidth-1),  (float)(j+1)/(float)(vtwidth-1) );
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

