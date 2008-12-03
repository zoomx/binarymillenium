/**
 * Shared Drawing Canvas (Server) 
 * by Alexander R. Galloway. 
 * 
 * A server that shares a drawing canvas between two computers. 
 * In order to open a socket connection, a server must select a 
 * port on which to listen for incoming clients and through which 
 * to communicate. Once the socket is established, a client may 
 * connect to the server and send or receive commands and data.
 * Get this program running and then start the Shared Drawing
 * Canvas (Client) program so see how they interact.
 */


import processing.net.*;

Server s;
Client c;
String input;
int data[];

int w = 320;
int h = 240;
byte[] pixbytes = new byte[w*h*3];

void setup() 
{
  size(w, h);
  background(204);
  stroke(0);
  frameRate(5); // Slow it down a little
  s = new Server(this, 12345); // Start a simple server on a port
}

boolean active = false;
void keyPressed() 
{
  if (key == 'a') {
    active = true;
  }   
}

int count = 0;
int framecount = 0;

void draw() 
{
  if (mousePressed == true) {
    // Draw our line
    stroke(255);
    line(pmouseX, pmouseY, mouseX, mouseY);
    // Send mouse coords to other person
    //s.write(pmouseX + " " + pmouseY + " " + mouseX + " " + mouseY + "\n");
  }
  count++;
  
  if (count > 40) {
  if ((s.clientCount > 0) && active) {
    
    println(framecount);
    framecount++;
    
    loadPixels();

    for (int i = 0; i < pixels.length  ; i++) {
      pixbytes[i*3]   = (byte) (pixels[i] & 0xFF);
      pixbytes[i*3+1] = (byte) (pixels[i] >> 8 & 0xFF);
      pixbytes[i*3+2] = (byte) (pixels[i] >> 16 & 0xFF);
    }

    s.write("IMST");
    s.write(pixbytes);
  }
  }
}

