/**
 * HTTP Client. 
 * 
 * Starts a network client that connects to a server on port 80,
 * sends an HTTP 1.1 GET request, and prints the results. 
 */


import processing.net.*;

Client c;
String data;

byte byteBuffer[] = new byte[10000];

OutputStream output;
//PrintWriter output;

void setup() {
  size(200, 200);
  background(50);
  fill(200);
  c = new Client(this, "processing.org", 80); // Connect to server on port 80
  c.write("GET /img/processing.gif HTTP/1.1\n"); // Use the HTTP "GET" command to ask for a Web page
  c.write("Host: my_domain_name.com\n\n"); // Be polite and say who we are

    output = createOutput("output.gif");
  //output = createWriter("output.gif");
}

boolean received = false;
boolean readingheader = true;
int totalcount = 0;
int expectedlength = 0;

void draw() {
  if (c.available() > 0) { // If there's incoming data from the client...


    {
      int count = c.readBytes(byteBuffer); // ...then grab it and print it

      if (readingheader) {
        readingheader = false; 
        String raw = new String(byteBuffer);

        String[] header = split(raw, "\n");

        /*
        if (header.length < 9) {
         println("split header- quitting, TBD allow this later");
         return; 
        }*/

        int startind = 0;
        for (int i = 0; i < header.length; i++) {
          println(header[i]);
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

        int rem = count - startind;
        byte byteBuffer2[] = new byte[rem];
        for (int i = 0; i < rem; i++) {
          byteBuffer2[i] = byteBuffer[i+startind];
        }

        println("startind " + startind + ", count = " + count + 
          ", remaining = " + rem + ", " + byteBuffer2.length);

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
          output.write(byteBuffer,0,count); //,totalcount,count);
          totalcount+=count;
        } 
        catch (IOException e) {
          println("output write failed");
        }  

      }

      println(count + " " + totalcount);
      if (totalcount >= expectedLength) received = true;
    }

  } 
  else if (received) {


    println("finished");

    try {
      output.flush();
      output.close(); 
    } 
    catch (IOException e) {
      println("output flush and close failed");
    }

    noLoop();
  }
}



