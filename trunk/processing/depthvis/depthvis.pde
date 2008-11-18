PImage tx,tx2;

void setup() {
   size(600,400);
}

int index = 10000;
  
void draw() {
  background(0);
  tx = loadImage("../depthbuffer/frames/depth" + index + ".png");
  tx2 = loadImage("../depthbuffer/frames/vis" + index + ".png");
  index++;
  
  float depth[][] = new float[tx.height][tx.width];
  
  loadPixels();
  
  for (int i = 0; i < tx.height; i++) {
  for (int j = 0; j < tx.width; j++) {

    int txpixind = i*tx.width + j;
    color c = tx.pixels[txpixind];
    
    float d = getfloat(c);
    depth[i][j] = d;
    
    float yf = (float)j/(float)tx.width;
    float zc = 1.0-((float)i/(float)tx.height); 
    /// the far left of the screen is the furthest object
    
    
    int xc = (int)(d  * width);
    int yc = (int)(height/2 +  (yf-0.5) * height * (1.0-d*0.4)  ); 
    

    int pixind = yc*width + xc;
    if (pixind >= width*height) pixind = width*height-1;
    if (pixind < 0) pixind = 0;
    
    pixels[pixind] = tx2.pixels[txpixind]; //makecolor(zc);
    if (pixind < width*height-1) pixels[pixind+1] = tx2.pixels[txpixind]; 
    //if ((depth[i][j] >0.0) && (depth[i][j] < 1.0)) {
     // println(i + " " + j + ", " + red(c) + " " + blue(c) + " " + green(c) + ", " + depth[i][j]);
    //}
  }}
  
  
  updatePixels();
  //saveFrame("frames/frame#####.jpg");
  //noLoop();
}
