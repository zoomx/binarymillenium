// binarymillenium 2008
// licensed under the GNU GPL latest version

boolean has_been_setup = false;

color cind[] = new color[8];
int NUM = 256*(cind.length-1);
color grad[] = new color[NUM];

void spectrum_setup() {
  has_been_setup = true;
  /// red is the warmest
  colorMode(RGB,255);

  cind[7] = color(255,255,255);
  cind[6] = color(255,0,0);
  cind[5] = color(255,255,0);
  cind[4] = color(0,255,0);
  cind[3] = color(0,255,255);
  /// blue is the coolest
  cind[2] = color(0,0,255);
  cind[1] = color(255,0,255);
  cind[0] = color(0,0,0);

  for (int i = 0; i < grad.length; i++) {
    grad[i] = makecolor((float)i/(float)grad.length); 
  }

  //size(NUM,140);

  //frameRate(1);
  //noStroke();
}

color makecolor(float f)
{
  if (f >= 1.0) return cind[cind.length-1];
  if (f <= 0.0) return cind[0];
  
  if (!has_been_setup) spectrum_setup();

  int i1 = 0;
  int i2 = 1;
  f = f*(cind.length-1);

  while (f > 1.0) {
    f -= 1.0;  
    i1++;
    i2++;    
  }

  int r = int( (1.0-f)*red(cind[i1])   + f*red(cind[i2]));
  int g = int( (1.0-f)*green(cind[i1]) + f*green(cind[i2]));
  int b = int( (1.0-f)*blue(cind[i1])  + f*blue(cind[i2]));

  //print (red(color(255,0 ", " + i1 + " " + i2 + "\n");

  return color(r,g,b,255);
}

//// return a float 0-1.0, where 1.0 is max dist and 0.0 is min
float getfloat(color c)
{
  if (!has_been_setup) spectrum_setup();

  if (c == cind[cind.length-1]) { 
    return 0.0; 
  } 
  if (c == cind[0]) { 
    return 1.0; 
  }

  for (int i = 0; i < grad.length; i++) {
   if (c == grad[i]) return 1.0-(float)i/(float)grad.length; 
  }
  
  return 0.0;

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
   
   fill(cind[cind]);
   rect(i,0,1,height);
   
   }*/

}
