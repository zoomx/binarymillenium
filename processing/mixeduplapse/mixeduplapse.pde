/**
 * binarymillenium 2008
 * licensed under the gnu gpl 3 or later
 * 
 */
import processing.net.*;

Client cl;
String data;

int smallw = 320;
int smallh = 240;

byte byteBuffer[]; 

/// thumbnail of the image just received
PImage rximage;
PImage rximageSmall;
/// thumbnail of the image that we want to match
PImage srcimageSmall;
/// base image that can be subtracted from src image
/// the first file in the src directory should be the base image, make this
/// more elegant later
PImage srcBaseSmall;

/// where the rxed image is written to
OutputStream output;

/// list of src files that have not yet been matched
ArrayList uncomparedFiles;

int im_counter = 0;

void setup() {
  size(800, 600);
  background(50);
  fill(200);
  
  uncomparedFiles = new ArrayList();
  
  File dir = new File(sketchPath("") + "/src/");
  String[] dirlist = dir.list();
  for (int i = 0; i < dirlist.length; i++) {
    //println(dirlist[i]);
    uncomparedFiles.add(dirlist[i]);
  }
  
  /// get the base image
  PImage imbase = getNewSrcImage(0);
  if (imbase == null) {
    noLoop();
    return; 
  }
  srcBaseSmall = createImage(smallw, smallh, RGB);
  srcBaseSmall.copy(imbase,0,0, imbase.width, imbase.height, 0,0, smallw,smallh); 
  
  srcimageSmall = getNewSrcSmallAndSubtractBackground(srcBaseSmall);
  
  getImage();
}

String newSrcImageName;

PImage getNewSrcSmallAndSubtractBackground(PImage base) {
  /// get random image to start off with
  PImage im = getNewSrcImage(-1);
  if (im == null) {
    noLoop();
    return im; 
  }
  PImage small = createImage(smallw, smallh, RGB);
  small.copy(im,0,0, im.width, im.height, 0,0, smallw,smallh); 
  
  return subtractBackground( base,  small);
  
}

PImage subtractBackground(PImage base, PImage newim) {
  PImage rv = createImage(newim.width, newim.height, RGB);
  
    for (int i= 0; i < newim.pixels.length; i++) {
        float rdiff = abs(  red(base.pixels[i]) - 
                        red(newim.pixels[i]) );
                                            
        float gdiff = abs( green(base.pixels[i]) - 
                       green(newim.pixels[i]) );
                                            
        float bdiff = abs( blue(base.pixels[i]) - 
                       blue(newim.pixels[i]) ); 
                       
    if ((rdiff > 20) || (gdiff > 20) || (bdiff > 20)) {
        rv.pixels[i] = newim.pixels[i];
    } else {
        rv.pixels[i] = color(0);
    }
  }
  
  return rv;
}

/// get a random image
PImage getNewSrcImage(int ind) {
  if (uncomparedFiles.size() < 1) return null;
  
  /// select a random image
  if (ind < 0) {
    ind = (int)random(0, uncomparedFiles.size()-1);
  }  
  /// TBD check for > size() condition
  
  newSrcImageName = (String)uncomparedFiles.get(ind);
  uncomparedFiles.remove(ind);
  
  println("new src is " + newSrcImageName);
  
  PImage newSrcIm = loadImage(sketchPath("") + "/src/" + newSrcImageName);
  
  if (newSrcIm == null) return getNewSrcImage(ind);
  
  return newSrcIm;
}

void getImage() {
  
  //im_counter++;
   
  byteBuffer = new byte[20000];
  
  //c = new Client(this, "processing.org", 80);
  //c.write("GET /img/processing.gif HTTP/1.1\n"); // Use the HTTP "GET" command to ask for a Web page
  
  startClient();
   
  /// could parse header and look for image type from that, and 
  /// generate file name from it.
  output = createOutput("output" + im_counter + ".jpg");
  //output = createWriter("output.gif");
  
 
  
  finished_rx = false;
  
  received = false;
  readingheader = true;
  totalcount = 0;
  expectedlength = 0;
}

boolean finished_rx  = false; 
boolean received     = false;
boolean readingheader = true;
int totalcount = 0;
int expectedlength = 0;

void startClient() {
  cl = new Client(this, "192.168.2.57", 80);
  cl.write("GET /now.jpg HTTP/1.1\r\n"); // Use the HTTP "GET" command to ask for a Web page
  cl.write("User-Agent: Wget/1.11.3\r\n"); 
  cl.write("Host: 192.168.2.123\r\n"); // Be polite and say who we are
  cl.write("Accept: *//*\r\n"); 
  cl.write("Connection: Keep-Alive\r\n"); 
  cl.write("\r\n"); 
}

void draw() {
  int clavail = 0;

      clavail = cl.available();

 
  if (clavail > 0) { 
   
    int bytescount;

      bytescount = cl.readBytes(byteBuffer); 


    if (readingheader) {
      readingheader = false; 
      String raw = new String(byteBuffer);

      String[] header = split(raw, "\n");

      int startind = 0;
      for (int i = 0; i < header.length; i++) {
        //println(header[i]);
        startind += header[i].length()+1;

        String[] substrings = split(header[i], " ");

        if ((substrings.length >1) && (substrings[0].equals("Content-Length:"))) {
          String len = substrings[1].substring(0,substrings[1].length()-1);
          expectedlength = Integer.parseInt(len);
         // println("expected length " + substrings[1] + " " + expectedlength);
        }

        if (header[i].length() == 1) //(header[i].equals(" "))  
          i+= header.length;
      }

      int rem = bytescount - startind;
      
      if (rem < 0) return;
      println(bytescount + " " + startind);
      byte byteBuffer2[] = new byte[rem];
      for (int i = 0; i < rem; i++) {
        byteBuffer2[i] = byteBuffer[i+startind];
      }

     // println("startind " + startind + ", count = " + count + 
     //    ", remaining = " + rem + ", " + byteBuffer2.length);

      //byteBuffer = byteBuffer2;   
      // count = rem;   

      try {
        output.write(byteBuffer2);//,totalcount,rem);
        totalcount+=rem;
      } 
      catch (IOException e) {
        println("output write failed");
      }  
    } 
    else {

      try {
        //println("count " + count + ", buffer len " + byteBuffer.length);
        output.write(byteBuffer,0,bytescount); //,totalcount,count);
        totalcount+=bytescount;
      } 
      catch (IOException e) {
        //println("output write failed");
      }  

    }

    //println(count + " " + totalcount);
    if (totalcount >= expectedlength) received = true;


  } 
  else if ((received) && (!finished_rx)) {


    //println("finished");

    try {
      output.flush();
      output.close(); 
    } 
    catch (IOException e) {
      println("output flush and close failed");
    }

    //println("rxed image");
    finished_rx = true;
    
    //cl.stop();
   
  } else if (finished_rx) {
    
    //try {
    rximage = loadImage("output" + im_counter + ".jpg");
    
    
    if (rximage == null) { getImage(); return; }
    
    rximageSmall = createImage(smallw,smallh, RGB);
    rximageSmall.copy(rximage,0,0,rximage.width,rximage.height, 0,0,smallw,smallh);
    
    PImage newim = subtractBackground( srcBaseSmall,  rximageSmall);
        
    float mse = 0.0;
    int mseCount = 0;
    
    //loadPixels();
    
    PImage outputimage = createImage(smallw,smallh, RGB);
    
    for (int i = 0; i < srcimageSmall.height; i++) {
      for (int j = 0; j < srcimageSmall.width; j++) {
        //mirror reverse
        
        int pixind = i*srcimageSmall.width+j;
            
        float diff = (brightness(newim.pixels[pixind]) - 
                      brightness(srcimageSmall.pixels[pixind]) );
                                                                                 
        float rdiff = (red(newim.pixels[pixind]) - 
                       red(srcimageSmall.pixels[pixind]) );
                                            
        float gdiff = (green(newim.pixels[pixind]) - 
                       green(srcimageSmall.pixels[pixind]) );
                                            
        float bdiff = (blue(newim.pixels[pixind]) - 
                       blue(srcimageSmall.pixels[pixind]) );
        
        int flippedpixind = i*srcimageSmall.width+srcimageSmall.width-j-1;
        if ((newim.pixels[pixind] == color(0)) && (srcimageSmall.pixels[pixind] == color(0))) {
          outputimage.pixels[flippedpixind] = color(0);
        } else  {
          mse += diff*diff;
          mseCount++;
          
          float nred   =   red(srcimageSmall.pixels[pixind]);
          float ngreen = green(srcimageSmall.pixels[pixind]);
          float nblue  =  blue(srcimageSmall.pixels[pixind]);
         
          if (rdiff > 0) nred   =  red(newim.pixels[pixind]);
          if (gdiff > 0) ngreen =green(newim.pixels[pixind]);
          if (bdiff > 0) nblue  = blue(newim.pixels[pixind]);
          
          if (newim.pixels[pixind] == color(0)) { 
            ngreen *= 0.7;
            nblue  *= 0.7;
          }
          if (srcimageSmall.pixels[pixind] == color(0)) { 
            nblue *= 0.7;
            nred  *= 0.7;
          }
          
          outputimage.pixels[flippedpixind] = color(nred,ngreen,nblue);
          //color(128+rdiff/2,128+gdiff/2,128+bdiff/2);
        } 

//      if (diff > 0) pixels[i*width+width-j-1] = color(0.7*diff,diff,diff*0.7);
//      else pixels[i*width+width-j-1] = color(-0.7*diff,-diff*0.66,-diff);
      
        
        //pixels[i*width+width-j-1] = srcimageSmall.pixels[i*width+j];
      
    }}
    //updatePixels();
    
    image(outputimage,0,0,width,height);
    
    mse /= mseCount;
    println("mse " + mse + ", " + mseCount);
    
    if (mse < 1500) saveAndIncrement();

    getImage();
  }
} 

int rximagecounter = 0;


void saveAndIncrement() {
  
  if ((rximage != null) && (rximage.width > 0)) {
    println("saving and incrementing");
    /// TBD need to save fullsize image instead
 
    rximage.save(newSrcImageName + "approx.jpg");
    rximagecounter++;
    
  }
    
    srcimageSmall = getNewSrcSmallAndSubtractBackground(srcBaseSmall);  
}

void keyPressed() {
  if (key == 'a') {
     saveAndIncrement();
  } 
}



