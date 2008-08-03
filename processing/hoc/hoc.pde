/**
 *
 * (c) binarymillenium 2008
 * Licensed under the GNU GPL latest version
 */

import processing.opengl.*;

boolean useSprings = false;
boolean drawScreen = false;

PImage tx[]; 

int counter =1;

boolean doublePoints = false;

final int SZX = 120;
final int SZY = 120;

///////////////////////////////////////////////////////

void setup(){

  size(640,480, OPENGL);

  strokeWeight(1);

  update(counter);

}

void update(int counter) {

  print(counter + " " + mx + " " + my+ " \n");

  String[] raw = loadStrings(counter+".csv");


  tx = cloudToBin(raw,  SZX,SZY);

  /*
  if (counter == 1) {
   print(minx + ", " + maxx + ", " + miny + " " + maxy + ", " + minz + " " + maxz + "\n");
   }
   */

  /// maxi is 255
  //print(mini + " " + maxi + "\n");



  /*
  if (counter == 1) {
   for (int i = 0; i < SZX; i++) {
   for (int j = 0; j < SZY; j++) {
   
   sp[i+SZX][j][0] = (float)i/(float)SZX * (maxx-minx) + minx - (maxx-minx)/2;
   sp[i+SZX][j][1] = (float)j/(float)SZY * (maxy-miny) + miny - (maxy-miny)/2;
   sp[i+SZX][j][2] = 0;
   
   sp[i][j][0] = sp[i+SZX][j][0];
   sp[i][j][1] = random(1.0);//sp[i+SZX][j][1];
   sp[i][j][2] = 0;
   
   }
   }
   }
   
   */

  //print ("assign z-depth points " + counter + "\n");


  //print ("update finished " + counter + "\n");


  //print ("starting spring creation " + counter + "\n");

  if (useSprings) {
    int ind = 0;
    for (int i = 0; i < SZX-1; i++) {
      for (int j = 0; j < SZY-1; j++) {

        ///distances to adjacent points
        float l1 = dist(sp[SZX+i][j][0],     sp[SZX+i][j][1],     sp[SZX+i][j][2], 
        sp[SZX+i+1][j+1][0], sp[SZX+i+1][j+1][1], sp[SZX+i+1][j+1][2]);
        float l2 = dist(sp[SZX+i][j][0],     sp[SZX+i][j][1],     sp[SZX+i][j][2], 
        sp[SZX+i+1][j][0],   sp[SZX+i+1][j][1],   sp[SZX+i+1][j][2]);
        float l3 = dist(sp[SZX+i][j][0],     sp[SZX+i][j][1],     sp[SZX+i][j][2], 
        sp[SZX+i][j+1][0],   sp[SZX+i][j+1][1],   sp[SZX+i][j+1][2]);

        if (counter == 1) {
          float kd = 1e-1;
          float kv = 1e-2;
          allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+1, j+1, l1, kd, kv ));
          allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+1, j,   l2, kd, kv ));
          allSprings = (Spring[]) append(allSprings, new Spring(i, j, i,   j+1, l3, kd, kv ));

          allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+SZX,   j, 0 , kd/3.0, kv/3.0));
        } 
        else {
          allSprings[ind].len = l1;
          ind +=1;
          allSprings[ind].len = l2;
          ind +=1;
          allSprings[ind].len = l3;
          ind +=2; /// add extra one for skipped over target point
        }
      }
    }

  }
}




float oldmx = 0;
float oldmy = 0;

/// straight on
//float my = 316;
//float mx = 286;

float my = 240;
float mx = 151;

void draw() {

  background(0);


  if (drawScreen) {
    pushMatrix();

    if (mousePressed) {


      mx += (mouseX -oldmx)/3;
      my += (mouseY- oldmy)/3;  

    } 

    oldmx = mouseX;
    oldmy = mouseY;


    translate(width/2, height/2); 
    translate(80,40,450-my/1.0);

    float div = 100;

    /// autorotate
    mx += div*(PI/2.0)/2000.0; 

    rotateY(-(width/div)/2 + mx/div);

    pointLight(255, 255, 255, 20, 10, 250);
    //lights();

    noStroke();
    //stroke(255);



    textureMode(NORMALIZED);

    /*
 beginShape();
     texture(tx);
     vertex(0, 0, 0, 0);
     vertex(width, 0, 1.0, 0);
     vertex(width, height, 1.0, 1.0);
     vertex(0, height, 0, 1.0);
     endShape();
     */


    for (int i = 0; i < SZX-1; i++) {
      beginShape(TRIANGLE_STRIP);
      texture(tx[0]);
      for (int j = 0; j < SZY-1; j++) {

        fill(250);
        //fill(f[i][j]);
        //front face
        // beginShape(TRIANGLES);

        boolean useNormal = true;

        float n1[] = new float[3];
        float n2[]= new float[3];
        float n3[]= new float[3];
        float n4[]= new float[3];

        if (useNormal) {
          n1 = getNormal(i,j);
          n2 = getNormal(i,j+1);
          n3 = getNormal(i+1,j);
          n4 = getNormal(i+1,j+1);
        }

        float u = (float)i/(float)SZX;
        float v = (float)j/(float)SZY;
        float du = 1.0/(float)SZX;
        float dv = 1.0/(float)SZY;

        if (useNormal) normal( n1[0], n1[1], n1[2]);
        vertex( sp[i][j][0],     sp[i][j][1],    sp[i][j][2],   u, v); 
        if (useNormal) normal( n2[0], n2[1], n2[2]);
        vertex( sp[i][j+1][0],   sp[i][j+1][1],  sp[i][j+1][2], u, v+dv);
        if (useNormal) normal( n3[0], n3[1], n3[2]);
        vertex( sp[i+1][j][0],   sp[i+1][j][1],  sp[i+1][j][2], u+du, v);
        if (useNormal) normal( n4[0], n4[1], n4[2]);
        vertex( sp[i+1][j+1][0], sp[i+1][j+1][1],sp[i+1][j+1][2], u+du, v+dv);
        //endShape();

      }
      endShape(); 
    }


    popMatrix();
  }

  counter = counter+1;
  update(counter);



  if (useSprings) {
    updateSprings();
    updatePos();
  }


  // saveFrame("frames/hoc_######.jpg");

}


//////////////////////////////////////////////////////////////


float[] getNormal(int i, int j) {

  float r[] = new float[3];
  r[0] = 1.0;

  float cp[][] = new float[0][3];

  if ((j <= 0) || (i <= 0) || (j >= SZY-1) || (i >= SZX-1)) return r;


  /*
    vertex( sp[i][j][0],     sp[i][j][1],    sp[i][j][2]); 
   vertex( sp[i][j+1][0],   sp[i][j+1][1],  sp[i][j+1][2]);
   vertex( sp[i+1][j][0],   sp[i+1][j][1],  sp[i+1][j][2]);
   vertex( sp[i+1][j+1][0], sp[i+1][j+1][1],sp[i+1][j+1][2]);
   */

  cp = (float[][])append(cp, crossProduct(i,j, i-1,j-1, i,j-1) );


  cp = (float[][])append(cp, crossProduct(i,j, i-1,j, i-1,j-1) );
  cp = (float[][])append(cp, crossProduct(i,j, i,j+1, i-1,j) );
  cp = (float[][])append(cp, crossProduct(i,j, i+1,j+1, i,j+1) );
  cp = (float[][])append(cp, crossProduct(i,j, i+1,j, i+1,j+1) );
  cp = (float[][])append(cp, crossProduct(i,j, i,j-1, i+1,j) );

  /// sum all normal vectors
  for (int ind = 0; ind < cp.length; ind++) {
    r[0] += cp[ind][0];    
    r[1] += cp[ind][1];
    r[2] += cp[ind][2];
  }

  /// normalize

  r = normalize(r);

  return r;

}


float [] normalize(float r[]) {

  float l = dist(0,0,0,r[0],r[1],r[2]);

  if (l == 0) return r;

  r[0] /= l;
  r[1] /= l;
  r[2] /= l;

  return r;
}
