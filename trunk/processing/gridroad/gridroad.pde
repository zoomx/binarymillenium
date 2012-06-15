
/**

*/



float BWD = 50.0;
// much above 120 is too intensive for my i5 laptop
int NUM = 80;

float[][] elev;//[NUM][NUM];

void setup()
{
  size(800, 800, P3D);
  frameRate(10);
  
  elev = new float[NUM][NUM];
  
  float nsc1 = 0.05;
  for (int i = 0; i < NUM; i++) {
    for (int j = 0; j < NUM; j++) {
      //elev[i][j] = -0.2*(i*j);
      elev[i][j] = 10*BWD*(noise(i*nsc1,j*nsc1)-0.5);
    }
  }
}

float x = BWD*NUM/2;
float y;
float z = BWD*3*NUM/4;

float y_off;

float yvel;
float xvel, zvel;
float rot, rotx;
boolean pause= false;

void keyPressed()
{
  float sc = BWD/8;
  if (key == 'w') {
    zvel -= sc*1;
  }
  if (key == 's') {
    zvel += sc*1;
  }  
  if (key == 'a') {
    xvel -= sc*0.5;
  }
  if (key == 'd') {
    xvel += sc*0.5;
  }  
  if (key == 'q') {
    yvel += sc*1;
  }
  if (key == 'z') {
    yvel -= sc*1;
  }  
  
  if (key== 'j') {
     rot += 0.1; 
  }
  
  if (key == 'l') {
     rot -= 0.1; 
  }
  
  if (key == 'p') {
     pause = !pause; 
  }
  
  if (key == 'i') {
     rotx += 0.1; 
     
     if (rotx > PI/2) { rotx = PI/2; }
  }
  
  if (key == 'k'){
     rotx -= 0.1; 
     
     if (rotx < -PI/2) { rotx = -PI/2; }
  }
}



void draw()
{
  background(10,90,200);
  
  ambientLight(50, 50, 200);

  directionalLight(255,255,220,0.2,1.0,-0.3);
  
  
  // TBD where does BWD*13 come from?
  translate(width/2, height/2, BWD*13 );
  
  
  translate(0,0, -BWD );
  fill(200);
  pushMatrix();
  translate(0,BWD/2, 0 );
  box(BWD/2, BWD/4, BWD/2);
  translate(0,-BWD/4, 0 );
  sphere(BWD/4);
  popMatrix();
  
  int i_loc = (int)((z+BWD/2.0)/BWD );
  int j_loc = (int)((x+BWD/2.0)/BWD );
  
  y_off = 0;
  if ((i_loc >= 0) && (i_loc < NUM) && (j_loc >= 0) && (j_loc < NUM)) {
   y_off = elev[i_loc][j_loc];
  }
  //println(x + ", x=" + j_loc + ", " + z + ", z=" + i_loc + ", y " + y + "," +  y_off);

  rotateX(rotx);
  rotateY(-rot);
  
  
  if (!pause) {
  yvel *= 0.95;
  yvel -= 1.4;
  y += yvel;
  
  if (y < y_off) { 
    y = y_off; 
    yvel = 0; 
  }
  
  xvel *= 0.6;
  zvel *= 0.6; 
  
  x += xvel * cos(rot) + zvel*sin(rot);
  z += -xvel * sin(rot) + zvel*cos(rot);
  }
  
  translate(-x,
            BWD + y, 
             -z);

  //translate(-x*cos(rot) -z*sin(rot),
  //          BWD + y, 
  //           x*sin(rot) -z*cos(rot));
  
  
  //stroke(50);
  
  fill(0,150,0);

  
  noStroke();
  for (int i = 0; i < NUM; i++) {
    pushMatrix();
    for (int j = 0; j < NUM; j++) {
      pushMatrix();
      translate(0, -elev[i][j], 0);
      box(BWD);
      popMatrix();
      translate(BWD,0,0);
    }
    popMatrix();
    translate(0,0,BWD);
    //translate(-10*20, 0, 10);
    
  }
    
}
