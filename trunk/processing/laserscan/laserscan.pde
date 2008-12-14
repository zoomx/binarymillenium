
PImage base, depth, viz;
 
int index = 2;

void setup() {
   base = loadImage("fullsize/base/base" + (index+1000) + ".jpg"); 
   viz = createImage(base.width, base.height,RGB);
   size(base.width, base.height);
}

void draw() {
   base  = loadImage("fullsize/base/base" + (index+1000) + ".jpg"); 
   depth = loadImage("fullsize/misc/misc" + (index+1000) + ".jpg");

  int bcount = 0;
  int dcount = 0;
   for (int i = 0; i < base.pixels.length; i++) {
      color col = base.pixels[i];
      //if ((hue(col) > 155) && (hue(col) < 160) 
      if ((green(col) > 200) &&
          (blue(col) < 210) && 
          (red(col) < 170)
          )    {
        viz.pixels[i] = color(0,0,255);
        bcount++;
      } 
      
      col = depth.pixels[i];
      //if ((hue(col) > 155) && (hue(col) < 160) 
      if ((green(col) > 200) &&
          (blue(col) < 210) && 
          (red(col) < 170)
          )    {
        viz.pixels[i] = color(0,255,0);
        dcount++;
      } 
     
   }
   
   println(index + " " + bcount + " " + dcount);
   
    //index = index%6+1;
    index = index+1;
    if (index >9) noLoop();
  
   image(viz,0,0); 
}
