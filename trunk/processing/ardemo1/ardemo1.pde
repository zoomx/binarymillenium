

 import processing.opengl.*;

PImage baseImage;
PImage fbImage = createImage(100,100, RGB);
  
float rotx = PI/4;
float roty = PI/4;

void setup() {
  

   textureMode(NORMALIZED);
   
  fbImage = loadImage("bm.jpg");
  baseImage = createImage(600,600,  RGB);
  baseImage.copy(fbImage, 0,0,fbImage.width, fbImage.height, 0,0, baseImage.width, baseImage.height);
 
  size(baseImage.width,baseImage.height, OPENGL); 
 
 /*
 baseImage.loadPixels();
   for (int i = 0; i < baseImage.width*baseImage.height; i++) {
     color c1 = baseImage.pixels[i];
      baseImage.pixels[i] = color(red(c1),blue(c1),green(c1),28);
  }
  
  */

 
 frameRate(10);
}

int srcX = 0;
int srcY = 0;

void mouseDragged() {
  float rate = 0.003;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
}

void draw() { 
  
  /*
  fbImage.copy(baseImage,srcX,srcY,fbImage.width, fbImage.height, 0,0, fbImage.width, fbImage.height);
    
  //fbImage.loadPixels();
  
  
 
 

  if (mousePressed && (mouseButton == RIGHT)) {
     srcX = mouseX;
    srcY = mouseY; 
  } 
 
 if (mousePressed && (mouseButton == LEFT)) {
     baseImage.blend(fbImage,0,0,fbImage.width, fbImage.height, mouseX-fbImage.width,mouseY-fbImage.height, fbImage.width, fbImage.height, BLEND);
  
  }

  
  
  image(baseImage,0,0,width,height);
  */
  
  background(0);
  image(baseImage,0,0,width,height);
  
    noStroke();
  translate(width/2.0, height/2.0, 200);
  rotateX(rotx);
  rotateY(roty);
  scale(90);
  TexturedCube(baseImage);
  
   
  loadPixels();
  arraycopy(pixels,baseImage.pixels);
  baseImage.updatePixels();
  
}


void TexturedCube(PImage tex) {
  beginShape(QUADS);
  texture(tex);

  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)
  
  // +Z "front" face
  vertex(-1, -1,  1, 0, 0);
  vertex( 1, -1,  1, 1, 0);
  vertex( 1,  1,  1, 1, 1);
  vertex(-1,  1,  1, 0, 1);

  // -Z "back" face
  vertex( 1, -1, -1, 0, 0);
  vertex(-1, -1, -1, 1, 0);
  vertex(-1,  1, -1, 1, 1);
  vertex( 1,  1, -1, 0, 1);

  // +Y "bottom" face
  vertex(-1,  1,  1, 0, 0);
  vertex( 1,  1,  1, 1, 0);
  vertex( 1,  1, -1, 1, 1);
  vertex(-1,  1, -1, 0, 1);

  // -Y "top" face
  vertex(-1, -1, -1, 0, 0);
  vertex( 1, -1, -1, 1, 0);
  vertex( 1, -1,  1, 1, 1);
  vertex(-1, -1,  1, 0, 1);

  // +X "right" face
  vertex( 1, -1,  1, 0, 0);
  vertex( 1, -1, -1, 1, 0);
  vertex( 1,  1, -1, 1, 1);
  vertex( 1,  1,  1, 0, 1);

  // -X "left" face
  vertex(-1, -1, -1, 0, 0);
  vertex(-1, -1,  1, 1, 0);
  vertex(-1,  1,  1, 1, 1);
  vertex(-1,  1, -1, 0, 1);

  endShape();
}

