/*
binarymillenium 
 November 2010
 GNU GPL v3 
*/


PImage tiles[];
PImage dec[];
PImage elev[];

PImage[] loadTiles(String path) {
  File dir = new File(path); 
  PImage tiles[];
  tiles = new PImage[dir.list().length];
  for (int i = 0; i < dir.list().length; i++) {
    println( dir.list()[i]);
    try {
    tiles[i] = loadImage(path + "/" + dir.list()[i]);
    } catch (Exception e) {
       tiles[i] = null; 
    }
  }
  return tiles;
}

void setup() {
  size(64*16,64*9);
  //tiles = loadImage("iso-64x64-outside.png");
  
  String path;
   
  tiles = loadTiles(sketchPath + "/data/tiles");
  dec   = loadTiles(sketchPath + "/data/dec");
  elev  = loadTiles(sketchPath + "/data/elev");
  
  //println("dec size " + dir.list().length);
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
      
      
      //////////////////////////////////////
      // get a random flat tile for base
      float frac = 1.0;  
     // random(tiles.length); 
      int tile_ind = (int) (tiles.length * 3.0*noise( x_noise/frac, y_noise/frac,t))%tiles.length;
     
      if (tiles[tile_ind] != null) {
        image(tiles[tile_ind], x_rot, y_rot);
      }
      
      ///////////////////////////////////////
      // raise the elevation
      int elevation = 0;
      if (noise( x_noise/frac, y_noise/frac,2100+t) > 0.7) {
        frac = 100.0;
        
      final int MAX_HEIGHT=4;
        elevation = (int) (MAX_HEIGHT*noise( x_noise/frac+2000, y_noise/frac,t));
      
      // draw elev tiles upwards
      for (int k = 0; k < elevation; k++) {
        
        float nval =  3.0*noise( x_noise/frac,y_noise/frac, k/frac + t);
        int ind = (int) (elev.length * nval) % elev.length;
        if (elev[ind] != null) {
          image(elev[ind], x_rot, y_rot - k*64 );
        }
      }
      }
         
      //////////////////////////
      /// now put a tree on it
      if (noise( 500 + x_noise/frac, y_noise/frac,t) > 0.7) {
        frac = 10.0;
        
        float nval =  3.0*noise( 100 + x_noise/frac,y_noise/frac,t);
        int ind = (int) (dec.length * nval) % dec.length;
        if (dec[ind] != null) {
          image(dec[ind], x_rot, y_rot - elevation*64 - dec[ind].height);
        }
        
        if (ind > dec_ind_max){ 
          dec_ind_max = ind; 
          println(dec.length + " max " + ind + " " + nval); 
        }
        if (ind < dec_ind_min){ 
          dec_ind_min = ind; 
          println(dec.length + "  min " + ind + " " + nval); 
        }
      }
      
    }  
  }
  
}
