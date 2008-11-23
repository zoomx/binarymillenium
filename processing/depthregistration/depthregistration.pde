
int SZ = 500;

float[][] grid = new float[SZ][SZ];

int cur_x;
int cur_y;
int cur_r;

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


void register(int ind) {
  
    ima = loadImage(base + str(ind).substring(1) + ".png");
    //imb = loadImage(base + str(index+1).substring(1) +".png");

 for (int i = 0; i < ima.height; i++) { 
    for (int j = 0; j < ima.width; j++) {
      
      int y = (i - ima.height/2)/5;
      int x = (j - ima.width/2)/5;
      
      int nx = cur_x+x;
      int ny = cur_y+y;
      
      if ((ny < SZ) && (nx < SZ) && (ny >=0) && (nx >= 0)) {
        float h = 1.0-getfloat(ima.pixels[i*ima.width+j]);  
        if (h > grid[ny][nx]) 
        //if (h > 0)
          grid[ny][nx] = h;  
        
      }
  }}
  
}

 int index = 100001;
       
void draw() {
  
 
  register(index);
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
