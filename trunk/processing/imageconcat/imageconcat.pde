 PImage tot;
 String base = "../velodyne/frames/hgt/prepross_height_";
  
 void setup() {
   
       tot = new PImage();
    tot.width = 120;
    tot.height = 120;
    tot.pixels = new color[120*120]; 
    
    size(120,120);
    
  BufferedReader reader;
 
  reader = createReader("../imageregistration/angles.csv");
  
  float totangle = 0;
  
  for (int ind = 0; ind < 101; ind++) {
  
   String newline;
   try {
        newline = reader.readLine();
   } 
   catch(Exception e) {
        return;  
   }
   
   String[] ln = split(newline,',');
   
   int index = int(ln[0]);
   float angledeg = float(ln[1]);
   if (abs(angledeg) < 0.5) angledeg = 0;
   
   totangle += angledeg;
   
   //ima = loadImage(base + index + ".png");
   PImage imb = loadImage(base + (index+1) +".png");
   
   pushMatrix();
   
       
    translate(width/2,height/2);
    rotate(totangle/180.0*PI);
    translate(-width/2,-height/2);
    image(imb,0,0);
    
    PImage imbr = get();
   
   for (int j = 0; j < imbr.width; j++) {
   for (int i = 0; i < imbr.height; i++) {
   
     int pixind = j*imbr.height + i;   
     float bb = brightness(imbr.pixels[pixind])/100.0;
     
     tot.pixels[pixind] = color(brightness(tot.pixels[pixind]) + bb);
     
  }}
  
  popMatrix();
  
 }
 
 noLoop();
 }
 
 void draw() {
   
  image(tot,0,0); 
  saveFrame("test.png");
 }
