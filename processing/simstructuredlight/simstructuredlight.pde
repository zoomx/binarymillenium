/**
 * binarymillenium
 GPL v3.0
November 2009
 
toxi geom library
http://toxiclibs.googlecode.com/files/toxiclibscore-0014.zip
*/

import javax.media.opengl.*;
import processing.opengl.*;
import com.sun.opengl.util.texture.*;  
import toxi.geom.*;

GL gl;

Texture tex[] = new Texture[3];
float rotx = PI/4;
float roty = PI/4;

String imnames[] = new String[3]; 
int imind = 0;

/// the position and orientation of the projector
Matrix4x4 projector;
Vec3D projPos;

Vec3D vs[] = new Vec3D[8];

Matrix4x4 rotateAbs(Matrix4x4 rot, float df, Vec3D axis) {
  Quaternion quat = new Quaternion(cos(df/2), 
                          new Vec3D(axis.x*sin(df/2),
                                    axis.y*sin(df/2),
                                    axis.z*sin(df/2)) );
                                    
  rot = rot.multiply(quat.getMatrix());
  return rot;
}
    
void setup() 
{
  size(480, 640, OPENGL);
  
  imnames[0] = "i1.png";
  imnames[1] = "i2.png";
  imnames[2] = "i3.png";
  
  float sc = 1;
  vs[0] = new Vec3D(-sc, -sc,  sc);  
  vs[1] = new Vec3D( sc, -sc,  sc);
  vs[2] = new Vec3D( sc,  sc,  sc);
  vs[3] = new Vec3D(-sc,  sc,  sc);
  
  vs[4] = new Vec3D(-sc, -sc,  -sc);  
  vs[5] = new Vec3D( sc, -sc,  -sc);
  vs[6] = new Vec3D( sc,  sc,  -sc);
  vs[7] = new Vec3D(-sc,  sc,  -sc);
  
  gl=((PGraphicsOpenGL)g).gl;
   
  for (int i = 0; i < 3; i++) { 
    try { 
      tex[i] = TextureIO.newTexture(new File(dataPath(imnames[i])),true); 
    }
    catch(Exception e) { println(e); } 
    
    tex[i].setTexParameteri(GL.GL_TEXTURE_WRAP_R,GL.GL_REPEAT);    
    tex[i].setTexParameteri(GL.GL_TEXTURE_WRAP_S,GL.GL_REPEAT);
    tex[i].setTexParameteri(GL.GL_TEXTURE_WRAP_T,GL.GL_REPEAT);
  }
 

  
  textureMode(NORMALIZED);
  fill(255);
  stroke(color(44,48,32));
  
  
  float angle = PI/2;
  projPos = new Vec3D(0,0,0);
  
  /// point at the origin
  //Vec3D dirV = new Vec3D(0,0,0).sub(projPos).getNormalized();
  //Quaternion dir = new Quaternion( cos(angle/2), 
   //                   new Vec3D(dirV.x*sin(angle/2),dirV.y*sin(angle/2),dirV.z*sin(angle/2)));
                      
  //projector= dir.getMatrix();
  projector = new Matrix4x4(1,0,0,0,
                            0,1,0,0,
                            0,0,1,0,
                            0,0,0,1);
  
}

void keyPressed() {
  float sc = 0.1;
  if (key == 'a') {
    projPos = projPos.add(sc,0,0);
  }  
  if (key == 'd') {
    projPos = projPos.sub(0.5*sc,0,0);
  }  
  if (key == 'q') {
    projPos = projPos.add(0,0,sc);
  }  
  if (key == 'z') {
    projPos = projPos.sub(0,0,0.5*sc);
  }  
  if (key == 'w') {
    projPos = projPos.add(0,sc,0);
  }  
  if (key == 's') {
    projPos = projPos.sub(0,0.5*sc,0);
  }  
  
  /// reset
  if (key == 'r') {
    projPos = new Vec3D(0,0,0);
      projector = new Matrix4x4(1,0,0,0,
                            0,1,0,0,
                            0,0,1,0,
                            0,0,0,1);
                            
     rotx = PI/4;
    roty = PI/4;
  }  
  
  if (key == 'j') {
    projector = rotateAbs(projector, sc*PI/10, new Vec3D(0,1,0));
  }
  if (key == 'k') {
    projector=rotateAbs(projector, -sc*PI/20, new Vec3D(0,1,0));
  }
  if (key == 'u') {
    projector = rotateAbs(projector, sc*PI/10, new Vec3D(0,0,1));
  }
  if (key == 'm') {
    projector = rotateAbs(projector, -sc*PI/20, new Vec3D(0,0,1));
  }
  if (key == 'o') {
    projector = rotateAbs(projector, sc*PI/10, new Vec3D(1,0,0));
  }
  if (key == 'l') {
    projector = rotateAbs(projector, -sc*PI/20, new Vec3D(1,0,0));
  }
  
  if (key == 'h') {
    drawLine = !drawLine; 
  }
  
  if (key == 'y') {
    switchTex = true;
  }
  
  if (key == 'g') {
    saveIm = true;
  }
  
}

///////////////////////////////////////////////

boolean switchTex = false;
boolean drawLine = true;
boolean saveIm = false;

void draw() {
  
  /// only do this synchronously with drawing
  if (switchTex) {
    imind++;
    imind %= 3;  
    /*
    try { tex  = TextureIO.newTexture(new File(dataPath(imnames[imind])),true); }
    catch(Exception e) { println(e); } 
    */
    println("using texture " + imnames[imind]); 
    
  }
  switchTex = false;
  
  background(0);
  noStroke();
  
  translate(width/2.0, height/2.0, -100);
    rotateZ(PI/2); 
rotateY(-rotx);     
  rotateX(roty);
  

  scale(90);
  drawObject(tex[imind]);
  
  if (saveIm) {
    String name = "phase" + (imind +1) + ".jpg";
    saveFrame(name);
    println("saving " + name);
  } 
  saveIm = false;
  
  if (drawLine) {
    stroke(255,255,255);
    line(projPos.x,projPos.y, projPos.z, 
         projPos.x+15.0*(float)projector.matrix[2][0],
         projPos.y+15.0*(float)projector.matrix[2][1], 
         projPos.z+15.0*(float)projector.matrix[2][2]);
  }
  
 
}

///////////////////////////////////////////////////

void vertexProj(Vec3D v,boolean verbose) {
  
  Vec3D rel = v.sub(projPos);

  Vec3D uv = projector.apply(rel);
  
  uv = uv.scale(0.1);
  
  //vertex(v.x, v.y, v.z, pt.x*10, pt.y *10);
  gl.glTexCoord2f(uv.x,uv.y);
  gl.glVertex3f(v.x,v.y,v.z);
  
  if (verbose) println(uv.x + " " + uv.y);
}

void vertexProj(Vec3D v) {
  vertexProj(v,false);
}

/// draw an object with texture projected onto it
void drawObject(Texture tex) {
  
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  
  GL gl = pgl.beginGL();  
   
  tex.bind();  
  tex.enable();  
   
  // beginShape(QUADS);
  // texture(tex);
 
  gl.glBegin(GL.GL_QUADS);
  //gl.glNormal3f( 0.0f, 0.0f, 1.0f); 
  
  gl.glTexParameteri( GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT );
  gl.glTexParameteri( GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_REPEAT );
  gl.glTexParameteri( GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_R, GL.GL_REPEAT );
  
  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)
  
  // +Z "front" face
  for (int i = 0; i < 4; i++) {
    vertexProj(vs[i],false);
  }
  
  for (int i = 4; i < 8; i++) {
    vertexProj(vs[i]);
  }

  int i;
  i = 0; vertexProj(vs[i]);
  i = 1; vertexProj(vs[i]);
  i = 5; vertexProj(vs[i]);
  i = 4; vertexProj(vs[i]);
  
  i = 2; vertexProj(vs[i]);
  i = 3; vertexProj(vs[i]);
  i = 7; vertexProj(vs[i]);
  i = 6; vertexProj(vs[i]);
  
  i = 0; vertexProj(vs[i]);
  i = 4; vertexProj(vs[i]);
  i = 7; vertexProj(vs[i]);
  i = 3; vertexProj(vs[i]);
  
  i = 1; vertexProj(vs[i]);
  i = 2; vertexProj(vs[i]);
  i = 6; vertexProj(vs[i]);
  i = 5; vertexProj(vs[i]);
  
  gl.glEnd();
  //println();
  //endShape();

  tex.disable();
  pgl.endGL();
}

void mouseDragged() {
  float rate = 0.01;
  rotx += (pmouseY-mouseY) * rate;
  roty += (mouseX-pmouseX) * rate;
}
