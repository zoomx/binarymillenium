/**
 * Shared Drawing Canvas (Client) 
 * by Alexander R. Galloway. 
 * 
 * The Processing Client class is instantiated by specifying a remote 
 * address and port number to which the socket connection should be made. 
 * Once the connection is made, the client may read (or write) data to the server.
 * Before running this program, start the Shared Drawing Canvas (Server) program.
 */


import processing.net.*;

Client c;
String input = new String("1234");
int data[];

int w = 320;
int h = 240;

//byte[] imagebuffer = new byte[w*h*3];
byte[] rxbuffer = new byte[w*h*3];

void setup() 
{
  size(w, h);
  background(204);
  stroke(0);
  frameRate(1); // Slow it down a little
  // Connect to the server's IP address and port
  c = new Client(this, "127.0.0.1", 12345); // Replace with your server's IP and port
}

boolean rximage = false;
int imind = 0;

int framecount = 0;

void draw() 
{ 
  int num = c.available();
  if (num > 0) {

    if ((rximage == false) && (num >= 4)) {
      
      char data[] = {c.readChar(),c.readChar(),c.readChar(),c.readChar()};
      input = new String(data);

      if (input.equals("IMST")) {
         framecount++;
        rximage = true;
        imind = 0;
      }

    } 
    else {
      loadPixels();
      int count = c.readBytes(rxbuffer);
      println(count + " " + framecount);

      for (int i = 0; i < count; i++) {
        if (i+imind >= rxbuffer.length) {
          //println("too many bytes rxed " + (count + imind) );
         
          rximage = false;
        } 
        else {
          int pixind = (int) ((i+imind)/3);
          int cind = (i+imind)%3;
          if (cind == 0)
            pixels[pixind] = (pixels[pixind] & 0xFFFFFF00) + rxbuffer[i]; 
          if (cind == 1)
            pixels[pixind] = (pixels[pixind] & 0xFFFF00FF) + rxbuffer[i]<<8;
          if (cind == 2)
            pixels[pixind] = (pixels[pixind] & 0xFF00FFFF) + rxbuffer[i]<<16;
        }
      }
      
      //if (count+imind)

      imind += count;
      updatePixels();
    }
  }

}

