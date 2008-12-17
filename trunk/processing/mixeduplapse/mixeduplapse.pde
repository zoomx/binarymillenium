/**
 * binarymillenium 2008
 * licensed under the gnu gpl 3 or later
 * 
 */
import processing.net.*;

Client cl;
String data;

byte byteBuffer[]; 

PImage rximageSmall;

PImage srcimageSmall;

OutputStream output;
//PrintWriter output;

ArrayList uncomparedFiles;

int im_counter = 0;

void setup() {
  size(320, 240);
  background(50);
  fill(200);
  
  uncomparedFiles = new ArrayList();
  
  File dir = new File(sketchPath("") + "/src/");
  String[] dirlist = dir.list();
  for (int i = 0; i < dirlist.length; i++) {
    //println(dirlist[i]);
    uncomparedFiles.add(dirlist[i]);
  }
  
  PImage im = getNewSrcImage();
  if (im == null) {
    noLoop();
    return; 
  }
  srcimageSmall = createImage(width, height, RGB);
  srcimageSmall.copy(im,0,0, im.width, im.height, 0,0, width,height); 
  
  getImage();
}

String newSrcImageName;

/// get a random image
PImage getNewSrcImage() {
  if (uncomparedFiles.size() < 1) return null;
  
  int ind = (int)random(0, uncomparedFiles.size()-1);
  
  newSrcImageName = (String)uncomparedFiles.get(ind);
  uncomparedFiles.remove(ind);
  
  PImage newSrcIm = loadImage(sketchPath("") + "/src/" + newSrcImageName);
  
  if (newSrcIm == null) return getNewSrcImage();
  
  return newSrcIm;
}

void getImage() {
  
  //im_counter++;
   
  byteBuffer = new byte[20000];
  
  //c = new Client(this, "processing.org", 80);
  //c.write("GET /img/processing.gif HTTP/1.1\n"); // Use the HTTP "GET" command to ask for a Web page
  
  cl = new Client(this, "10.1.100.123", 80);
  cl.write("GET /now.jpg HTTP/1.1\r\n"); // Use the HTTP "GET" command to ask for a Web page
  cl.write("User-Agent: Wget/1.11.3\r\n"); 
  cl.write("Host: 10.1.38.123\r\n"); // Be polite and say who we are
  cl.write("Accept: *//*\r\n"); 
  cl.write("Connection: Keep-Alive\r\n"); 
  cl.write("\r\n"); 
   
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


void draw() {

  if (cl.available() > 0) { 

    int bytescount = cl.readBytes(byteBuffer); 

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
          println("expected length " + substrings[1] + " " + expectedlength);
        }

        if (header[i].length() == 1) //(header[i].equals(" "))  
          i+= header.length;
      }

      int rem = bytescount - startind;
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


    println("finished");

    try {
      output.flush();
      output.close(); 
    } 
    catch (IOException e) {
      println("output flush and close failed");
    }

    println("rxed image");
    finished_rx = true;
    
    cl.stop();
   
  } else if (finished_rx) {
    
    PImage rxim = loadImage("output" + im_counter + ".jpg");
    
    rximageSmall = createImage(width,height, RGB);
    rximageSmall.copy(rxim,0,0,rxim.width,rxim.height, 0,0,width,height);
    
    
    loadPixels();
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        //mirror reverse
      pixels[i*width+width-j-1] = color(abs(brightness(rximageSmall.pixels[i*width+j]) - 
                                            brightness(srcimageSmall.pixels[i*width+j]) ));
    }}
    updatePixels();
    
    
    
    getImage();
  }
} 

int rximagecounter = 0;

void keyPressed() {
  if (key == 'a') {
     
    /// TBD need to save fullsize image instead
    rximageSmall.save(newSrcImageName + "approx.jpg");
    rximagecounter++;
    
     PImage im = getNewSrcImage();
     if (im == null) {
       println("end of src images");
       noLoop();
       return; 
     }
     srcimageSmall = createImage(width, height, RGB);
     srcimageSmall.copy(im,0,0, im.width, im.height, 0,0, width,height); 
  } 
}



