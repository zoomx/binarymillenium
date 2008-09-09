


color c[] = new color[6];
int NUM = 256*(c.length-1);
color grad[] = new color[NUM];

void spectrum_setup() {
/// red is the warmest


c[5] = color(255,0,0);
c[4] = color(255,255,0);
c[3] = color(0,255,0);
c[2] = color(0,255,255);
/// blue is the coolest
c[1] = color(0,0,255);
c[0] = color(255,0,255);

//size(NUM,140);

//frameRate(1);
//noStroke();
}

color makecolor(float f)
{
  int i1 = 0;
  int i2 = 1;
  f = f*(c.length-1);
 
  while (f > 1.0) {
     f -= 1.0;  
     i1++;
     i2++;    
  }
  
   int r = int( (1.0-f)*red(c[i1])   + f*red(c[i2]));
   int g = int( (1.0-f)*green(c[i1]) + f*green(c[i2]));
   int b = int( (1.0-f)*blue(c[i1])  + f*blue(c[i2]));
  
   return color(r,g,b,255);
}

void spectrum_draw() {
  
  color oc = color(0,0,0);
 
  for (int i = 0; i< NUM; i++) {
      
      float f = (float)i/(float)NUM;  
      
      color nc = makecolor(f);
      fill(nc);
      
      rect(i,0,1,height/2);
      

      fill( color( 250*abs(red(nc)-red(oc)),  250*abs(green(nc)-green(oc)), 250*abs(blue(nc)-blue(oc))) );  
      rect(i,height/2,1,height/2);

      
      oc = nc;
  }
  //background(0);
 
 /* 
for (int i = 0; i< NUM; i+=2) {

  int cind = i/(NUM/c.length); 
  if (i > 2) i =2;
  
  fill(c[cind]);
  rect(i,0,1,height);

}*/

}
