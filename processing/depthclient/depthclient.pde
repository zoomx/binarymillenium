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
import java.io.*;

Client c;
String input = new String("1234");
int data[];

int w = 320;
int h = 240;


String imagebase = "C:/Documents and Settings/lucasw/My Documents/own/processing/depthclient/frames/rxim_";

//byte[] imagebuffer = new byte[w*h*3];
//byte[] rxbuffer = new byte[w*h*3];

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

int index = 10000;
int totalcount = 0;
OutputStream output;
int len = 0;

void draw() 
{ 

  int num = c.available();
  if (num > 0) {
    println("num " + num);



    if ((rximage == false) && (num >= 8)) {

      char data[] = {
        c.readChar(),c.readChar(),c.readChar(),c.readChar()      };
      input = new String(data);

      println(input); 

      if (input.equals("IMST")) {
        index++; 
        rximage = true;
        imind = 0;
        totalcount = 0;

        int len1 = (int) c.readChar() ;
        int len2= (int) c.readChar() ;
        int len3 = (int) c.readChar() ;
        int len4 = (int) c.readChar() ;

        print(len1 + ", len " + len2);

        len = len1 + len2*256;//len3<<16 + len4<<24;
        output = createOutput("frames/rxim_" + index + ".png");

        println("expecting " + len + " bytes");

        num -= 8;
      }  


    } 

    if (rximage) {  
      if (num > (len - totalcount)) {
        num = len-totalcount;
        rximage = false;
        println("finished");
        try {  
          output.flush();
          output.close();
        } 
        catch (IOException e) {
          println("output flush and close failed");
        }
        
      }

      byte[] byteBuffer = new byte[num];
      int count = c.readBytes(byteBuffer);

      int written = 0;
      try {
        output.write(byteBuffer);//,totalcount,rem);

      } 
      catch (IOException e) {
        println("output write failed");
        return;
      }  

      println("count " + count + ", num " + num);
      totalcount+=count;
    }

  }

}


