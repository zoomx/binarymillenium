
int SZ = 500;

float[][] grid = new float[SZ][SZ];

int cur_x;
int cur_y;
float cur_r;

PImage ima;
PImage imb;
String base = "../depthvis/frames/height/frame";

void setup() {
  
  frameRate(1);
  /// start out in the middle of the grid
  cur_x = SZ/2;
  cur_y = SZ/2;
  
  size(SZ,SZ);
  
  cur_r = 0;
  
  
}


float register() {
  
   
    //imb = loadImage(base + str(index+1).substring(1) +".png");

float minmse = 100000.0;
float minrot = 0.0;
int minxo =0;
int minyo =0;



  int rsteps = 10;
  float rrange = PI/20.0;
  float div = 5.0;
  
  int latstepsize = (int)div;
  int latrange=latstepsize*3;
  
  int totnum = 0;
  
  float[][] mse = new float[latrange/latstepsize*latrange/latstepsize*rsteps][5];
    // println(mse.length + " ");
 for (int i = 0; i < ima.height; i++) { 
 for (int j = 0; j < ima.width; j++) {
   
   float h = 1.0-getfloat(ima.pixels[i*ima.width+j]);  
   if (h > 0) {
      int y = (i - ima.height/2);
      int x = (j - ima.width/2);
      
      int mseind = 0;
      
      for (int xo = -latrange/2; xo < latrange/2; xo+=latstepsize) {
      for (int yo = -latrange/2; yo < latrange/2; yo+=latstepsize) {
      for (float rind = 0; rind < rsteps; rind++) {
        float r = -rrange/2+rind*rrange/rsteps;
     
        int rx = (int) ((cos(cur_r+r)*(x+xo)-sin(cur_r+r)*(y+yo))/div);
        int ry = (int) ((sin(cur_r+r)*(x+xo)+cos(cur_r+r)*(y+yo))/div);
      
        int nx = cur_x + rx;
        int ny = cur_y + ry;
      
        if ((ny < SZ) && (nx < SZ) && (ny >=0) && (nx >= 0)) {
        
          if (grid[ny][nx] > 0) {
           
            float diff = abs(grid[ny][nx]-h);
            
            mse[mseind][0] += diff*diff;
            mse[mseind][1] = xo;
            mse[mseind][2] = xo;
            mse[mseind][3] = r;
            /// count the number of points differenced
            mse[mseind][4]++;
            
            totnum++;
          }
           
        }
        

        mseind++;
        
      }}}
   }
  }}
      
      
  
  /////////////////////////////////////////////////////////////////////  
  /// find minmse
  int mseind = 0;
  int minmseind = 0;
      
     for (int xo = -latrange/2; xo < latrange/2; xo+=latstepsize) {
      for (int yo = -latrange/2; yo < latrange/2; yo+=latstepsize) {
      for (float rind = 0; rind < rsteps; rind++) {
        float r = -rrange/2+rind*rrange/rsteps;
          
          mse[mseind][0] = mse[mseind][0]/mse[mseind][4];
        if (mse[mseind][4] > 0.25*(float)totnum/(float)mse.length) {
        
  
        if (mse[mseind][0] < minmse) {
          minmse = mse[mseind][0];
          minxo =  (int)mse[mseind][1];
          minyo =  (int)mse[mseind][2];
          minrot = mse[mseind][3];        
          minmseind = mseind;
        }
        }
        
        mseind++;
        
      }}}
        
    
    println(minmseind + ", mse " + mse[minmseind][0] + ", xo " + mse[minmseind][1] + 
            ", yo " + mse[minmseind][2] + ", r " + 180.0*mse[minmseind][3]/PI + ", num " + mse[minmseind][4]);
 cur_x += minxo;
 cur_y += minyo;
 cur_r += minrot;
 
 return minmse;
  
}

void updategrid()
{
  /// having found the minmse, save the values into the grid
 
 for (int i = 0; i < ima.height; i++) { 
    for (int j = 0; j < ima.width; j++) {
      
      int y = (i - ima.height/2);
      int x = (j - ima.width/2);
      
      int rx = (int) ((cos(cur_r)*x-sin(cur_r)*y)/5.0);
      int ry = (int) ((sin(cur_r)*x+cos(cur_r)*y)/5.0);
      
      int nx = cur_x + rx;
      int ny = cur_y + ry;
      
      if ((ny < SZ) && (nx < SZ) && (ny >=0) && (nx >= 0)) {
        
          float h = 1.0-getfloat(ima.pixels[i*ima.width+j]);  
        
          //if (h > grid[ny][nx]) 
          if (h > 0) {
            grid[ny][nx] = h;       
          }
      }
  }}
  
}
 int index = 100001;
       
void draw() {
  
  
  
  ima = loadImage(base + str(index).substring(1) + ".png");
  
  float minmse = 0.0; 
  if (index > 100001) minmse =register();
  
 
  updategrid();
  //println(minmse + ", " + cur_x + " " + cur_y + ", " + cur_r/PI*180.0);
   
  index++; 
 
  loadPixels();
 for (int i = 0; i < SZ; i++) { 
    for (int j = 0; j < SZ; j++) {
     
      int pixind = i*SZ+j;
     pixels[pixind] = makecolor(grid[i][j]);      
      
        
 }}
 updatePixels();
 
 //noLoop();
}
