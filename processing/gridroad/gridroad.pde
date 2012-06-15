
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
      float hills = (noise(100+i*nsc1,10+j*nsc1)-0.5);
      if (hills < 0.0) hills = 0;
      hills *= 10*BWD;
      elev[i][j] = 1*BWD*(noise(i*nsc1,j*nsc1)-0.5) + hills - 5*BWD;
    }
  }
}

float x = BWD*NUM/2;
float y;
float z = BWD*3*NUM/4;

float y_off;

float yvel;
float xvel, zvel;
float rot;
float rotx = -PI/8;
boolean ground_contact = false;
boolean pause= false;

void keyPressed()
{
  float sc = BWD/8;
  
  if (ground_contact) {
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

void drawCar(float SZ)
{
  pushMatrix();
  //translate(0,BWD*0.5, 0 );
  translate(0,-SZ/8, 0 );
  
  fill(200);
  pushMatrix();
  box(SZ/2.5, SZ/8, SZ/2);
  translate(0,-SZ/8, 0 );
  box(SZ/2.5, SZ/8, SZ/5);
  popMatrix();
 
 // draw four wheels
  fill(10);
  translate(0,SZ/10, SZ*0.23 );
  
  // back wheels
  translate(-SZ/5,0 , 0 );
  sphere(SZ/16);
  translate(SZ/2.5,0 , 0 );
  sphere(SZ/16);
  
  // forward wheel
  fill(50);
  translate(0,0 , -SZ*0.46);
  sphere(SZ/16);
  fill(50);
  translate(-SZ/2.5,0 , 0 );
  sphere(SZ/16);
  popMatrix();
}

void draw()
{
  background(10,90,200);
  
  ambientLight(50, 50, 200);

  directionalLight(255,255,220,0.2,1.0,-0.3);
  
  // TBD where does BWD*13 come from?
  translate(width/2, height/2, BWD*13 );
  
  // how far behind the car the camera should be
  float car_sz = BWD/8;
  translate(0, BWD/4, BWD/4 );
  
  rotateX(rotx);
    
  drawCar(car_sz);

  
  int i_loc = (int)((z+BWD/2.0)/BWD );
  int j_loc = (int)((x+BWD/2.0)/BWD );
  
  y_off = 0;
  
  i_loc %= NUM;
  j_loc %= NUM;
  
  if (j_loc < 0) j_loc+= NUM;
  if (i_loc < 0) i_loc+= NUM;
  
  println(i_loc + " " + j_loc);

  
  if ((i_loc >= 0) && (i_loc < NUM) && (j_loc >= 0) && (j_loc < NUM)) {
   y_off = elev[i_loc][j_loc];
  }
  //println(x + ", x=" + j_loc + ", " + z + ", z=" + i_loc + ", y " + y + "," +  y_off);


  rotateY(-rot);
  
  
  if (!pause) {
  yvel *= 0.95;
  yvel -= 1.4;
  y += yvel;
  
  if (y < y_off) { 
    ground_contact = true;
    y = y_off; 
    yvel = 0; 
  } else {
    ground_contact = false; 
  }
  
  xvel *= 0.6;
  zvel *= 0.6; 
  
  x += xvel * cos(rot) + zvel*sin(rot);
  z += -xvel * sin(rot) + zvel*cos(rot);
  }
  
  translate(-x,
            BWD/2 + y, 
             -z);

  //translate(-x*cos(rot) -z*sin(rot),
  //          BWD + y, 
  //           x*sin(rot) -z*cos(rot));
  
  
  //stroke(50);
  
  fill(0,150,0);

  
  noStroke();
  for (int i = i_loc- NUM/2; i < i_loc + NUM/2; i++) {
    //pushMatrix();
    for (int j = j_loc - NUM/2; j < j_loc + NUM/2; j++) {
      pushMatrix();
      
      int j2 = j;
      int i2 = i;
      
      if (j2 < 0) j2+= NUM;
      if (i2 < 0) i2+= NUM;
      
      j2 = j2 % NUM;
      i2 = i2 % NUM;
      //if ((j2 < 0) || (i2 < 0)) {println(j2 + " " + i2);}
      translate(j*BWD, -elev[i2][j2], i*BWD);
      box(BWD);
      popMatrix();
      //translate(BWD,0,0);
    }
    //popMatrix();
    //translate(0,0,BWD);
    //translate(-10*20, 0, 10);
    
  }
    
}
