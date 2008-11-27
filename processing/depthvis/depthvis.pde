// binarymillenium 2008
// licensed under the GNU GPL latest version

PImage tx,tx2;

// from depthbuffer
// the original perspective command sets perspective in the
// vertical direction, so it is wider in the horiz dir.
final float angle =  PI*0.5*600/600;
final float neard = 1600/4;
final float fard = 1600/2*80;
float ffract;

void setup() {
  final int h = 1600;
  final int w = (int)(h*tan(angle/2)*2); //(h*2.0);
   size(w,h);
   
   ffract = (fard-neard)/fard;
}

int index = 10000;

boolean dovis = false;

void draw() {
  background(0);
  tx  = loadImage("../depthbuffer/frames/depth/depth" + index + ".png");
  tx2 = loadImage("../depthbuffer/frames/vis/vis"     + index + ".png");
  index+=1;
  
  //float depth[][] = new float[tx.height][tx.width];
  
  loadPixels();
  
  for (int i = 0; i < tx.height; i++) {
    float zf = -0.5*((float)(i - tx.height/2)/(float)(tx.height/2));
    //print("zf " + zf);
  for (int j = 0; j < tx.width; j++) {

    int txpixind = i*tx.width + j;
    color c = tx.pixels[txpixind];
    
    if (c != color(0)) {
    float d = getfloat(c);  //1.0 -  red(c)/255.0;
    
    /// add the 'missing' depth that is inbetween 
    d = (d + neard/fard)/(1.0+neard/fard);
    //depth[i][j] = d;
    //if (d > 0.9) print(d + " ");
    
    float xf = (float)j/(float)tx.width-0.5;
    
    float zc = 0.5 + d*zf;
    
    // the ffract is wrong give that d is scale above, but it looks less skewed
    int yc = (int)((1.0-d) * height); //*ffract*0.8);
    int xc = (int)(width/2 + d * xf * width);   // (2*atan(angle/2)*height)
    
    int pixind = yc*width + xc;
    if (pixind >= width*height) pixind = width*height-1;
    if (pixind < 0) pixind = 0;
    
    if ((pixels[pixind] == color(0)) || (getfloat(pixels[pixind]) > zc)) {
      if (dovis)
        pixels[pixind] = tx2.pixels[txpixind];
      else pixels[pixind] =makecolor(zc);//color(zc*255); // // 
    }
  
    /// draw first person view in lower left corner  
    //pixels[(height-tx.height/2+ i/2)*width+j/2] = makecolor(zc);

    }
  }
  //println("");
}
  
  
  updatePixels();
  if (dovis)  saveFrame("frames/vis#####.png");
  else saveFrame("frames/hgt#####.png");
noLoop();
}
