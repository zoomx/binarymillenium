

  PImage ima;
  PImage imb;
  PImage imd; 
  PImage imminrot;
 
  PrintWriter output;
  
  String base = "../velodyne/frames/hgt/prepross_height_";
  
  void setup() {
    
    output = createWriter("angles.csv");
 
     size(120, 120);
       
  }
 
 int index = 10000;
 
  void draw() {
    
       
    ima = loadImage(base + index + ".png");
    imb = loadImage(base + (index+1) +".png");
    
    imd = new PImage();
    imd.width = ima.width;
    imd.height = ima.height;
    imd.pixels = new color[ima.width*ima.height]; 
    
  

    float minmse = 10000.0;
    float minrot = 0.0;      
    
      
    for (float r = -2.0; r < 2.0; r+= 0.005) {
      
    pushMatrix();
    
    translate(width/2,height/2);
    rotate(r/180.0*PI);
    translate(-width/2,-height/2);
    image(imb,0,0);
    
    PImage imbr = get();
    
    float mse = 0.0;
    
    for (int j = 0; j < ima.width; j++) {
    for (int i = 0; i < ima.height; i++) {
      
      int pixind = j*ima.height + i;
      
      float ba = brightness(ima.pixels[pixind]);
      float bb = brightness(imbr.pixels[pixind]);      
      
      float diff = abs(bb-ba);
      
      imd.pixels[pixind] = color(diff); 
      
      if ((alpha(ima.pixels[pixind]) > 0) && (alpha(imb.pixels[pixind]) > 0))
        mse += (diff*diff);
      else
        imd.pixels[pixind] = color(0);
      
    }} 
        
    mse = mse/(ima.width*ima.height);
      
    if (mse < minmse) {
      minmse = mse;
      minrot = r;
      imminrot = imd.get();
    }
    
    popMatrix();
    }
   
   print(index + ", mse " + minmse + ", rotation " + minrot + "\n");
   output.println(index + ",\t" + minrot);
   output.flush();
   
    image(imminrot,0,0);
    
    index++;  
}
