
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


void keyPressed()
{
  float sc = BWD;
  if (key == 'w') {
    z -= sc*1;
  }
  if (key == 's') {
    z += sc*1;
  }  
  if (key == 'a') {
    x -= sc*1;
  }
  if (key == 'd') {
    x += sc*1;
  }  
  if (key == 'q') {
    y += sc*1;
  }
  if (key == 'z') {
    y -= sc*1;
  }  
}

float y_off;
void draw()
{
  background(0);
  
  directionalLight(255,255,220,0.2,1.0,-0.3);
  
  
  // TBD where does BWD*13 come from?
  translate(width/2, height/2, BWD*13 );
  
  int i_loc = (int)((z+BWD/2.0)/BWD );
  int j_loc = (int)((x+BWD/2.0)/BWD );
  
  if ((i_loc >= 0) && (i_loc < NUM) && (j_loc >= 0) && (j_loc < NUM)) {
   y_off = elev[i_loc][j_loc];
  }
  println(x + ", x=" + j_loc + ", " + z + ", z=" + i_loc + ", y " + y + "," +  y_off);
  
  translate(-x, BWD + y + y_off, -z);
  
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
