/*
binarymillenium 
 November 2010
 GNU GPL v3 
*/


PImage tiles[];
PImage dec[];

void setup() {
  size(64*16,64*9);
  //tiles = loadImage("iso-64x64-outside.png");
  
  String path;
  File dir;
   
  path = sketchPath + "/data/tiles";

  dir = new File(path); 
  
  //File files = listFiles(sketchPath + "/data/tiles");
  
  tiles = new PImage[dir.list().length];
  for (int i = 0; i < dir.list().length; i++) {
    tiles[i] = loadImage(path + "/" + dir.list()[i]);
  }
  
  path = sketchPath + "/data/dec";
  dir = new File(path); 
  
  //File files = listFiles(sketchPath + "/data/tiles");
  
  dec = new PImage[dir.list().length];
  for (int i = 0; i < dir.list().length; i++) {
    dec[i] = loadImage(path + "/" + dir.list()[i]);
    //println( dir.list()[i]);
  }
  println("dec size " + dir.list().length);
  //noLoop();
  frameRate(10);
}

int ew_mv_size = 0;

void keyPressed() 
{
  if (key == 'a') {
    ew_mv_size += 4;
  } 
  if (key == 'd') {
    ew_mv_size -= 3;
  } 
}


float t = 0.0;
int xoff = 0;
int yoff = 0;
int dec_ind_max = 0;
int dec_ind_min = 100000;

void draw() {
  background(0);
  
  t += 0.00001;
  int mv_size = 8;
  xoff += ew_mv_size;
  yoff -= ew_mv_size/2;
  
  int x_part = xoff % 32;
  int x_rnd = xoff/32;
  
  int y_part = yoff % 32;
  int y_rnd  = yoff/32;
  //println(x_part);
  
  for (int j = -height/32; j < height/32; j++) {
    for (int i = -2; i < width/32+1; i++) {
      float x = i*32 - x_part;
      float y = -j*32 + y_part;
           
      float x_rot = x;
      float y_rot = x/2 - y;
      
      int x_noise = (i + x_rnd);
      int y_noise = (j + y_rnd);
      // get a random flat tile
      float frac = 1.0;  
     // random(tiles.length); 
      int tile_ind = (int) (tiles.length * 3.0*noise( x_noise/frac, y_noise/frac,t))%tiles.length;
     
      image(tiles[tile_ind], x_rot, y_rot);
          
      /// now put a tree on it
      if (noise( 500 + x_noise/frac, y_noise/frac,t) > 0.7) {
        frac = 10.0;
        
        float nval =  3.0*noise( 100 + x_noise/frac,y_noise/frac,t);
        int dec_ind = (int) (dec.length * nval) % dec.length;
        image(dec[dec_ind], x_rot, y_rot);
        
        if (dec_ind > dec_ind_max){ 
          dec_ind_max = dec_ind; 
          println(dec.length + " max " + dec_ind + " " + nval); 
        }
        if (dec_ind < dec_ind_min){ 
          dec_ind_min = dec_ind; 
          println(dec.length + "  min " + dec_ind + " " + nval); 
        }
      }
      
    }  
  }
  
}
