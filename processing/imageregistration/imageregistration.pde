

  PImage ima;
  PImage imb;
  PImage imd;
  
  void setup() {
    
    ima = loadImage("../velodyne/frames/hgt/prepross_height_10101.png");
    imb = loadImage("../velodyne/frames/hgt/prepross_height_10102.png");
    
    imd = new PImage();
    imd.width = ima.width;
    imd.height = ima.height;
    imd.pixels = new color[ima.width*ima.height]; 
    
    
    float mse = 0.0;
    
    for (int j = 0; j < ima.width; j++) {
    for (int i = 0; i < ima.height; i++) {
      
      int pixind = j*ima.height + i;
      
      float ba = brightness(ima.pixels[pixind]);
      float bb = brightness(imb.pixels[pixind]);      
      
      float diff = abs(bb-ba);
      
      imd.pixels[pixind] = color(diff); 
      
      if ((alpha(ima.pixels[pixind]) > 0) && (alpha(ima.pixels[pixind]) > 0))
        mse += (diff*diff);
      
    }} 
        
    mse = mse/(ima.width*ima.height);
      
    print("mse " + mse + "\n");
    
    size(ima.width*3,ima.height*3);
       
  }
 
  
  void draw() {
    scale(3);
    image(imd,0,0);
  }
