PImage tx,tx2;

// from depthbuffer
// the original perspective command sets perspective in the
// vertical direction, so it is wider in the horiz dir.
float angle =  PI*0.44*640/480; //PI*0.44*640/480;
float neard = 500;
float fard = 8000*0.6;
float ffract;

void setup() {
  int h = 500;
  int w = (int)(2*atan(angle*3/4)*h);
   size(w,h);
   
   ffract = (fard-neard)/fard;
}

int index = 10000;
  
void draw() {
  background(0);
  tx  = loadImage("../depthbuffer/frames/depth/depth" + index + ".png");
  tx2 = loadImage("../depthbuffer/frames/vis/vis"     + index + ".png");
  index+=5;
  
  float depth[][] = new float[tx.height][tx.width];
  
  loadPixels();
  
  for (int i = 0; i < tx.height; i++) {
    float zf = -0.5*((float)(i - tx.height/2)/(float)(tx.height/2));
    //print("zf " + zf);
  for (int j = 0; j < tx.width; j++) {

    int txpixind = i*tx.width + j;
    color c = tx.pixels[txpixind];
    
    if (c != color(0)) {
    float d = getfloat(c);
    depth[i][j] = d;
    
    float yf = (float)j/(float)tx.width;
    
    float zc = 0.5 + d*zf;
    
    int yc = (int)((1.0-d) * height *ffract);
    int xc = (int)(width/2 +  (yf-0.5) * width * (d + neard/fard)/(1.0+neard/fard)  ); 
    
    int pixind = yc*width + xc;
    if (pixind >= width*height) pixind = width*height-1;
    if (pixind < 0) pixind = 0;
    
    if ((pixels[pixind] == color(0)) || (getfloat(pixels[pixind]) > zc)) {
      pixels[pixind] = makecolor(zc);///tx2.pixels[txpixind]; 
    }
  
    /// draw first person view in lower left corner  
    pixels[(height-tx.height/2+ i/2)*width+j/2] = makecolor(zc);

    }
  }
  //println("");
}
  
  
  updatePixels();
  saveFrame("frames/frame#####.jpg");
//noLoop();
}
