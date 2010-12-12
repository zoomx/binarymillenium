/*
binarymillenium 
 November 2010
 GNU GPL v3 
*/


PImage tiles[];
PImage dec[];
PImage elev[];
PImage slope[];

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
  slope  = loadTiles(sketchPath + "/data/slope");
  
  //println("dec size " + dir.list().length);
  //noLoop();
  frameRate(10);
}

int ew_mv_size = 0;
int ns_mv_size = 0;

void keyPressed() 
{
  if (key == 'a') {
    ew_mv_size += 32;
  } 
  if (key == 'd') {
    ew_mv_size -= 32;
  } 
  
  if (key == 'w') {
    ns_mv_size += 16;
  } 
  if (key == 's') {
    ns_mv_size -= 16;
  } 
}


float t = 0.0;
int xoff = 0;
int yoff = 0;
int dec_ind_max = 0;
int dec_ind_min = 100000;

final int MAX_HEIGHT=8;
int getElevation(int x_noise,int y_noise)
{
   float frac = 3.0;
        
      
   int elevation = (int) (MAX_HEIGHT*noise( x_noise/frac+2000, y_noise/frac,t));
   
   elevation -=4;
   
   if (elevation <0) elevation = 0;
   
   return elevation;
      
}


void draw() {
  background(0);
  
  //t += 0.00001;
  xoff += ew_mv_size;
  yoff -= ns_mv_size;
  
  ew_mv_size =0;
  ns_mv_size =0;
  
  int x_part = xoff % 32;
  int x_rnd  = xoff/32;
  
  int y_part = yoff % 16;
  int y_rnd  = yoff/16;
  //println(x_part);
  

  for (int i = 10; i>= -10/*-2; i < width/32+1*/; i--) {
    // diagonal down to right
    for (int j = -10; j <=10; j++) {
      float x =  j*32 - x_part;
      float y = -i*32 + y_part;
           
      float x_rot = x   - y/2 + width/2 + i*16 -32;
      float y_rot = x/2 + y   + height/2 + i*16 -16*3;
      
      int x_noise = (i + x_rnd);
      int y_noise = (j + y_rnd);
      
      
      //////////////////////////////////////
      // get a random flat tile for base
      float frac = 90.0;  
     // random(tiles.length); 
      int tile_ind = (int) (tiles.length * 3.0*noise( x_noise/frac, y_noise/frac,t))%tiles.length;
     
      if (tiles[tile_ind] != null) {
        image(tiles[tile_ind], x_rot, y_rot);
      }
      
      if (false) {
      ///////////////////////////////////////
      // raise the elevation
      int elevation = getElevation(x_noise,y_noise);
           
      // draw elev tiles upwards
      for (int k = 0; k < elevation; k++) {
        
        float nval =  3.0*noise( x_noise/frac,y_noise/frac, k/frac + t);
        int ind = (int) (elev.length * nval) % elev.length;
        if (elev[ind] != null) {
          image(elev[ind], x_rot, y_rot - k*64 );
        }
      }
      
      /// put a slope if neighboring tiles are elevated differently
      if (getElevation(x_noise+1,y_noise-1) > elevation) {
        ///diagonally to left
         image(slope[2], x_rot, y_rot - elevation*64 );
      } else if (getElevation(x_noise-2,y_noise+1) > elevation) {
        ///diagonally to left
         image(slope[5], x_rot, y_rot - elevation*64 );
      } else if (getElevation(x_noise,y_noise-1) > elevation) {
        ///diagonally to above
         image(slope[1], x_rot, y_rot - elevation*64 );
      } else if (getElevation(x_noise,y_noise+1) > elevation) {
        ///diagonally to botttom
         image(slope[8], x_rot, y_rot - elevation*64 );
      } else
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
      
      } // extra terrain
      
    }  // i loop
  } // j loop
  
}
